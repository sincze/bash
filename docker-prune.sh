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
## @link     https://github.com/sincze/bash                                                               ##
##                                                                                                        ##
## Version   1.0 - 31-05-2025                                                                             ##
##                                                                                                        ##
## Sometimes Diskpace Runs out mainly do to OLD docker images.                                            ##
## This script checks and removes unused images to reclaim diskspace.                                     ##
## It sends a Telegram message with the result.                                                           ##
##                                                                                                        ##
## usage:    Download the script and save it in a directory                                               ##
##           sudo chmod +x docker-prune.sh                                                                ##
##                                                                                                        ##
##           sudo nano /etc/crontab                                                                       ##
##           0 7 1 * *    root    /usr/bin/nice -n20 /home/pi/scripts/docker-prune.sh  > /dev/null 2>&1   ##
############################################################################################################

logPath="/var/log"
logFile="$logPath/docker-prune.log"
host=$(hostname)
now=$(date '+%Y-%m-%d %H:%M:%S')

# Load secrets/config
source /home/pi/domoticz/scripts/system/config

# Begin log entry
echo "[$now] Starting Docker cleanup on $host..." | tee -a "$logFile"
logger -t script "Docker cleanup started on $host"

# Run prune and capture output
pruneOutput=$(docker system prune -af --volumes)
echo "$pruneOutput" | tee -a "$logFile"

# Determine if anything was removed
if [[ "$pruneOutput" == *"Total reclaimed space:"* ]]; then
    reclaimed=$(echo "$pruneOutput" | grep "Total reclaimed space:" | cut -d: -f2 | xargs)

    # Send Telegram message
    curl -s -X POST "$TELEGRAM_URL" \
        -d chat_id="$TELEGRAM_ID" \
        -d text="$(echo -e "$host: Docker cleanup complete. Reclaimed: $reclaimed")" > /dev/null 2>&1

    logger -t script "Docker cleanup completed on $host – reclaimed $reclaimed"
else
    logger -t script "Docker cleanup completed on $host – nothing to reclaim"
fi

echo "[$now] Docker cleanup complete." | tee -a "$logFile"
