#!/bin/sh
# Returns the temperature of the CPUs.
# The temperature is extracted from the package, if available, otherwise from
# the highest measurement of all cores for each CPU.
# See: https://www.kernel.org/doc/html/latest/hwmon/coretemp.html

set -e

while [ $# -gt 0 ] ; do
  case "$1" in
    "--newline")
      newline=1
    ;;
    "--unit")
      unitsymbol="°C"
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

multi_cpu=0

__colorize() {
  if [ "$1" -lt 75 ]; then
    color="$colgreen"
  elif [ "$1" -lt 80 ]; then
    color="$colyellow"
  elif [ "$1" -lt 85 ]; then
    color="$colred"
  else
    color="$colred_blink"
  fi
}

for cpu in /sys/devices/platform/coretemp.?; do
  [ -r "$cpu" ] || continue
  for cpu_hwmon in "$cpu"/hwmon/hwmon?; do
    is_package=0
    while read -r f_content; do
      case "$f_content" in
        "Package id "[0-9])
          is_package=1
        ;;
      esac
    done < "$cpu_hwmon/temp1_label"
    cpu_temp="-99"
    for core_temp_path in "$cpu_hwmon"/temp?_input; do
      while read -r f_content; do
        core_temp="${f_content%[0-9][0-9][0-9]}"
        [ "$core_temp" -gt $cpu_temp ] && cpu_temp="$core_temp"
      done < "$core_temp_path"
      [ $is_package = 1 ] && break
    done
    [ "$colorize" = 1 ] && __colorize "$cpu_temp"
    if [ $multi_cpu = 1 ]; then
      sep="|"
    else
      sep=""
      multi_cpu=1
    fi
    printf "%b%s%s%b%s" "$color" "$cpu_temp" "$unitsymbol" "$colend$colbgend" "$sep"
    # Only one hwmonX should be in hwmon, pick the first in case of multiple
    break
  done
done

[ "$newline" = 1 ] && printf "\n" || :
