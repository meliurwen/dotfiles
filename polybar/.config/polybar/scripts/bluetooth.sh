#!/bin/sh
# Usage: ./bluetooth.sh [--toggle]

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
