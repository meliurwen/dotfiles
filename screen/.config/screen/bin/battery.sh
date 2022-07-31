#!/bin/sh

# Docs: https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-power

set -e

while [ $# -gt 0 ] ; do
    case "$1" in
        "--newline")
            newline=1
        ;;
        "--unit")
            unitsymbol="%"
        ;;
        "--icon")
            case $2 in
                "ascii"|""|"--"*)
                    case "$2" in
                        "--"*|"")
                            : # skip if it's a parameter or is empty
                        ;;
                        *)
                            shift
                        ;;
                    esac
                    iconize=1
                    iconbat0="[----]"
                    iconbat1="[#---]"
                    iconbat2="[##--]"
                    iconbat3="[###-]"
                    iconbat4="[####]"
                ;;
                "nerd")
                    shift
                    iconize=1
                    iconbat0=
                    iconbat1=
                    iconbat2=
                    iconbat3=
                    iconbat4=
                ;;
                *)
                    printf "Icon coding not supported. Aborting...\n"
                    exit 1
                ;;
            esac
        ;;
        "--color")
            case $2 in
                "screen")
                    shift
                    colorize=1
                    colgreen="\005{g}"
                    colyellow="\005{y}"
                    colred="\005{r}"
                    colred_blink="\005{+B r}"
                    colend="\005{-}"
                ;;
                "lemonbar")
                    shift
                    colorize=1
                    # xterm ANSI color palette
                    colgreen="%{F#00CD00}"
                    colyellow="%{F#CDCD00}"
                    colred="%{F#CD0000}"
                    colred_blink="%{F#000000}%{B#CD0000}" # no blinking available :(
                    colend="%{F-}"
                    colbgend="%{B-}"
                ;;
                "ansi"|""|"--"*)
                    case "$2" in
                        "--"*|"")
                            : # skip if it's a parameter or is empty
                        ;;
                        *)
                            shift
                        ;;
                    esac
                    colorize=1
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
        ;;
        "--symbols")
            case $2 in
                "ascii"|""|"--"*)
                    case "$2" in
                        "--"*|"")
                            : # skip if it's a parameter or is empty
                        ;;
                        *)
                            shift
                        ;;
                    esac
                    symdischarging="-"
                    symcharging="+"
                    symnotcharging="~"
                    symunknown="?"
                    symundetermined="/"
                ;;
                "ascii-alt")
                    shift
                    symdischarging="▼"
                    symcharging="▲"
                    symnotcharging="~"
                    symunknown="?"
                    symundetermined="/"
                ;;
                *)
                    printf "Charset not available. Aborting...\n"
                    exit 1
                ;;
            esac
        ;;
        *)
            printf "Parameter not recognized. Aborting...\n"
            exit 1
        ;;
    esac
    shift
done

pwr_lvl=""
status=""
multi_bat=0

supply_paths=/sys/class/power_supply/*/

for folder in $supply_paths; do
    [ -r "$folder/type" ] && [ "$(cat "$folder/type")" = "Battery" ] || continue
    [ -r "$folder/capacity" ] || continue
    [ -r "$folder/status" ] || continue
    pwr_lvl="$(cat "$folder/capacity")"
    pwr_stat="$(cat "$folder/status")"
    case "$pwr_stat" in
        "Discharging")
            status="$symdischarging"
        ;;
        "Charging")
            status="$symcharging"
        ;;
        "Not charging"|"Full")
            status="$symnotcharging"
        ;;
        "Unknown")
            status="$symunknown"
        ;;
        *)
            status="$symundetermined"
        ;;
    esac
    if [ "$colorize" = 1 ] || [ "$iconize" = 1 ]; then
        if [ "$pwr_lvl" -le 5 ]; then
            color="${colred_blink}"
            icon="${iconbat0}"
        elif [ "$pwr_lvl" -le 15 ]; then
            color="${colred}"
            icon="${iconbat0}"
        elif [ "$pwr_lvl" -le 35 ]; then
            color="${colyellow}"
            icon="${iconbat1}"
        elif [ "$pwr_lvl" -le 65 ]; then
            color="${colgreen}"
            icon="${iconbat2}"
        elif [ "$pwr_lvl" -le 97 ]; then
            color="${colgreen}"
            icon="${iconbat3}"
        else
            color="${colgreen}"
            icon="${iconbat4}"
        fi
    fi
    [ "$colend" = "%{F-}" ] && [ "$unitsymbol" = "%" ] && colend="%%{F-}"
    if [ $multi_bat = 1 ]; then
        sep="|"
    else
        sep=""
        multi_bat=1
    fi
    printf "%b%s%s%s%s%b%s" "${color}" "${icon}" "${status}" "${pwr_lvl}" "${unitsymbol}" "${colend}${colbgend}" "${sep}"
done

[ "$newline" = 1 ] && printf "\n" || :
