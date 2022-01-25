#!/bin/bash

# Script to restart SSH with help of MONIT and report via Telegrambot.
# Created By: Sándor Incze
# Version 1.0 (25-01-2022)
#
# The file should be located here: /home/pi/domoticz/scripts/system/ssh.sh
# Execute the following commands after downloading in /home/pi/domoticz/scripts/system/ directory:
# $ chmod +x ssh.sh
#
# Prereq is that monit is installed:
# $ sudo apt-get install monit
# $ sudo nano /etc/monit/monitrc

# Contents of the file monitrc (remove all the #):
# ------------------------
# set daemon 120            # check services at 2-minute intervals
# set log /var/log/monit.log
# set pidfile /var/run/monit.pid
# set idfile /var/lib/monit/id
# set statefile /var/lib/monit/state
# set eventqueue
#     basedir /var/lib/monit/events 
#     slots 100                     
# set httpd port 2812 and
#    use address localhost  
#    allow localhost        
#    allow admin:monit      
# include /etc/monit/conf.d/*
# include /etc/monit/conf-enabled/*
# ------------------------
#
# A separate config file should be created to monitor ssh
# $ sudo nano /etc/monit/conf.d/sshd.conf

# Contents of the file sshd.conf (remove all the #):
# ------------------------
# check process sshd with pidfile /var/run/sshd.pid
# start program "/bin/bash -c /home/pi/domoticz/scripts/system/ssh.sh"
# stop program "/etc/init.d/ssh stop"
# if failed host 127.0.0.1 port 22 protocol ssh then restart
# ------------------------

# If all files are created:
# $ sudo monit -t (Should not give any errors)
# $ sudo monit reload
#
# From now on if Monit restarts SSH you will receive a telegram message

# -------------------
source /home/pi/domoticz/scripts/system/config
# -------------------

sudo /etc/init.d/ssh start
curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "$HOSTNAME: SSH Service Restarted!")" > /dev/null 2>&1
logger -t SSH check -- SSH was offline. Restarted SSH....
