#!/bin/sh

# Commands and env variables that are common at startup to all graphical
# interfaces launchers (all DM and xinitrc/startx) should go in ~/.xsessionrc .
# This file is only sourced on Debian and derivates, so here a rudimentary
# check to source it in case we're not on Debian or derivative distro.
if [ ! -f /etc/debian_version ]; then
    [ -f "$HOME/.xsessionrc" ] && . "$HOME/.xsessionrc"
fi

# Set i3 as default if no argument is passed
session=${1:-i3}

# Launch a known WM/DE, otherwise launch as a command
case $session in
    dwm        ) exec dwm;;
    i3|i3wm    ) exec i3;;
    bspwm      ) exec bspwm;;
    xfce|xfce4 ) exec startxfce4;;
    xmonad     ) exec xmonad;;
    *) exec $1;;
esac

