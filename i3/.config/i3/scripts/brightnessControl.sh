#!/usr/bin/env bash

# You can call this script like this:
# $ ./brightnessControl.sh up
# $ ./brightnessControl.sh down

# Script inspired by these wonderful people:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

function get_brightness {
  #xbacklight -get | cut -d '.' -f 1 # This seems to no longer work on Intel graphics
  max_bright=$(cat /sys/class/backlight/intel_backlight/max_brightness)
  act_bright=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
  # To round down/up/nearest in sh: https://stackoverflow.com/a/2395294
  # In this case we round to the nearest: (num + (denom / 2)) / denom
  echo $(( (act_bright*100+(max_bright/2))/max_bright ))
}

function draw_bar {
  percentual=$1
  slices=$2
  lvl=$((percentual / slices))
  empty=$(((100 / slices) - lvl))
  lvl_bar=""
  for X in $(seq "$lvl"); do
    lvl_bar="$lvl_bar$(printf '\u2588')"
  done
  empty_bar=""
  for X in $(seq "$empty"); do
    empty_bar="$empty_bar$(printf '\u2591')"
  done
  echo "$lvl_bar$empty_bar"
}

function send_notification {
  if [ ! -d "/sys/class/backlight/intel_backlight/" ]; then
    notif_icon="display-brightness-disabled-dark"
    notif_text="Disabled"
  else
    brightness=$(get_brightness)
    if [ $brightness -le 0 ] ; then
      notif_icon="display-brightness-none-dark"
    else
      if [ $brightness -le 30 ] ; then
        notif_icon="display-brightness-low-dark"
      else
        if [ $brightness -le 85 ] ; then
          notif_icon="display-brightness-medium-dark"
        else
          if [ $brightness -le 100 ] ; then
            notif_icon="display-brightness-high-dark"
          else
            notif_icon="display-brightness-overamplified-dark"
          fi
        fi
      fi
    fi
    notif_text=$(draw_bar $brightness 5)
  fi
  # Send the notification
  dunstify -i "$notif_icon" -r 5555 -u normal "$notif_text"
}

case $1 in
  up)
    # increase the backlight by 5%
    ##xbacklight -inc 5
    brightnessctl s +5%
    send_notification
    ;;
  down)
    # decrease the backlight by 5%
    ##xbacklight -dec 5
    brightnessctl s 5%-
    send_notification
    ;;
esac

# Note: Seems that `xbacklight` doesn't work without a proper DE under i3.
# `brightnessctl` seems an interesting alternative. :)
