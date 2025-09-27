#!/bin/bash

# Script to monitor Undervoltage messages. Probably time to change a POE adapter ;-)
#
# Author: Sándor Incze
# Version 1.0 (27-09-2025)
#
# Works with Raspberry Pi
# Execute the following commands after downloading in /home/pi/scripts/ directory:
# $ chmod +x undervoltagemonitor.sh
#
# $ sudo nano /etc/crontab
# Monitor Domoticz every minute.
# Add this line: * * * * *   root   /home/pi/scripts/undervoltagemonitor.sh >/dev/null 2>&1
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

#!/bin/bash

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

check_undervoltage() {
    local host=$(hostname)

    local entry_date=$(date -d '1 minute ago' "+%b %e %H:%M")

    # Use journalctl (preferred) or fallback to syslog
#    local logs=$(journalctl -b --since "1 minute ago" 2>/dev/null | grep "Undervoltage detected")
    # DEBUG
#    local logs=$(journalctl --since "24 hours ago" 2>/dev/null | grep "Undervoltage detected")

    # Alternatively:
    # local logs=$(grep "$entry_date" /var/log/syslog | grep "Undervoltage detected")

    local count=$(echo "$logs" | grep -c "Undervoltage detected")

    if (( count > 2 )); then
        local now=$(date "+%d-%m-%Y %H:%M:%S")
        local message="$host - undervoltagenmonitor.sh: On $now kernel reported $count undervoltage warnings in the last minute!"
        echo "$message"
        logger "$message"
        send_notification "$message"
    fi
}

# Call the function
check_undervoltage
