#!/bin/bash

# Script to report SSH logins using Telegrambot.
# Modified By: Sándor Incze
# Version 1.0 (24-01-2022)
# Version 1.1 (25-01-2022) included a config file
#
# The file should be located here: /usr/local/bin/notify-on-ssh-login.sh
# Execute the following commands after downloading in /usr/local/bin/ directory:
# $ chmod +x notify-on-ssh-login.sh
#
# $ sudo nano /etc/pam.d/sshd
# Add the following as last line: session optional pam_exec.so /usr/local/bin/notify-on-ssh-login.sh
#
# Now every SSH login will trigger a message via Telegram

# CONFIG File
source /home/pi/domoticz/scripts/system/config

if [ "$PAM_TYPE" != "open_session" ]
then
        exit 0
else
        curl -s -X POST $TELEGRAM_URL -d chat_id=$TELEGRAM_ID -d text="$(echo -e "Host: `hostname`\nUser: $PAM_USER\nHost: $PAM_RHOST")" > /dev/null 2>&1
        exit 0
fi
