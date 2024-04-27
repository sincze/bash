#!/bin/bash

# Script to monitor OpenVPN logs to see if someone logs in.
# It will send a telegram message!
#
# We assume the dockername is -openvpn- if not change line 36.
#
# Author: Sándor Incze
# Version 1.0 (27-04-2024)
#
# Works with Raspberry Pi
# Execute the following commands after downloading in /home/pi/scripts/ directory:
# $ chmod +x vpnmonitor.sh
#
# $ sudo nano /etc/crontab
# Monitor Domoticz every minute.
# Add this line: * * * * *   root   /home/pi/scripts/vpnmonitor.sh >/dev/null 2>&1
#

# Source the config file
source /home/pi/scripts/config

# Export the variables
export TELEGRAM_TOKEN TELEGRAM_ID

# Function to send Telegram notification
send_notification() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_ID" \
        -d "text=${message}" >/dev/null
}

parse_logs() {
    local entry_date=$(date -d '1 min ago' "+%H:%M")
    local logs=$(sudo /usr/bin/docker logs openvpn 2>&1 | grep "$entry_date" | grep "autologin")
    if [[ -n "$logs" ]]; then
        echo "$logs" | while IFS= read -r line; do
            local date=$(echo "$line" | awk '{print $1}')
            local user=$(awk -F"'" '{print $4}' <<< "$line")
            local cli=$(awk -F"'" '{print $6}' <<< "$line")
            local reason=$(awk -F"'" '{print $8}' <<< "$line")
            # Send notification
            local message="vpnmonitor.sh: OpenVPN accessed on $date by user $user using client $cli. Reason: $reason"
            echo "$message"
            logger "$message"
            send_notification "$message"
        done
    fi
}

# Call parse_logs function
parse_logs
