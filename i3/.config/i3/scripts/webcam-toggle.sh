#!/bin/sh

pkill -f /dev/video || \
    mpv --title="mpv-floating-window" \
        --no-config \
        --no-osc \
        --no-input-default-bindings \
        --input-conf=/dev/null \
        -vo=gpu \
        --geometry=-0-0 \
        --autofit=30%  \
        av://v4l2:/dev/video0
