#!/bin/bash

# Script to report SSH logins using Telegrambot.
# Modified By: Sándor Incze
# Version 1.0 (24-01-2022)
#
# The file should be located here: /usr/local/bin/notify-on-ssh-login.sh
# Execute the following commands after downloading in /usr/local/bin/ directory:
# $ chmod +x notify-on-ssh-login.sh
#
# $ sudo nano /etc/pam.d/sshd
# Add the following as last line: session optional pam_exec.so /usr/local/bin/notify-on-ssh-login.sh
#
# Now every SSH login will trigger a message via Telegram

TOKEN="<TELEGRAM BOT TOKEN>"
ID="<TELEGRAM GROUP ID>"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

if [ "$PAM_TYPE" != "open_session" ]
then
        exit 0
else
        curl -s -X POST $URL -d chat_id=$ID -d text="$(echo -e "Host: `hostname`\nUser: $PAM_USER\nHost: $PAM_RHOST")" > /dev/null 2>&1
        exit 0
fi
