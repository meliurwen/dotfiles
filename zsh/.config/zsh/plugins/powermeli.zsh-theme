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

prompt_context() {
  if [ $(id -u) -eq 0 ]; then
    prompt_segment "$SEGMENT_SEPARATOR" black yellow
  else
    prompt_segment "$SEGMENT_SEPARATOR" black default
  fi
  if [ -z ${SSH_CLIENT+x} ]; then
    PROMPT_LINE="$PROMPT_LINE %n "
  else
    PROMPT_LINE="$PROMPT_LINE %n@%m "
  fi
}

prompt_git() {
  if [ "$ZSH_THEME_GIT_MODE" = "disabled" ]; then
    return
  fi
  if ! type git > /dev/null 2>&1; then
    return
  fi
  PL_BRANCH_CHAR="" # $'\ue0a0'

  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = "true" ]; then
    repo_path=$(git rev-parse --git-dir 2> /dev/null)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [ -n "$(git status --porcelain --ignore-submodules=dirty 2> /dev/null | tail -n 1)" ]; then
      prompt_segment "$SEGMENT_SEPARATOR" yellow black
    else
      prompt_segment "$SEGMENT_SEPARATOR" green black
    fi

    if [ -e "${repo_path}/BISECT_LOG" ]; then
      mode=" <B>"
    elif [ -e "${repo_path}/MERGE_HEAD" ]; then
      mode=" >M<"
    elif [ -e "${repo_path}/rebase" ] || [ -e "${repo_path}/rebase-apply" ] || [ -e "${repo_path}/rebase-merge" ] || [ -e "${repo_path}/../.dotest" ]; then
      mode=" >R>"
    fi

    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    PROMPT_LINE="$PROMPT_LINE${${ref:gs/%/%%}/refs\/heads\// $PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode} "
    unset repo_path ref mode
  fi
  unset PL_BRANCH_CHAR
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
  prompt_git
  PROMPT_LINE="$PROMPT_LINE%{%k%F{${OLD_BG:-blue}}%}$SEGMENT_SEPARATOR%{%f%}"
  unset OLD_BG OLD_SEP
  printf "%s%s " "%{%f%b%k%}" "$PROMPT_LINE"
  unset PROMPT_LINE
  unset -f prompt_segment prompt_status prompt_virtualenv prompt_context prompt_git
}

setopt prompt_subst
PROMPT='$(build_prompt)'
