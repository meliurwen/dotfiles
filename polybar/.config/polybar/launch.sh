#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar
#polybar main -c $HOME/.config/polybar/config &

# Set Monitors
#xrandr --output HDMI1 --auto --left-of LVDS1

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar main --reload -c $HOME/.config/polybar/config &
  done
else
  polybar main --reload -c $HOME/.config/polybar/config &
fi
