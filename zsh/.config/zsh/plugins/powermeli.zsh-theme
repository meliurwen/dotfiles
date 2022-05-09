#!/bin/zsh
# Theme: powermeli
# Description: Complete rewrite of omz's Agnoster theme with no bloat
# Original:
# - https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/agnoster.zsh-theme
# Dependencies:
# - https://github.com/Lokaltog/powerline-fonts
# - git
# See:
# - https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# - https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#vcs_005finfo-Configuration
# - https://wiki.archlinux.org/title/zsh#Prompts

SEGMENT_SEPARATOR= # $'\ue0b0'

PROMPT_LINE=""

prompt_segment() {
  separator=""

  if [ -n "$OLD_SEP" ]; then
    separator="%F{$OLD_BG}$OLD_SEP"
  fi

  OLD_SEP=$1
  OLD_BG=$2
  PROMPT_LINE="$PROMPT_LINE%{%K{$2}%}$separator%{%F{$3}%}$4"
  unset separator
}

# Return the first ancestor PID of the PID of this process with the name issued
# From: https://unix.stackexchange.com/a/459007
# TODO: Consider reading from `/proc/<pid>/*` using only POSIX shell builtins
# Note: the `/proc` is not guaranteed to be on all unices (see BSD, Mac...)
# See:
# - https://stackoverflow.com/a/50457487
# - https://stackoverflow.com/a/1525673
get_apid() {
  ps -Ao pid= -o ppid= -o comm= |
    awk -v p="$$" -v ancestor="$1" '
      {
        pid = $1; ppid[pid] = $2
        sub(/([[:space:]]*[[:digit:]]+){2}[[:space:]]*/, "")
        name[pid] = $0
      }
      END {
        while (p) {
          if ( name[p] == ancestor ) {
            print p, name[p]
            exit
          }
          p = ppid[p]
        }
      }'
}

prompt_context() {
  if [ $(id -u) -eq 0 ]; then
    prompt_segment "$SEGMENT_SEPARATOR" black yellow
  else
    prompt_segment "$SEGMENT_SEPARATOR" black default
  fi
  # Check if inside an ssh session, also if using `sudo su`
  if [ -z ${SSH_CLIENT+x} ] && [ -z ${SSH_TTY+x} ] && [ -z "$(get_apid sshd)" ]; then
    PROMPT_LINE="$PROMPT_LINE %n "
  else
    PROMPT_LINE="$PROMPT_LINE %n%{%F{blue}%}@%{%F{cyan}%}%m "
  fi
}

prompt_git() {
  if ! command -pv git > /dev/null 2>&1; then
    return
  fi

  repo_path="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n "$repo_path" ]; then
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    git_status="$(git status --porcelain=v1 --ignore-submodules=dirty 2> /dev/null)"
    git_str=""
    if [ -n "$git_status" ]; then
      prompt_segment "$SEGMENT_SEPARATOR" yellow black
      # If sourced or executed by zsh overwrite with an associative array
      # https://zsh.sourceforge.io/Doc/Release/Parameters.html#Array-Parameters
      [ -z ${ZSH_VERSION+x} ] && set -A git_status ${(f)"${git_status}"}
      OLDIFS="$IFS"
      IFS="
"
      for line in $git_status; do
        git_states="${line%%"${line##[MTADRCU?! ][MTADRCU?! ]}"}"
        if [ -z ${git_staged+x} ] && [ -n "${git_states##["?""!"" "][MTADRCU?! ]}" ]; then
          git_staged="✚" # Staged
        fi
        if [ -z ${git_dirty+x} ] && [ -n "${git_states##[MTADRCU?! ]["!"" "]}" ]; then
          git_dirty="±" # Unstaged (Dirty tree)
        fi
        [ -z ${git_staged+x} ] || [ -z ${git_dirty+x} ] || break
      done
      IFS="$OLDIFS"
      git_str="$git_dirty$git_staged"
      unset git_states git_staged git_dirty OLDIFS
    else
      prompt_segment "$SEGMENT_SEPARATOR" green black
    fi

    if [ -e "${repo_path}/BISECT_LOG" ]; then
      git_str="$git_str <B>"
    elif [ -e "${repo_path}/MERGE_HEAD" ]; then
      git_str="$git_str >M<"
    elif [ -e "${repo_path}/rebase" ] || [ -e "${repo_path}/rebase-apply" ] || [ -e "${repo_path}/rebase-merge" ] || [ -e "${repo_path}/../.dotest" ]; then
      git_str="$git_str >R>"
    fi

    [ -n "$git_str" ] && git_str="$git_str "

    branch_char="" # $'\ue0a0'
    PROMPT_LINE="$PROMPT_LINE${${ref:gs/%/%%}/refs\/heads\// $branch_char } ${git_str}"

    unset ref git_status git_str branch_char
  fi
  unset repo_path
}

prompt_virtualenv() {
  if [ -n "$VIRTUAL_ENV" ] && [ -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]; then
    prompt_segment "$SEGMENT_SEPARATOR" blue black "(${VIRTUAL_ENV:t:gs/%/%%})"
  fi
}

prompt_status() {
  symbols=""

  [ $RETVAL -ne 0 ] && symbols="$symbols%{%F{red}%}✘" # last command exit code
  [ $(jobs -l | wc -l) -gt 0 ] && symbols="$symbols%{%F{cyan}%}⚙" # background jobs
  [ $(id -u) -eq 0 ] && symbols="$symbols%{%F{yellow}%}⚡" # root or not

  [ -n "$symbols" ] && prompt_segment "" black default " $symbols"
  unset symbols
}

build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_segment "$SEGMENT_SEPARATOR" blue black " %~ "
  [ "$ZSH_THEME_GIT_MODE" = "disabled" ] || prompt_git
  PROMPT_LINE="$PROMPT_LINE%{%k%F{${OLD_BG:-blue}}%}$SEGMENT_SEPARATOR%{%f%}"
  unset OLD_BG OLD_SEP
  printf "%s%s " "%{%f%b%k%}" "$PROMPT_LINE"
  unset PROMPT_LINE
  unset -f prompt_segment prompt_status prompt_virtualenv prompt_context prompt_git get_apid
}

setopt prompt_subst
PROMPT='$(build_prompt)'
