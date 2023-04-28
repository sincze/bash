#!/bin/bash

# Script to upload Gasmeter data to Mindergas.nl
# Based on the new API
#
# Modified By: Sándor Incze
# Version 1.0 (27-04-2023)
#
# Works with default Raspberry Pi install with user "Pi"
# Execute the following commands after downloading in /home/pi/domoticz/scripts/system/ directory:
# $ chmod +x mindergas.sh
#
# $ sudo nano /etc/crontab
# Monitor Domoticz every minute.
# Add this line: 59 23 * * *   root   /home/pi/domoticz/scripts/system/mindergas.sh >/dev/null 2>&1
#
# Config file in here
# -------------------
source /home/pi/domoticz/scripts/system/config
# -------------------

#Token to authenicate with mindergas.nl
TOKEN=$MINDERGAS_API
IDX=$GAS_IDX

#fetch meterstand
METERSTAND=`curl -s --connect-timeout 2 --max-time 5 "Accept: application/json" "http://$DOMOTICZ_IP:$DOMOTICZ_PORT/json.htm?type=devices&rid=$IDX"  | /bin/grep '"Counter" :' | awk {'print $3'} | /usr/bin/cut -d '"' -f 2`
if [ $METERSTAND ] ; then
#   echo $METERSTAND

   #Get OS date, and format it corectly.
   NOW=$(date +"%Y-%m-%d")
#   NOW=$(date  --date="yesterday" +"%Y-%m-%d")

   #Build JSON by hand ;-)
   JSON='{ "date":"'$NOW'", "reading":"'$METERSTAND'"  }'

   #post using curl to API
   curl -v -H "Content-Type:application/json" -H "AUTH-TOKEN:$TOKEN" -d "$JSON"  https://www.mindergas.nl/api/meter_readings
   exit
else
  echo "Error no value!"
fi
