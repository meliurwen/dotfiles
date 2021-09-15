#!/usr/bin/env bash

# You can call this script like this:
# $ ./volumeControl.sh up
# $ ./volumeControl.sh down
# $ ./volumeControl.sh mute
# $ ./volumeControl.sh mic

# Script modified from these wonderful people:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

function get_volume {
  amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1
}

function is_mute {
  amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null
}

function is_mic_mute {
  amixer get Capture | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null
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
  if [ $1 == "audio" ] ; then
    replace_id=2593
    if is_mute ; then
      notif_icon="audio-volume-muted-dark"
      notif_text="Audio Muted"
    else
      volume=$(get_volume)
      if [ $volume -le 0 ] ; then
        notif_icon="audio-volume-none-dark"
      elif [ $volume -le 30 ] ; then
        notif_icon="audio-volume-low-dark"
      elif [ $volume -le 85 ] ; then
        notif_icon="audio-volume-medium-dark"
      elif [ $volume -le 100 ] ; then
        notif_icon="audio-volume-high-dark"
      else
        notif_icon="audio-volume-overamplified-dark"
      fi
      notif_text="$(draw_bar $volume 5)"
    fi
  else
    replace_id=2594
    if is_mic_mute ; then
      notif_icon="microphone-sensitivity-muted"
      notif_text="Microphone Muted"
    else
      notif_icon="microphone-sensitivity-high"
      notif_text="Microphone On"
    fi
  fi
  # Send the notification
  dunstify -i $notif_icon -r $replace_id -u normal "$notif_text"
}

case $1 in
  up)
    # set the volume on (if it was muted)
    amixer -D pulse set Master on > /dev/null
    # up the volume (+ 5%)
    amixer -D pulse sset Master 5%+ > /dev/null
    send_notification audio
    ;;
  down)
    amixer -D pulse set Master on > /dev/null
    amixer -D pulse sset Master 5%- > /dev/null
    send_notification audio
    ;;
  mute)
    # toggle mute
    amixer -D pulse set Master 1+ toggle > /dev/null
    send_notification audio
    ;;
  mic)
    # toggle microphone mute
    amixer -D pulse set Capture toggle > /dev/null
    send_notification mic
    ;;
esac
