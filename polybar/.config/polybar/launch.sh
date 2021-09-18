#!/bin/sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u "$(id -u)" -x polybar >/dev/null; do sleep 1; done

# Launch polybar
#polybar main -c $HOME/.config/polybar/config &

# Set Monitors
#xrandr --output HDMI1 --auto --left-of LVDS1

POLY_IFACES="$(ip link show | awk '/^[0-9]+:/ {sub(/:/,"",$2); print $2}')"

for NET_IFACE in $POLY_IFACES ; do
  echo "$NET_IFACE"
  case $NET_IFACE in
    wlp* ) POLY_WLP=$NET_IFACE ;;
    enp* ) POLY_ENP=$NET_IFACE ;;
  esac
done

HWMON_BASEDIR="$(find "/sys/devices/platform/coretemp.0/hwmon/" -maxdepth 1 -type d -name 'hwmon*' | tail -n +2 | head -1)"
POLY_HWMON="$HWMON_BASEDIR"/temp1_input

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    POLY_WLP=$POLY_WLP POLY_ENP=$POLY_ENP POLY_HWMON=$POLY_HWMON MONITOR=$m polybar main --reload -c "$HOME/.config/polybar/config" &
  done
else
  polybar main --reload -c "$HOME/.config/polybar/config" &
fi
