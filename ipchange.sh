#!/bin/bash

# Script to report public IP address change using Telegrambot.
# Modified By: Sándor Incze
# Version 1.0 (24-01-2022)
#
# Works with default Raspberry Pi install with user "Pi"
# Execute the following commands after downloading in /home/pi directory:
# $ chmod +x ipchange.sh
#
# $ sudo nano /etc/crontab
# Monitor external IP Changes each 30 minutes.
# Add this line: */30 * * * *   root   /home/pi/ipchange.sh  >/dev/null 2>&1
#

TOKEN="<telegram token>"
ID="<telegram_group_id_here"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

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
curl -s -X POST $URL -d chat_id=$ID -d text="$(echo -e "The IP Address at Lammertiend has changed, The IP address has been changed to $CURRENT_IP")" > /dev/null 2>&1

logger -t ipcheck -- IP changed to $CURRENT_IP
else

#If not just report that it stayed the same
#curl -s -X POST $URL -d chat_id=$ID -d text="$(echo -e "The IP Address at Lammertiend is the same. The IP address stayed the same $CURRENT_IP")" > /dev/null 2>&1
logger -t ipcheck -- NO IP change
fi
