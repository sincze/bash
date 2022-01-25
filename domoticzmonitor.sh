
#!/bin/bash

# Script to monitor if Domoticz is still up and running.
# If not.. restart Domoticz and report via Telegrambot.
#
# Modified By: Sándor Incze
# Version 1.0 (25-01-2022)
#
# Works with default Raspberry Pi install with user "Pi"
# Execute the following commands after downloading in /home/pi/domoticz/scripts/system/ directory:
# $ chmod +x domoticzmonitor.sh
#
# $ sudo nano /etc/crontab
# Monitor Domoticz every minute.
# Add this line: * * * * *   root   /home/pi/domoticz/scripts/system/domoticzmonitor.sh >/dev/null 2>&1
#
# Config file in here
# -------------------
source /home/pi/domoticz/scripts/system/config
# -------------------

dt=$(date '+%d/%m/%Y %H:%M:%S')
STATUS=`curl -s --connect-timeout 2 --max-time 5 "Accept: application/json" "http://$DOMOTICZ_IP:$DOMOTICZ_PORT/json.htm?type=devices&rid=1" | grep "status"| awk -F: '{print $2}'|sed 's/,//'| sed 's/\"//g'`
if [ $STATUS ] ; then
        MINUTE=$(date +"%M")
#        echo "$HOSTNAME : Domoticz at minute $MINUTE still OK!"
        curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "$HOSTNAME: Domoticz All OKAY!")" > /dev/null 2>&1
   exit
else
   sleep 10
   STATUS2=`curl -s --connect-timeout 2 --max-time 5 "Accept: application/json" "http://$DOMOTICZ_IP:$DOMOTICZ_PORT/json.htm?type=devices&rid=1" | grep "status"| awk -F: '{print $2}'|sed 's/,//'| sed 's/\"//g'`
   if [ $STATUS2] ; then
      exit
   else
      sleep 20
      STATUS3=`curl -s --connect-timeout 2 --max-time 5 "Accept: application/json" "http://$DOMOTICZ_IP:$DOMOTICZ_PORT/json.htm?type=devices&rid=1" | grep "status"| awk -F: '{print $2}'|sed 's/,//'| sed 's/\"//g'`
      if [ $STATUS3 ] ; then
         exit
      else
         NOW=$(date +"%Y-%m-%d_%H%M%S")
         sudo service domoticz.sh stop
         sleep 30
         sudo killall domoticz
         lsof -i tcp:${DOMOTICZ_PORT} | awk 'NR!=1 {print $2}' | xargs kill -9   # Added 19-09-20187 clear used ports 8080
         sudo service domoticz.sh start
         curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "$HOSTNAME: Domoticz Restarted!")" > /dev/null 2>&1
         logger -t "$dt, Domoticz was offline. Restarted Domoticz...."
      fi
   fi
fi
