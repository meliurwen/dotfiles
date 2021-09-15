#!/bin/sh

# You can call this script like this:
# $ ./volumeControl.sh audio up
# $ ./volumeControl.sh audio down
# $ ./volumeControl.sh audio mute
# $ ./volumeControl.sh mic mute
# $ ./volumeControl.sh brightness up
# $ ./volumeControl.sh brightness down

# Acknowledgements:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

get_volume() {
  amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1
}

is_mute() {
  amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null
}

is_mic_mute() {
  amixer get Capture | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null
}

get_brightness() {
  max_bright=$(cat /sys/class/backlight/intel_backlight/max_brightness)
  act_bright=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
  echo $(( (act_bright*100+(max_bright/2))/max_bright ))
}

get_level_icon() {
  if [ "$1" -le 0 ] ; then
    printf %s "$2-none-dark"
  elif [ "$1" -le 30 ] ; then
    printf %s "$2-low-dark"
  elif [ "$1" -le 85 ] ; then
    printf %s "$2-medium-dark"
  elif [ "$1" -le 100 ] ; then
    printf %s "$2-high-dark"
  else
    printf %s "$2-overamplified-dark"
  fi
}

draw_bar() {
  percentual=$1
  slices=$2
  lvl=$((percentual / slices))
  empty_lvl=$(((100 / slices) - lvl))
  n=0
  lvl_bar=""
  while [ $n -lt $lvl ]; do
    lvl_bar="$lvl_bar"█
    n=$((n + 1))
  done
  n=0
  while [ $n -lt $empty_lvl ]; do
    lvl_bar="$lvl_bar"░
    n=$((n + 1))
  done
  printf "%s" "$lvl_bar"
}

send_notification() {
  if [ "$1" = "audio" ] ; then
    replace_id=2593
    if is_mute ; then
      notif_icon="audio-volume-muted-dark"
      notif_text="Audio Muted"
    else
      level=$(get_volume)
      notif_icon=$(get_level_icon "$level" "audio-volume")
      notif_text="$(draw_bar "$level" 5)"
    fi
  elif [ "$1" = "mic" ]; then
    replace_id=2594
    if is_mic_mute ; then
      notif_icon="microphone-sensitivity-muted"
      notif_text="Microphone Muted"
    else
      notif_icon="microphone-sensitivity-high"
      notif_text="Microphone On"
    fi
  elif [ "$1" = "brightness" ] ; then
    replace_id=2595
    if [ ! -d "/sys/class/backlight/intel_backlight/" ]; then
      notif_icon="display-brightness-disabled-dark"
      notif_text="Backlight Disabled"
    else
      level="$(get_brightness)"
      notif_icon=$(get_level_icon "$level" "display-brightness")
      notif_text="$(draw_bar "$level" 5)"
    fi
  else
    replace_id=2590
    notif_icon="dialog-error"
    notif_text="Script-error: option not found"
  fi
  # Send the notification
  dunstify -i $notif_icon -r $replace_id -u normal "$notif_text"
}

# set the volume on (if it was muted)
# and then up/down the volume of the 5%
set_audio() {
  case $1 in
    up)
      amixer -D pulse set Master on > /dev/null
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
}

# increase/decrease the backlight by 5%
set_brightness() {
  case $1 in
    up)
      brightnessctl s +5%
      send_notification brightness
      ;;
    down)
      brightnessctl s 5%-
      send_notification brightness
      ;;
  esac
}

set_mic() {
  case $1 in
    mute)
      # toggle microphone mute
      amixer -D pulse set Capture toggle > /dev/null
      send_notification mic
      ;;
  esac
}

case $1 in
  audio)
    set_audio "$2"
    ;;
  brightness)
    set_brightness "$2"
    ;;
  mic)
    set_mic "$2"
    ;;
esac
