#!/bin/sh

# ~/.profile: executed by the command interpreter for login shells.
#
# This file is not read by bash, if ~/.bash_profile or ~/.bash_login exists.
#
# The default umask is set in /etc/profile; for setting the umask for ssh
# logins, install and configure the libpam-umask package.
#umask 022

# Set font for console tty
# Source: https://github.com/powerline/fonts/tree/master/Terminus/PSF
if [ "$TERM" = "linux" ]; then
    CONSOLE_FONTD=$HOME/.local/share/consolefonts
    CONSOLE_FONT=ter-powerline-v12n.psf.gz
    if [ -f "$CONSOLE_FONTD/$CONSOLE_FONT" ]; then
        setfont "$CONSOLE_FONTD/$CONSOLE_FONT"
    fi
fi
