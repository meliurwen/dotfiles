#!/bin/sh

set -e

# If at least one polybar process is running send a SIGTERM to all:
# - Give a grace period of N cycles to all processes to terminate gracefully
# - When the grace period is expired, send a SIGKILL to all
cycle=0
while pgrep -u "$(id -u)" -x polybar >/dev/null
do
  if [ $cycle -eq 0 ]; then
    # Terminate already running bar instances
    pkill -U "$(id -u)" -15 polybar
  elif [ $cycle -eq 4 ]; then
    # At the 5th cylcle SIGKILL
    pkill -U "$(id -u)" -9 polybar
  fi
  sleep 1
  cycle=$((cycle + 1))
done
unset cycle

NET_IFACES="$(ip link show | awk '/^[0-9]+:/ {sub(/:/,"",$2); print $2}')"
for NET_IFACE in $NET_IFACES ; do
  case $NET_IFACE in
    wlp* ) POLY_WLP=$NET_IFACE ;;
    enp* ) POLY_ENP=$NET_IFACE ;;
  esac
done
unset NET_IFACES

HWMON_MODULE="/sys/devices/platform/coretemp.0/hwmon/"
if [ -d "$HWMON_MODULE" ]; then
  HWMON_BASEDIR="$(find "$HWMON_MODULE" -maxdepth 1 -type d -name 'hwmon*' | tail -n +2 | head -1)"
  POLY_HWMON="$HWMON_BASEDIR"/temp1_input
  unset HWMON_BASEDIR
fi
unset HWMON_MODULE

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    POLY_WLP=$POLY_WLP POLY_ENP=$POLY_ENP POLY_HWMON=$POLY_HWMON MONITOR=$m polybar main -c "$HOME/.config/polybar/config" &
  done
fi

unset POLY_WLP POLY_ENP POLY_HWMON
