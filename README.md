# UDRLocalBackup
A script to remotely back up files from a UniFi Dream Router (UDR) to a local directory.

file name: udr_backup.sh

Dependencies

    -rsync
    -ssh

Configuration

This script requires a configuration file located at /path/to/config/file/udr_backup.conf with the following variables:

    UDR_IP: IP address of the UDR
    UDR_USERNAME: username for the UDR
    LOCAL_BACKUP_DIR: local directory for the backups
    SOURCE_BACKUP_DIR: directory on the UDR from which the backups will be downloaded
    SSH_KEYS: file containing the SSH keys for accessing the UDR

Usage

./udr_backup.sh [-i UDR_IP] [-u UDR_USERNAME] [-d LOCAL_BACKUP_DIR] [-s SOURCE_BACKUP_DIR] [-q] [-n] [-h]

Options

    -i UDR_IP: IP address of the UDR (overrides the value in the configuration file)
    -u UDR_USERNAME: username for the UDR (overrides the value in the configuration file)
    -d LOCAL_BACKUP_DIR: local directory for the backups (overrides the value in the configuration file)
    -s SOURCE_BACKUP_DIR: directory on the UDR from which the backups will be downloaded (overrides the value in the configuration file)
    -q: run the script quietly (do not print verbose output)
    -n: dry run (do not download the backups, just print what would have been transferred)
    -h: display usage information

Functionality

    1.The script checks if the required dependencies are installed. If not, it will exit with an error message.
    2.The script reads the configuration file and sources it.
    3.The script checks if the SSH keys file specified in the configuration file exists. If not, it will exit with an error message.
    4.The script checks if the required parameters in the configuration file are set. If any are missing, it will exit with an error message.
    5.The script parses the command line arguments.
    6.The script sets the log file.
    7.The script checks if the local backup directory exists and creates it if it does not.
    8.The script sets the options for rsync.
    9.The script runs a dry-run of rsync to extract the number of files transferred.
    10.The script runs rsync to download the backups from the UDR.
    11.The script prints the number of files transferred and the total transfer size.
    12.The script exits.
    
To schedule the script you can use a cron job.
To edit the cron jobs for the current user, open a terminal and type:

crontab -e
    
If you want to schedule the script to run at a specific time or frequency, you can use the following syntax:

# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *  command_to_execute

For example, to schedule the script to run every day at 5 am, you can use the following cron job:

0 5 * * * /path/to/udr_backup.sh -i UDR_IP -u UDR_USERNAME -d LOCAL_BACKUP_DIR -s SOURCE_BACKUP_DIR
or
0 5 * * * /path/to/udr_backup.sh


**Note**: This script has only been tested on a UniFi Dream Router. It may or may not work with the UniFi Dream Machine or UniFi Dream Machine Pro. Use at your own risk.
