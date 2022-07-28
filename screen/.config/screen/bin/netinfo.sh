#!/bin/sh
# Usage: ./netinfo.sh [--color [screen]]

while [ $# -gt 0 ] ; do
  case "$1" in
    "--newline")
      newline=1
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
          iconbar0="[----]"
          iconbar1="[#---]"
          iconbar2="[##--]"
          iconbar3="[###-]"
          iconbar4="[####]"
        ;;
        "ascii-alt")
          shift
          iconize=1
          iconbar0="____"
          iconbar1="▂___"
          iconbar2="▂▄__"
          iconbar3="▂▄▆_"
          iconbar4="▂▄▆█"
        ;;
        "nerd")
          shift
          iconize=1
          iconbar0=
          iconbar1=
          iconbar2=
          iconbar3=
          iconbar4=
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
    *)
      printf "Parameter not recognized. Aborting...\n"
      exit 1
    ;;
  esac
  shift
done

_wifi_str() {
    wifi_signal="$(cat < /proc/net/wireless | grep "$1" | awk '{print $3}' | tr -d '.')"
    bar=""
    case $wifi_signal in
        [0][0-9])
          color=${colred}
          bar="$iconbar0"
        ;;
        [1][0-9])
          color=${colred}
          bar="$iconbar1"
        ;;
        [2-3][0-9])
          color=${colyellow}
          bar="$iconbar2"
        ;;
        [4-5][0-9])
          color=${colgreen}
          bar="$iconbar3"
        ;;
        [6-7][0-9])
          color=${colgreen}
          bar="$iconbar4"
        ;;
        *)
          color=${colred_blink}
          bar="????"
        ;;
    esac
    printf "%b%s%b" "${color}" "${bar}" "${colend}"
}

IFACES="$(ip link show | awk '/^[0-9]+:/ {sub(/:/,"",$2); print $2","$9}')"

multi_ifce=0
for NET_IFACE in $IFACES ; do

  [ "$(printf "%s\n" "$NET_IFACE" | cut -d ',' -f2)" = "DOWN" ] && continue

  device="$(echo "$NET_IFACE" | cut -d ',' -f1)"
  case $device in
    wlp*)
      [ $multi_ifce = 1 ] && STR_OUT="$STR_OUT|" || multi_ifce="1"
      STR_OUT="$STR_OUT$(_wifi_str "$device")"
      ;;
    enp*)
      [ $multi_ifce = 1 ] && STR_OUT="$STR_OUT|" || multi_ifce="1"
      STR_OUT="$STR_OUT$device"
      ;;
    usb*)
      [ $multi_ifce = 1 ] && STR_OUT="$STR_OUT|" || multi_ifce="1"
      STR_OUT="$STR_OUT$device"
      ;;
  esac
done

printf "%s" "${STR_OUT}"

[ "$newline" = 1 ] && printf "\n" || :
