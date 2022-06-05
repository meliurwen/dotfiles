#!/bin/sh

set -e

# This file is used by xinit and its wrapper startx.
# Display managers like xdm doesn't use this file at all
#
# See: man startx
# Use this script with the following commands:
# startx
# startx <program_full_path>
# startx $HOME/.xinitrc i3
# xinit -- $DISPLAY -nolisten tcp vt$XDG_VTNR

if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

# NOTE: this stinks a bit, and everything works without this... BUT there are
#       some parameters set in this collection of scripts of which at the
#       moment I don't have the time (and the will) to grasp the secuirty
#       consequences of removing them.
# run all system xinitrc shell scripts.
#if [ -d /etc/X11/Xsession.d ]; then
#    SESSIONFILES=$(run-parts --list /etc/X11/Xsession.d)
#    if [ -n "$SESSIONFILES" ]; then
#        set +e
#        for SESSIONFILE in $SESSIONFILES; do
#            . "$SESSIONFILE"
#        done
#        set -e
#    fi
#fi

# Set the Numlock for X session
# TODO: define a way to set it locally
if [ -r /etc/default/numlockx ]; then
    . /etc/default/numlockx
fi
NUMLOCK="${NUMLOCK:-on}"
case "$NUMLOCK" in
    on|off|toggle|keep)
    ;;
    auto)
        # Yeah... I don't see why it shouldn't be on.
        NUMLOCK=on
    ;;
    *)
        println "Warning: incorrect value assigned to NUMLOCK variable!"
        NUMLOCK=off
    ;;
esac
if command -v numlockx && [ "$NUMLOCK" != "keep" ]; then
    numlockx "$NUMLOCK"
fi

# To avoid very solw startup of many GTK apps
# https://dbus.freedesktop.org/doc/dbus-update-activation-environment.1.html
if [ -x "/usr/bin/dbus-update-activation-environment" ]; then
  # tell dbus-daemon --session (and systemd --user, if running)
  # to put a minimal subset of the Xsession's environment in activated
  # services' environments
  dbus-update-activation-environment --systemd \
    DISPLAY
#    DBUS_SESSION_BUS_ADDRESS \
#    XAUTHORITY
fi

# invoke local X session script
. "$HOME/.xsession"
