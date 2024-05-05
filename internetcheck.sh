#!/bin/bash
##################################################################
# A Project of TNET Services, Inc
#
# Title:     Internet_Check
# Author:    Original Idea: Kevin Reed (Dweeber)
#            dweeber.dweebs@gmail.com
# Modified:  S.Incze
# Project:   Raspberry Pi Stuff
#
# Copyright: Copyright (c) 2012 Kevin Reed <kreed@tnet.com>
#            https://github.com/dweeber/WiFi_Check
#
# Purpose:
#
# Script checks to see if Internet is available
#
# Uses a lock file which prevents the script from running more
# than one at a time.  If lockfile is old, it removes it
#
# Instructions:
#
# o Install where you want to run it from like /usr/local/bin
# o chmod 0755 /usr/local/bin/internetcheck.sh
# o Add to crontab
#
# Run Every 5 mins - Seems like ever min is over kill unless
# this is a very common problem.  If once a min change */5 to *
# once every 2 mins */5 to */2 ...
#
# */5 * * * * /usr/local/bin/internetcheck.sh
#
##################################################################
# Settings
# Where and what you want to call the Lockfile
lockfile='/var/run/WiFi_Internet_Check.pid'
# Which Interface do you want to check/fix
wlan='wlan0'
##################################################################
# -------------------
source /home/pi/domoticz/scripts/system/config
# -------------------

echo
echo "Starting Internet check for $wlan"
date
echo

# Check to see if there is a lock file
if [ -e $lockfile ]; then
    # A lockfile exists... Lets check to see if it is still valid
    pid=`cat $lockfile`
    if kill -0 &>1 > /dev/null $pid; then
        # Still Valid... lets let it be...
        #echo "Process still running, Lockfile valid"
        exit 1
    else
        # Old Lockfile, Remove it
        #echo "Old lockfile, Removing Lockfile"
        rm $lockfile
    fi
fi
# If we get here, set a lock file using our current PID#
#echo "Setting Lockfile"
echo $$ > $lockfile

# We can perform check
echo "Performing Internet Network check for $wlan"

/bin/wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "Internet connection OKAY!"
    logger "$HOSTNAME: WIFI INTERNET check -- Internet Online...."
else
    echo "Internet connection down! Attempting reconnection."
    logger "$HOSTNAME: WIFI INTERNET check -- Internet offline...."
fi

# Check is complete, Remove Lock file and exit
#echo "process is complete, removing lockfile"
rm $lockfile

exit 0

##################################################################
# End of Script
##################################################################
