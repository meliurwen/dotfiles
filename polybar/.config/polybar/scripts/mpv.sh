#!/bin/sh

# Note: In order to use this script you have to tell to mpv to enable a socket.
#       Two ways are possible to achieve this:
#       1) Use the argument --input-ipc-server when you launch it. For example:
#          `mpv --input-ipc-server=~/.cache/mpvsocket Your.Video.File.mkv`
#       2) Add the line below when in the `mpv.conf` file:
#          `input-ipc-server=~/.cache/mpvsocket`

time_to_human(){
    if [ "$API_OUTPUT" -gt 3600 ]; then
        API_OUTPUT=$(printf '%d:%02d:%02d' $((API_OUTPUT/3600)) $((API_OUTPUT%3600/60)) $((API_OUTPUT%60)))
    else
        if [ "$API_OUTPUT" -gt 60 ]; then
            API_OUTPUT=$(printf '%02d:%02d' $((API_OUTPUT%3600/60)) $((API_OUTPUT%60)))
        else
            API_OUTPUT=$(printf '%02d' $((API_OUTPUT%60)))
        fi
    fi
}

MPV_SOCKET_PATH="$HOME/.cache/mpvsocket"

OUTPUT=""

if pgrep -u "$(id -u)" -x mpv > /dev/null; then

    # The "16) Connection refused" error happens at the row below
    # See: https://github.com/deterenkelt/Nadeshiko/wiki/Known-issues-for-Nadeshiko%E2%80%91mpv#----connection-refused
    if ! TIME="$(echo '{ "command": ["get_property", "time-pos"] }' | socat - "$MPV_SOCKET_PATH" 2> /dev/null)"; then
        exit 1
    fi
    if [ "$(echo "$TIME" | jq -r .error)" = "success" ]; then
        while [ $# -gt 0 ]; do
            COMMAND=$1
            VALID_COMMAND=true
            case $COMMAND in
                "time-pos" | "time-remaining" | "duration" | "media-title" | "playlist-pos" | "playlist-pos-1" | "playlist-count")
                    API_OUTPUT=$(echo "{ \"command\": [\"get_property\", \"$COMMAND\"] }" | socat - "$MPV_SOCKET_PATH")
                    ;;
                "core-idle" | "play-pause-btn")
                    API_OUTPUT=$(echo '{ "command": ["get_property", "core-idle"] }' | socat - "$MPV_SOCKET_PATH")
                    ;;
                *)
                    VALID_COMMAND=false
                    ;;
            esac

            if $VALID_COMMAND; then
                if [ "$(echo "$API_OUTPUT" | jq -r .error)" = "success" ]; then
                    case $COMMAND in
                        "time-pos" | "time-remaining" | "duration")
                            API_OUTPUT=$(echo "$API_OUTPUT" | jq -r .data | cut -d'.' -f 1)
                            time_to_human
                            ;;
                        "media-title")
                            API_OUTPUT=$(echo "$API_OUTPUT" | jq -r .data | cut -c 1-35)
                            ;;
                        "playlist-pos" | "playlist-pos-1" | "playlist-count")
                            API_OUTPUT=$(echo "$API_OUTPUT" | jq -r .data)
                            ;;
                        "core-idle" | "play-pause-btn")
                            shift;
                            if [ "$(echo "$API_OUTPUT" | jq -r .data)" = "false" ]; then
                                API_OUTPUT=$1 #Play icon
                                shift;
                            else
                                shift;
                                API_OUTPUT=$1 #Pause icon
                            fi
                            ;;
                    esac
                else
                    API_OUTPUT="API error!"
                fi
            else
                API_OUTPUT="$COMMAND"
            fi
            OUTPUT="$OUTPUT$API_OUTPUT"
            shift;
        done

    else
        OUTPUT="Loading..."
    fi
else
    exit
fi

printf %s "$OUTPUT"
