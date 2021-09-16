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

if [ -f $HOME/.Xresources ]; then
    xrdb -merge $HOME/.Xresources
fi

# invoke local X session script
. $HOME/.xsession

