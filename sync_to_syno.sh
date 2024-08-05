#!/bin/bash

# Script to BACKUP data from NVME drive to mounted SYNOLOGY Share.
# Created By: Sándor Incze
# Version 1.0 (05-08-2024)
#
# Works with default Raspberry Pi install with user "Pi"
# Execute the following commands after downloading in /home/pi/domoticz/scripts/system/ directory:
# $ chmod +x sync_to_syno.sh
#
# Execute via or add to crontab
# $ sudo ./sync_to_syno.sh
#

# Config file in here
# -------------------
source /home/pi/scripts/config
# -------------------

# Source and destination directories
SRC_DIR="/media"
DEST_DIR="/mnt/syno"

# Rsync options
RSYNC_OPTS="-av --progress --delete"

# Function to perform a dry run
dry_run() {
    echo "PI: Performing a dry run from PI to Synology..."
    rsync $RSYNC_OPTS --dry-run "$SRC_DIR/" "$DEST_DIR/"
    echo "PI: Dry run from PI to Synology complete. No changes made."
}

# Function to perform the actual sync
sync_files() {
    echo "PI: Syncing files from NVME $SRC_DIR to SYNOLOGY $DEST_DIR..."
    curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "Syncing files from $SRC_DIR to $DEST_DIR...")" > /dev/null 2>&1

    rsync $RSYNC_OPTS "$SRC_DIR/" "$DEST_DIR/"
    echo "PI: Sync complete."
    curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "Syncing files from $SRC_DIR to $DEST_DIR completed!")" > /dev/null 2>&1
}

# Function to send a message to Telegram
send_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_ID" \
        -d "text=$message"
}
# Main function
main() {
    echo "PI: Starting rsync script from NVME to Synology."
    send_message "PI: Starting rsync script, Syncing files from NVME $SRC_DIR to Synology $DEST_DIR." > /dev/null

    # Perform dry run
    dry_run

    # Prompt user for confirmation before actual sync
    read -p "Do you want to proceed with the actual sync? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        sync_files
    else
        echo "PI: Sync operation cancelled."
        send_message "Sync operation cancelled, from $SRC_DIR to $DEST_DIR." > /dev/null
    fi
    echo "PI: Rsync script finished."
    send_message "PI: NVME sync to Synology Finished" > /dev/null
}

# Run main function
main
