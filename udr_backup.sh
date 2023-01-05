#!/bin/bash
# Usage: ./udr_backup.sh [-i UDR_IP] [-u UDR_USERNAME] [-d LOCAL_BACKUP_DIR] [-s SOURCE_BACKUP_DIR] [-q] [-n] [-h]

# Check if required dependencies are installed
if ! command -v rsync >/dev/null; then
  echo "Error: rsync is not installed." >&2
  exit 1
fi
if ! command -v ssh >/dev/null; then
  echo "Error: ssh is not installed." >&2
  exit 1
fi

# Read the configuration file
if [ ! -f "udr_backup.conf" ]; then
  echo "Error: configuration file not found." >&2
  exit 1
fi
source udr_backup.conf

# Validate the SSH keys file
if [ ! -f "$SSH_KEYS" ]; then
  echo "Error: SSH keys file not found." >&2
  exit 1
fi

# Validate the configuration file
if [ -z "$UDR_IP" ] || [ -z "$UDR_USERNAME" ] || [ -z "$LOCAL_BACKUP_DIR" ] || [ -z "$SOURCE_BACKUP_DIR" ] || [ -z "$SSH_KEYS" ]; then
  echo "Error: configuration file is missing required parameters." >&2
  exit 1
fi

# Parse the command line arguments
DRY_RUN=0
VERBOSE=1
while getopts ":i:u:d:s:qnh" opt; do
  case $opt in
    i) UDR_IP="$OPTARG";;
    u) UDR_USERNAME="$OPTARG";;
    d) LOCAL_BACKUP_DIR="$OPTARG";;
    s) SOURCE_BACKUP_DIR="$OPTARG";;
    q) VERBOSE=0;;
    n) DRY_RUN=1;;
    h) printf "Usage: %s [-i UDR_IP] [-u UDR_USERNAME] [-d LOCAL_BACKUP_DIR] [-s SOURCE_BACKUP_DIR] [-q] [-n] [-h]\n" "$0" >&2; exit 0;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1;;
  esac
done

# Set the log file
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOCAL_BACKUP_DIR/udr_backup_$TIMESTAMP.log"

# Check if the local backup directory exists and create it if it does not
if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
  mkdir -p $LOCAL_BACKUP_DIR
fi

# Set options for rsync
RSYNC_OPTS="-avz -e ssh"

if [ $VERBOSE -eq 0 ]; then
  RSYNC_OPTS="$RSYNC_OPTS -q"
fi
if [ $DRY_RUN -eq 1 ]; then
  RSYNC_OPTS="$RSYNC_OPTS --dry-run --stats"
fi

# Exit the script if any command returns a non-zero exit code
set -e

# Extract the number of files transferred from the rsync dry-run output
FILES_TRANSFERRED=$(rsync $RSYNC_OPTS --dry-run --stats "$UDR_USERNAME@$UDR_IP:$SOURCE_BACKUP_DIR/*.unf" $LOCAL_BACKUP_DIR 2>&1 | grep "Number of regular files transferred:" | awk -F: '{print $2}')
# Connect to the UniFi Dream Machine and download the new backups using rsync
rsync $RSYNC_OPTS --update --progress --stats "$UDR_USERNAME@$UDR_IP:$SOURCE_BACKUP_DIR/*.unf" $LOCAL_BACKUP_DIR 2>&1 | tee -a $LOG_FILE

# Catch any errors and log them
trap 'echo "Error: $?" >&2' ERR

# Output download results
if [ $DRY_RUN -eq 1 ]; then
  echo "-------------------" | tee -a $LOG_FILE
  echo " Dry run completed." | tee -a $LOG_FILE
  echo "-------------------" | tee -a $LOG_FILE
else
  if [ $FILES_TRANSFERRED -ne 0 ]; then
    echo "---------------------------------------" | tee -a $LOG_FILE
    echo "Files transferred:$FILES_TRANSFERRED" | tee -a $LOG_FILE
    echo "---------------------------------------" | tee -a $LOG_FILE
    echo "Backups downloaded to: $LOCAL_BACKUP_DIR" | tee -a $LOG_FILE
    echo "---------------------------------------" | tee -a $LOG_FILE
  else
    echo "-------------------------" | tee -a $LOG_FILE
    echo "No files transferred or synced." | tee -a $LOG_FILE
    echo "-------------------------" | tee -a $LOG_FILE
  fi
fi

# Cleanup old files #

# Find all backup files in the local backup directory
BACKUP_FILES=$(find "$LOCAL_BACKUP_DIR" -maxdepth 1 -type f -name '*.unf' -printf '%T@ %p\n' | sort -n | cut -d' ' -f2)

# If there are more than 20 backup files, delete the oldest ones
if [ "$(echo "$BACKUP_FILES" | wc -l)" -gt 20 ]; then
  DELETE_FILES=$(echo "$BACKUP_FILES" | head -n -20)
  echo "Deleting $DELETE_FILES" >> "$LOG_FILE"
  rm -f $DELETE_FILES
fi

# Find all log files in the local backup directory
LOG_FILES=$(find "$LOCAL_BACKUP_DIR" -maxdepth 1 -type f -name '*.log' -printf '%T@ %p\n' | sort -n | cut -d' ' -f2)

# If there are more than 20 log files, delete the oldest ones
if [ "$(echo "$LOG_FILES" | wc -l)" -gt 20 ]; then
  DELETE_FILES=$(echo "$LOG_FILES" | head -n -20)
  echo "Deleting $DELETE_FILES" >> "$LOG_FILE"
  rm -f $DELETE_FILES
fi
