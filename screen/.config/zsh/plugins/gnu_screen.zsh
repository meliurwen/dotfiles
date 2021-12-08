#!/bin/zsh

# If the terminal is `screen` set a proper title and hardstatus
# See: https://gist.github.com/rampion/143727
if [[ $TERM == "screen" || $TERM == "screen-256color" ]]; then
    function print_precmdexec() {
        local tilded_home="$(printf %s "$PWD" | sed "s|^$HOME|~|")"
        # set hardstatus of tab window (%h) for screen
        printf '\e]0;%s\a' "[$tilded_home]:$1"
        # set the tab window title (%t) for screen
        printf '\ek%s\e\\' "$2"
    }
    # called by zsh before executing a command
    function preexec() {
        local cmd=(${(z)1}) # the command string
        print_precmdexec "$cmd" "$cmd[1]:t"
    }
    # called by zsh before showing the prompt
    function precmd() {
        print_precmdexec "$SHELL:t" "$SHELL:t"
    }
fi
