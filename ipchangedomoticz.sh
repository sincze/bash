#!/bin/bash

# Script to report public IP address change
# By: Sándor Incze
#
# V1.02 18-02-2022 Changed to original ipchange.sh to extract data from Domoticz (user variable WAN_IP) instead of a local file. 
# V1.01 13-02-2022 Changed from whatismyip to ifconfig.me, no cutting in result needed ;-)

# Config file in here
# -------------------
source /home/pi/domoticz/scripts/system/config
# -------------------

#Get the current public IP:
CURRENT_IP=$(curl -s http://ifconfig.me)

#Get the current KNOWN IP from DOMOTICZ
DOMOTICZ_WAN=$(curl -s 'http://'$DOMOTICZ_IP':'$DOMOTICZ_PORT'/json.htm?type=command&param=getuservariable&idx='$WAN_IP_VAR'' | jq '.result[].Value' | cut -f1 -d" " | sed 's/\"//g')

echo "The Current Internet IP IS: "$CURRENT_IP", According to Domoticz WAN IP IS: "$DOMOTICZ_WAN

if [ "$CURRENT_IP" != "$DOMOTICZ_WAN" ] && [[ $CURRENT_IP == *"."* ]]; then   # UPDATE DOMOTICZ VARIABLE if the IP was different

  #If so send an alert
  curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "The external IP Address of $HOSTNAME has changed, The IP address has been changed to $CURRENT_IP")" > /dev/null 2>&1
  curl -s 'http://'$DOMOTICZ_IP':'$DOMOTICZ_PORT'/json.htm?type=command&param=udevice&idx='$WAN_IP_IDX'&nvalue=0&svalue='$CURRENT_IP''
  curl -s 'http://'$DOMOTICZ_IP':'$DOMOTICZ_PORT'/json.htm?type=command&param=updateuservariable&vname=WAN_IP&vtype=string&vvalue='$CURRENT_IP''
  logger -t ipcheck -- IP changed to $CURRENT_IP
else
  echo "Update not necessary"
  logger -t ipcheck -- NO IP change
fi
