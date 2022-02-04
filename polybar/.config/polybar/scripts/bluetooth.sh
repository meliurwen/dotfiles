#!/bin/sh
# Usage: ./bluetooth.sh [--toggle]

case $1 in
    "")
        if [ "$(bluetoothctl show | grep "Powered: yes" | wc -c)" -eq 0 ]; then
            printf "%s\n" "%{F#66ffffff}"
        elif [ "$(printf "%s\n" info | bluetoothctl | grep 'Device' | wc -c)" -eq 0 ]; then 
            printf "%s\n" ""
            printf "%s\n" "%{F#2193ff}"
        else
            printf "%s\n" "%{F#2193ff}"
        fi
    ;;
    "--toggle")
        if [ "$(bluetoothctl show | grep "Powered: yes" | wc -c)" -eq 0 ]; then
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
