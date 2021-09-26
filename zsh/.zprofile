#!/bin/zsh

if [ -f "$HOME/.profile" ]; then
    emulate sh
        . $HOME/.profile
    emulate zsh
fi

