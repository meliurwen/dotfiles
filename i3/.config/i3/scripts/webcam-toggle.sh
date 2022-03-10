#!/bin/sh

CAMERA=${CAMERA:-/dev/video0}

pkill -f "$CAMERA" || \
    mpv --title="mpv-floating-window" \
        --no-config \
        --no-osc \
        --no-input-default-bindings \
        --input-conf=/dev/null \
        --vo=gpu \
        --geometry=-0-0 \
        --autofit=30%  \
        --profile=low-latency \
        --untimed \
        --demuxer-lavf-format=video4linux2 \
        --demuxer-lavf-o-set=input_format=mjpeg \
        --demuxer-lavf-o=video_size=320x240\
        "$CAMERA"
