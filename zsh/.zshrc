#!/bin/zsh
# ~/.zshrc
# See:
# - https://zsh.sourceforge.io/Doc/Release/
# - https://stevenvanbael.com/profiling-zsh-startup

### History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=500000000
SAVEHIST=100000000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

## Aliases
# Common
[ -f "$HOME/.aliases" ] && . "$HOME/.aliases"
# ZSH only
alias history='history 1' # Print whole history

### Keybinds
# See:
# https://stackoverflow.com/a/21965133
# https://github.com/sorin-ionescu/prezto/pull/314
# https://vinipsmaker.wordpress.com/2014/02/23/my-zsh-config/
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh
# /etc/zsh/zshrc

# Use emacs key bindings
bindkey -e

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init() {
        echoti smkx
    }
    function zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish

    typeset -A key

    # List of keys
    key=(
        Up         "${terminfo[kcuu1]}"
        Down       "${terminfo[kcud1]}"
        PageUp     "${terminfo[kpp]}"
        PageDown   "${terminfo[knp]}"
    )
else
    # Fallback to manually managed user-driven database
    printf 'Failed to setup keys using terminfo (application mode unsuported).\n'
    # TODO: set zkbd mode
    # See: https://github.com/vinipsmaker/dotfiles/blob/master/config/.zshrc
fi

if [[ -n "${key[Up]}" ]] && [[ -n "${key[Down]}" ]]; then
    autoload -U up-line-or-beginning-search
    autoload -U down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search

    bindkey "${key[Up]}" up-line-or-beginning-search
    bindkey "${key[Down]}" down-line-or-beginning-search
fi
[[ -n "${key[PageUp]}" ]] && bindkey "${key[PageUp]}" up-line-or-history
[[ -n "${key[PageDown]}" ]] && bindkey "${key[PageDown]}" down-line-or-history


### Completion (dump)
# Note: This stuff probably has to be run before defining completion configs
# TODO: Check if the above note is true
# See:
# https://www.csse.uwa.edu.au/programming/linux/zsh-doc/zsh_23.html
# https://linux.die.net/man/1/zshcompsys

# Load all stock functions (from $fpath files) called below.
autoload -U compinit

# Save the location of the current completion dump file.
ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"
compinit -u -C -d "${ZSH_COMPDUMP}"


### Completion
zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

zsh_asugg_path="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh_shigh_path="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "${zsh_asugg_path}" ] && . "${zsh_asugg_path}"
[ -f "${zsh_shigh_path}" ] && . "${zsh_shigh_path}"
unset zsh_asugg_path zsh_shigh_path

### Addons
# Colored manpages
man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[45;93m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[4;93m") \
        man "$@"
}

# Colored `ls` command and colored dir and files suggestions
autoload -U colors && colors

if [[ "$DISABLE_LS_COLORS" != "true" ]]; then
    # For GNU ls, we use the default ls color theme.
    # They can later be overwritten by themes.
    if [[ -z "$LS_COLORS" ]]; then
        (( $+commands[dircolors] )) && eval "$(dircolors -b)"
    fi

    # Take advantage of $LS_COLORS for completion as well.
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# TODO: check what `multios` really does
# See: http://zsh.sourceforge.net/Doc/Release/Options.html
#setopt auto_cd
setopt multios


### Custom zsh-specific Functions
function zsh_stats() {
    fc -l 1 | \
        awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' | \
        grep -v "./" | sort -nr | head -20 | column -c3 -s " " -t | nl
}


## Theme
# This is ugly as hell, but is efficient and reliable
# TODO: find a clean, reliable and efficient solution to this mess
zsh_base_dir="$HOME/.config/zsh"

# Rudimentary plugin loader
# Note: the files are loaded in alphabetical order
# Notes about the `(xEXN)`:
# - `.` plain files, should be comparable to a `-f` in a `find`
# - `@` symbolic links
# - `x`, `E`, `X` are respectively executable for owner, group and world
# - the `N` is a nullglob applied for the current pattern
# - See: https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers
for plugin_f in "$zsh_base_dir/plugins/"*(.zsh|.zsh-theme)(xEXN); do
    source $plugin_f || printf "An error has occurred sourcing: %s\n" "$plugin_f"
done

#PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

unset zsh_base_dir
