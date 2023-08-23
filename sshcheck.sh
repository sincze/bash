#!/bin/bash

############################################################################################################
##                                                                                                        ##
## BASH Scripting                                                                                         ##
##                                                                                                        ##
## @category Home_Automation                                                                              ##
## @link                                                                                                  ##
##                                                                                                        ##
## @author   Sándor Incze                                                                                 ##
## @license  GNU GPLv3                                                                                    ##
## @link     https://github.com/sincze/Domoticz                                                           ##
##                                                                                                        ##
## Sometimes the SSH service does not work anymore but I want to know that!                               ##
## As such this scripts checks the hosts (IP addresses from sshmachines) and reports on the SSH status.   ##
## If failed a Telegram message will notify me.                                                           ##
##                                                                                                        ##
## usage:    Download the script and save it in a directory                                               ##
##           sudo chmod +x sshcheck.sh                                                                    ##
##                                                                                                        ##
##           sudo nano /etc/crontab                                                                       ##
##           0 * * * *   root    /usr/bin/nice -n20 /home/pi/scripts/sshcheck.sh  > /dev/null 2>&1        ##
############################################################################################################

# CONFIG File
source /home/pi/domoticz/scripts/system/config

# Provide Path of the file sshmachines
path="/home/pi/domoticz/scripts/system/"
file=$path"sshmachines"

# Do NOT CHANGE BELOW HERE
for ssh_host in $(cat $file); do
  if nc -dvzw1 $ssh_host 22 2>/dev/null;
  then echo $ssh_host "Succeeded";
  else
     echo $ssh_host "failed"
     logger -t script sshcheck -- Statuscode $ssh_host is failed....
     curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "$ssh_host: Failed SSH connection!")" > /dev/null 2>&1
     exit 0
  fi
done
