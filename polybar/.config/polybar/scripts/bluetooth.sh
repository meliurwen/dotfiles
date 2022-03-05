#!/bin/sh
# Usage: ./bluetooth.sh [--toggle]

set -e

# If the folder doesn't exist (kernel module not loaded) or it's empty, exit
if [ ! -d /sys/class/bluetooth ]; then
    exit 1
elif [ -z "$(ls -A /sys/class/bluetooth)" ]; then
    exit 1
else
    :
fi

case $1 in
    "")
        bt_color=""
        if bluetoothctl show | grep -q "Powered: no"; then
            bt_color="%{F#66ffffff}"
        elif bluetoothctl info | grep -q "Device"; then
            bt_color="%{F#2193ff}"
        else
            :
        fi
        printf "%s%s\n" "$bt_color" ""
    ;;
    "--toggle")
        if bluetoothctl show | grep -q "Powered: no"; then
            bluetoothctl power on
        else
            bluetoothctl power off
        fi
    ;;
    *)
        printf "Parameter not supported. Aborting...\n"
        exit 1
    ;;
esac
