#!/bin/sh
# Usage: ./battery.sh [--color [screen]]

if [ "$1" = "--color" ]; then
    case $2 in
        "screen")
            colgreen="\005{g}"
            colyellow="\005{y}"
            colred="\005{r}"
            colred_blink="\005{+B r}"
            colend="\005{-}"
        ;;
        "")
            colgreen="\033[0;32m"
            colyellow="\033[0;33m"
            colred="\033[0;31m"
            colred_blink="\033[5;31m"
            colend="\033[0m"
        ;;
        *)
            printf "Color coding not supported. Aborting...\n"
            exit 1
        ;;
    esac
fi

pwr_lvl=""
status=""
multi_bat=0
for folder in /sys/class/power_supply/BAT?/; do
    pwr_lvl="$(cat "$folder/capacity")"
    pwr_stat="$(cat "$folder/status")"
    if [ "$pwr_stat" = "Discharging" ]; then
        status="%▼"
    elif [ "$pwr_stat" = "Charging" ]; then
        status="%▲"
    elif [ "$pwr_stat" = "Not charging" ]; then
        status="%~"
    elif [ "$pwr_stat" = "Unknown" ]; then
        status="%?"
    else
        status="%/"
    fi
    if [ "$1" = "--color" ]; then
        # if:
        #   - <= 5 blinking red text
        #   - <= 10 red text
        #   - <= 20 yellow text
        #   - > 20 green
        if [ "$pwr_lvl" -le 8 ]; then
            color="${colred_blink}"
        elif [ "$pwr_lvl" -le 20 ]; then
            color="${colred}"
        elif [ "$pwr_lvl" -le 40 ]; then
            color="${colyellow}"
        else
            color="${colgreen}"
        fi
    fi
    if [ $multi_bat = 1 ]; then
        sep="|"
    else
        sep=""
        multi_bat=1
    fi
    printf "%b%s%s%b%s" "${color}" "${pwr_lvl}" "${status}" "${colend}" "${sep}"
done
