#!/bin/sh
# Usage: ./netinfo.sh [--color [screen]]

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

wifi_str() {
    wifi_signal="$(cat < /proc/net/wireless | grep "$1" | awk '{print $3}' | tr -d '.')"
    bar=""
    case $wifi_signal in
        [0-1][0-9])
          color=${colred}
          bar="▂___"
        ;;
        [2-3][0-9])
          color=${colyellow}
          bar="▂▄__"
        ;;
        [4-5][0-9])
          color=${colgreen}
          bar="▂▄▆_"
        ;;
        [6-7][0-9])
          color=${colgreen}
          bar="▂▄▆█"
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

  [ "$(echo "$NET_IFACE" | cut -d ',' -f2)" = "DOWN" ] && continue

  device="$(echo "$NET_IFACE" | cut -d ',' -f1)"
  case $device in
    wlp*)
      [ $multi_ifce = 1 ] && STR_OUT="$STR_OUT|" || multi_ifce="1"
      STR_OUT="$STR_OUT$(wifi_str "$device")"
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
