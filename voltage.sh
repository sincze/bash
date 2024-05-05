#!/bin/bash
# Script to monitor the volage of your Raspberry Pi and store value in virtual voltage sendor in Domoticz.
# Created By: Sándor Incze
# Version 1.0 (05-05-2024)
#
# The file should be located here: /home/pi/domoticz/scripts/system/voltage.sh
# Execute the following commands after downloading in /home/pi/domoticz/scripts/system/ directory:
# $ chmod +x voltage.sh
# o Add to crontab (sudo nano /etc/crontab)
#
#
# * * * * * /usr/local/bin/voltage.sh
# -------------------
source /home/pi/domoticz/scripts/system/config
# -------------------

# Run the command and capture the output
output=$(vcgencmd measure_volts core)

# Check if there is output
if [ -n "$output" ]; then
    # Extract the voltage value using string manipulation
    voltage=$(echo "$output" | awk -F= '{print $2}')
    
    # Print the voltage value without trailing 'V'
    echo "${voltage%V}"
    
    # Push the voltage value to a web server using curl
     curl -s 'http://'$DOMOTICZ_IP':'$DOMOTICZ_PORT'/json.htm?type=command&param=udevice&idx='$PI_V'&nvalue=0&svalue='${voltage%V}''
     logger -t voltagecheck -- Current Voltage ${voltage%V}
else
    # Display an error message or log an error
    echo "Error: No output from vcgencmd measure_volts core" >&2
fi
