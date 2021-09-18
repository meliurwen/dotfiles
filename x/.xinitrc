#!/bin/sh

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
#       moment I don't have the time (and will) to grasp the secuirty
#       consequences of removing them.
# run all system xinitrc shell scripts.
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for i in /etc/X11/xinit/xinitrc.d/* ; do
        if [ -x "$i" ]; then
      . "$i"
        fi
    done
fi

# To avoid very solw startup of many GTK apps
# https://dbus.freedesktop.org/doc/dbus-update-activation-environment.1.html
#dbus-update-activation-environment --systemd DISPLAY

# invoke local X session script
. "$HOME/.xsession"
