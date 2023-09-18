#!/bin/sh

# ~/.profile: executed by the command interpreter for login shells.
#
# This file is not read by bash, if ~/.bash_profile or ~/.bash_login exists.
#
# The default umask is set in /etc/profile; for setting the umask for ssh
# logins, install and configure the libpam-umask package.
#umask 022

# If inside a TTY
if [ "$TERM" = "linux" ]; then
    # Set font for TTY
    # Source: https://github.com/powerline/fonts/tree/master/Terminus/PSF
    CONSOLE_FONTD=$HOME/.local/share/consolefonts
    CONSOLE_FONT=ter-powerline-v12n.psf.gz
    if [ -f "$CONSOLE_FONTD/$CONSOLE_FONT" ]; then
        setfont "$CONSOLE_FONTD/$CONSOLE_FONT"
    fi
   # Enable numlock for TTY
   if command -v setleds > /dev/null 2>&1; then
       setleds -D +num
   fi
fi

# Load locale.conf in XDG paths
# It is normally done by systemd but this is more agnostic
# Credits: Arch Linux folks!
if [ -n "$LANG" ]; then
    :
elif [ -r "${XDG_CONFIG_HOME:-$HOME/.config/locale.conf}" ]; then
    . "${XDG_CONFIG_HOME:-$HOME/.config/locale.conf}"
elif [ -r /etc/locale.conf ]; then
    . /etc/locale.conf
fi
LANG=${LANG:-C}
export LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY \
    LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT \
    LC_IDENTIFICATION
