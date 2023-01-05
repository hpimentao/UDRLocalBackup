# UDRLocalBackup
A script to remotely back up files from a UniFi Dream Router (UDR) to a local directory.

file name: udr_backup.sh

**Dependencies**

    -rsync
    -ssh

**Configuration**

This script requires a configuration file located at /path/to/config/file/udr_backup.conf with the following variables:

    UDR_IP: IP address of the UDR
    UDR_USERNAME: username for the UDR
    LOCAL_BACKUP_DIR: local directory for the backups
    SOURCE_BACKUP_DIR: directory on the UDR from which the backups will be downloaded (For UDR autobackup files location: /ssd1/.data/unifi/data/backup/autobackup)
    SSH_KEYS: file containing the SSH keys for accessing the UDR

**Usage**

<pre><code>./udr_backup.sh [-i UDR_IP] [-u UDR_USERNAME] [-d LOCAL_BACKUP_DIR] [-s SOURCE_BACKUP_DIR] [-q] [-n] [-h]</code></pre>

**Options**

    -i UDR_IP: IP address of the UDR (overrides the value in the configuration file)
    -u UDR_USERNAME: username for the UDR (overrides the value in the configuration file)
    -d LOCAL_BACKUP_DIR: local directory for the backups (overrides the value in the configuration file)
    -s SOURCE_BACKUP_DIR: directory on the UDR from which the backups will be downloaded (overrides the value in the configuration file)
    -q: run the script quietly (do not print verbose output)
    -n: dry run (do not download the backups, just print what would have been transferred)
    -h: display usage information

**Functionality**

1. The script checks if the required dependencies, `rsync` and `ssh`, are installed on the system. If either is not found, it will exit with an error message.
2. The script reads the configuration file located at `/path/to/config/file/udr_backup.conf` and sources it to read the variables defined in the file.
3. The script checks if the SSH keys file specified in the configuration file (`$SSH_KEYS`) exists. If the file is not found, it will exit with an error message.
4. The script checks if the required parameters in the configuration file (`UDR_IP`, `UDR_USERNAME`, `LOCAL_BACKUP_DIR`, `SOURCE_BACKUP_DIR`, and `SSH_KEYS`) are set. If any of these variables are empty, it will exit with an error message.
5. The script parses the command line arguments using the `getopts` builtin. The script supports the following options:
   - `-i UDR_IP`: Specifies the IP address of the UniFi Dream Router.
   - `-u UDR_USERNAME`: Specifies the username to use when connecting to the UniFi Dream Router via SSH.
   - `-d LOCAL_BACKUP_DIR`: Specifies the local directory where the backups will be saved.
   - `-s SOURCE_BACKUP_DIR`: Specifies the directory on the UniFi Dream Router where the backups are stored.
   - `-q`: Runs the script in quiet mode (suppresses progress and status messages).
   - `-n`: Runs the script in dry-run mode (performs a simulation of the backup process without transferring any files).
   - `-h`: Displays the usage message and exits.
6. The script sets the log file name to `udr_backup_$TIMESTAMP.log`, where `$TIMESTAMP` is the current date and time in the format `YYYYMMDD_HHMMSS`.
7. The script checks if the local backup directory (`$LOCAL_BACKUP_DIR`) exists. If the directory does not exist, it will create the directory and any necessary parent directories.
8. The script sets the options for `rsync` in the `$RSYNC_OPTS` variable. The `-avz` options enable archive mode, verbose output, and compression, respectively. The `-e ssh` option specifies that `ssh` should be used for communication with the remote device. If the `-q` option was specified, the `-q` option is added to the `$RSYNC_OPTS` variable to run rsync in quiet mode. If the `-n` option was specified, the `--dry-run` and `--stats` options are added to the `$RSYNC_OPTS` variable to run `rsync` in dry-run mode and display transfer statistics.
9. The script runs a dry-run of `rsync` to extract the number of files transferred. The `--dry-run` and `--stats` options are used to display transfer statistics without actually transferring any files. The `grep` and `awk` commands are used to extract the number of files transferred from the `rsync` output. The result is stored in the `$FILES_TRANSFERRED` variable.
10. The script runs `rsync` to download the backups from the UniFi Dream Router. The `--update` and `--progress` options are used to skip files that are already up-to-date and display progress information, respectively. The `--stats` option is used to display transfer statistics.
11. The script prints the number of files transferred and the total transfer size.
12. The script lists and deletes the oldest backup and log files in the local backup directory if there are more than 20 of each type and finaly exits.

**Scheduling**

To schedule the script you can use a cron job.
To edit the cron jobs for the current user, open a terminal and type:

<pre><code>crontab -e</code></pre>
    
If you want to schedule the script to run at a specific time or frequency, you can use the following syntax:

<pre><code>
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *  command_to_execute
</code></pre>

For example, to schedule the script to run every day at 5 am, you can use the following cron job:

<pre><code>0 5 * * * /path/to/udr_backup.sh -i UDR_IP -u UDR_USERNAME -d LOCAL_BACKUP_DIR -s SOURCE_BACKUP_DIR</code></pre>
or
<pre><code>0 5 * * * /path/to/udr_backup.sh</code></pre>


**Note**: This script has only been tested on a UniFi Dream Router. It may or may not work with the UniFi Dream Machine or UniFi Dream Machine Pro. Use at your own risk.
