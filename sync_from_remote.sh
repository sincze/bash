#!/bin/bash

# Script to PULL data as BACKUP from remote NVME drive to local SYNOLOGY.
# It uses SSH login with keys, so please enable that first.
# HINT: https://www.raspberrypi.com/documentation/computers/remote-access.html#configure-ssh-without-a-password
#
# Created By: Sándor Incze
# Version 1.0 (05-08-2024)
#
# Works with default Raspberry Pi install with user "Pi"
# Execute the following commands after downloading in /root/ directory:
# $ chmod +x sync_from_remote.sh
#
# Execute via Synology Task Scheduler
# $ bash /root/sync_from_remote.sh
#
# CLI USAGE:    ./sync_from_remote.sh --dry-run
#               ./sync_from_remote.sh
#

# Config file in here
# -------------------
source /root/config
# -------------------

# Configuration
PI_HOST="hostname"                                      # Replace with the IP or hostname of the Raspberry Pi
PI_USER="pi"                                            # Replace with the Raspberry Pi's username
PI_MUSIC_DIR="/remote/dir"                              # Source directory on Raspberry Pi
DS_MUSIC_DIR="/local/dir"                               # Destination directory on Synology DiskStation

LOG_FILE="/var/log/backup_music.log"                    # Log file location

RSYNC_OPTS="-avz --delete --progress"                   # rsync options including progress

# Function to send a Telegram message
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_ID}" \
    -d "text=${message}" > /dev/null
}

# Function to log messages
log_message() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" | tee -a "${LOG_FILE}"
}

# Function to perform a dry run
dry_run() {
    log_message "Starting dry run..."
    rsync $RSYNC_OPTS --dry-run "${PI_USER}@${PI_HOST}:${PI_MUSIC_DIR}/" "${DS_MUSIC_DIR}"
    log_message "Dry run complete. No changes made."
}

# Main backup function
backup() {
    # Send a message when the backup starts
    log_message "DS412: Backup of Music directory from Zevenbergen NVME started."
    send_telegram_message "DS412: Backup of Music directory from Zevenbergen NVME started."

    # Perform the backup using rsync
    rsync $RSYNC_OPTS "${PI_USER}@${PI_HOST}:${PI_MUSIC_DIR}/" "${DS_MUSIC_DIR}"

    # Check if the rsync command was successful
    if [ $? -eq 0 ]; then
        log_message "DS412: Backup of Music directory from Zevenbergen NVME completed successfully."
        send_telegram_message "DS412: Backup of Music directory from Zevenbergen NVME completed successfully."
    else
        log_message "DS412: Backup of Music directory from Zevenbergen NVME failed."
        send_telegram_message "DS412: Backup of Music directory from Zevenbergen NVME failed."
    fi
}

# Check for the --dry-run flag
if [[ $1 == "--dry-run" ]]; then
    dry_run
else
    backup
fi
