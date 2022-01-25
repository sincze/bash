#!/bin/bash

# Script to report public IP address change using Telegrambot.
# Modified By: Sándor Incze
# Version 1.0 (24-01-2022)
# Version 1.1 (25-01-2022) included "config" file needs to be placed somewhere
#
# Works with default Raspberry Pi install with user "Pi"
# Execute the following commands after downloading in /home/pi/domoticz/scripts/system/ directory:
# $ chmod +x ipchange.sh
#
# $ sudo nano /etc/crontab
# Monitor external IP Changes each 30 minutes.
# Add this line: */30 * * * *   root   /home/pi/domoticz/scripts/system/ipchange.sh  >/dev/null 2>&1
#
# Config file in here
# -------------------
source /home/pi/domoticz/scripts/system/config
# -------------------

#The file that contains the current pubic IP
EXT_IP_FILE="/home/pi/ipaddress"

#Get the current public IP from whatsmyip.com
CURRENT_IP=$(curl -s http://ifconfig.me)

#Check file for previous IP address
if [ -f $EXT_IP_FILE ]; then
KNOWN_IP=$(cat $EXT_IP_FILE)
else
KNOWN_IP=
fi

#See if the IP has changed
if [ "$CURRENT_IP" != "$KNOWN_IP" ]; then
echo $CURRENT_IP > $EXT_IP_FILE

#If so send an alert
curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "The external IP Address of $HOSTNAME has changed, The IP address has been changed to $CURRENT_IP")" > /dev/null 2>&1

logger -t ipcheck -- IP changed to $CURRENT_IP
else

#If not just report that it stayed the same
curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "The external IP Address of $HOSTNAME is still the same. The IP address stayed the same $CURRENT_IP")" > /dev/null 2>&1
logger -t ipcheck -- NO IP change
fi
