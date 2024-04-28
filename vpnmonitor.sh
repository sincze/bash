#!/bin/bash

# Script to monitor OpenVPN logs to see if someone logs in.
# We assume the dockername is -openvpn-
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
    local entry_date=$(date -d '1 minute ago' "+%Y-%m-%dT%H:%M")
    local logs=$(sudo /usr/bin/docker logs openvpn 2>&1 | grep "$entry_date" | grep -E "autologin|client-instance exiting")
    if [[ -n "$logs" ]]; then
        echo "$logs" | while IFS= read -r line; do

            # Extract the timestamp from the log line
            timestamp=$(echo "$line" | awk -F' ' '{print $1}')

            # Convert the timestamp to a human-readable format
            formatted_timestamp=$(date -d "$timestamp" "+%d-%m-%Y %H:%M:%S")

            if [[ $line == *"client-instance exiting"* ]]; then
                # Extract relevant information for client disconnection
                local user=$(echo "$line" | awk -F' ' '{print $8}' | awk -F'/' '{print $1}')
                if [[ $user == *_AUTOLOGIN ]]; then
                    user="${user%%_AUTOLOGIN}"  # Extract username before _AUTOLOGIN
                fi
                local reason=$(awk -F"SIGTERM" '{print $2}' <<< "$line" | awk -F", " '{print $1}')
                local message="vpnmonitor.sh: On $formatted_timestamp OpenVPN connection for user $user was terminated. Reason: $reason"
            else
                # Extract relevant information for client connection
                local user=$(awk -F"user': '" '{print $2}' <<< "$line" | awk -F"'" '{print $1}')
                local cli=$(awk -F"cli='" '{print $2}' <<< "$line" | awk -F"'" '{print $1}')
                local reason=$(awk -F"reason': '" '{print $2}' <<< "$line" | awk -F"'" '{print $1}')
                local message="vpnmonitor.sh: On $formatted_timestamp OpenVPN was accessed by user $user using a $cli client. Reason: $reason"
            fi

            # Send notification
            echo "$message"
            logger "$message"
            send_notification "$message"
        done
    fi
}


# Call parse_logs function
parse_logs
