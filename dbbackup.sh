#!/bin/bash

# Script to Backup the Domoticz Database via Telegram
#
# Author: Sándor Incze
# Version 1.0 (05-05-2024)
#
# Works with Raspberry Pi
# Execute the following commands after downloading in /home/pi/domoticz/system/ directory:
# $ chmod +x dbbackup.sh
#
# $ sudo nano /etc/crontab
# Execute the Script first of the month.
# 30 0 1 * *      root    /home/pi/domoticz/scripts/system/dbbackup.sh >/dev/null 2>&1
#

# Source configuration file
source /home/pi/domoticz/scripts/system/config

# Define colors
ON_BLUE="\033[44m"
RED="\033[1;31m"
GREEN="\033[1;32m"
STD="\033[0m" # Clear color

# Function to send a message to Telegram
send_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_ID" \
        -d "text=$message"
}

# Function to send a file to Telegram
send_file() {
    local file_path="$1"
    local caption="$2"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
        -F "chat_id=$TELEGRAM_ID" \
        -F "document=@$file_path" \
        -F "caption=$caption"
}

# Get date and time
DATE=$(date +"%m-%d-%y")

# Output formatting
format_output() {
    local title="$1"
    local message="$2"
    echo "_____________________________________"
    echo -e " ${GREEN} $title ${STD}"
    echo -e " ${RED} $message ${STD}"
    echo -e " ${GREEN} DATE: $DATE ${STD}"
    echo "_____________________________________"
}

# Send initial message
format_output "Title" "Message"
send_message "Hi, I'm your Domoticz backupbot to send files... UPLOADING here…" > /dev/null
format_output "Message Sent"

# Create backup file for database
BACKUP_DB="domoticzbackup.db"
TEMP_DIR="/var/log"
FILE_PATH="$TEMP_DIR/$BACKUP_DB"
echo "- Creating backup file for database here $FILE_PATH"

# Create backup file
echo "- Creating backup file for database."
/usr/bin/curl -s "http://$DOMOTICZ_IP:$DOMOTICZ_PORT/backupdatabase.php" > "$FILE_PATH" || { echo "Failed to create backup file"; exit 1; }

# Check if backup file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Backup file does not exist."
    send_message "Hi, Backup file does not exist." > /dev/null
    exit 1
fi

# Compress backup file
echo "- Creating compressed backup file from database."
gzip -9 "$FILE_PATH" || { echo "Failed to compress backup file"; exit 1; }

# Check if compressed file exists
if [ ! -f "$FILE_PATH.gz" ]; then
    echo "Compressed backup file does not exist."
    send_message "Hi, Compressed Backup file does not exist." > /dev/null
    exit 1
fi

# Upload file to Telegram
echo "Uploading to Telegram"
send_file "$FILE_PATH.gz" "Your file is here." > /dev/null || { echo "Failed to upload file to Telegram"; exit 1; }

# Check if upload was successful
if [ $? -ne 0 ]; then
    echo "File upload to Telegram failed."
    send_message "Hi, File upload to Telegram failed." > /dev/null
    exit 1
fi

# Cleanup
rm "$FILE_PATH.gz" || { echo "Failed to remove temporary file"; exit 1; }
