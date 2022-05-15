#!/bin/sh

# Dependencies: mpv jq socat
# Note: In order to use this script you have to tell to mpv to enable a socket.
#       Two ways are possible to achieve this:
#       1) Use the argument --input-ipc-server when you launch it. For example:
#          `mpv --input-ipc-server=mpvsocket Your.Video.File.mkv`
#       2) Add the line below when in the `mpv.conf` file:
#          `input-ipc-server=mpvsocket`

time_to_human(){
  seconds=$1
  if [ "$seconds" -gt 3600 ]; then
    printf '%d:%02d:%02d' $((seconds/3600)) $((seconds%3600/60)) $((seconds%60))
  elif [ "$seconds" -gt 60 ]; then
    printf '%02d:%02d' $((seconds%3600/60)) $((seconds%60))
  else
    printf '%02d' $((seconds%60))
  fi
}

if ! pgrep -u "$(id -u)" -x mpv > /dev/null; then
  exit 1
fi

MPV_SOCKET_PATH="${XDG_RUNTIME_DIR:-/tmp/$(id -u)-runtime}/mpv/main.sock"

OUTPUT=""

# The "16) Connection refused" error happens at the row below
# See: https://github.com/deterenkelt/Nadeshiko/wiki/Known-issues-for-Nadeshiko%E2%80%91mpv#----connection-refused
if ! TIME="$(printf '{ "command": ["get_property", "time-pos"] }\n' | socat - "$MPV_SOCKET_PATH" 2> /dev/null)"; then
  exit 1
fi

if [ "$(printf "%s" "$TIME" | jq -r .error)" != "success" ]; then
  printf "Loading..."
  exit 0
fi

while [ $# -gt 0 ]; do
  COMMAND=$1
  case $COMMAND in
    "time-pos" | "time-remaining" | "duration" | "media-title" | "playlist-pos" | "playlist-pos-1" | "playlist-count" | "core-idle" | "play-pause-btn")
      if [ "$COMMAND" = "play-pause-btn" ]; then
      COMMAND="core-idle"
      fi
      API_OUTPUT=$(printf '{ "command": ["get_property", "%s"] }\n' "$COMMAND" | socat - "$MPV_SOCKET_PATH")
    ;;
    *)
      OUTPUT="$OUTPUT$COMMAND"
      shift
      continue
    ;;
  esac

  if [ "$(printf "%s" "$API_OUTPUT" | jq -r .error)" != "success" ]; then
    printf "API error!"
    exit 1
  fi
  JSON_DATA="$(printf "%s" "$API_OUTPUT" | jq -r .data)"
  case $COMMAND in
    "time-pos" | "time-remaining" | "duration")
      API_OUTPUT="$(time_to_human "$(printf "%s" "$JSON_DATA" | cut -d'.' -f 1)")"
    ;;
    "media-title")
      API_OUTPUT=$(printf "%s" "$JSON_DATA" | cut -c 1-35)
    ;;
    "playlist-pos" | "playlist-pos-1" | "playlist-count")
      API_OUTPUT="$JSON_DATA"
    ;;
    "core-idle")
      shift
      if [ "$JSON_DATA" = "false" ]; then
        API_OUTPUT=$1 #Play icon
        shift
      else
        shift
        API_OUTPUT=$1 #Pause icon
      fi
    ;;
  esac
  OUTPUT="$OUTPUT$API_OUTPUT"
  shift
done

printf "%s" "$OUTPUT"
