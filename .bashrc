################################################################################
#                                 ENVIRONMENT                                  #
################################################################################

# expand PATH to include user's private bin if not already present
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# standard editor is (neo)vim
export EDITOR=nvim

# readable man-pages
export MANWIDTH=80
export GROFF_NO_SGR=1

# colorful man-pages
export LESS_TERMCAP_mb=$'\e[1;34m'   # bold
export LESS_TERMCAP_md=$'\e[1;34m'   # blinking
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;33m'   # underline
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_so=$'\e[30;47m'   # standout (search / sections)
export LESS_TERMCAP_se=$'\e[0m'

# fix dircolors for Selenized
export LS_COLORS="$LS_COLORS:ow=1;7;34:st=30;44:su=30;41"

################################################################################
#                                                                              #
#                                   TOOLING                                    #
#                                                                              #
# Lazy-loading tooling always follows the same pattern: Create a function that #
# deletes itself and then loads completions and other initializations only if  #
# needed                                                                       #
#                                                                              #
# tool() {                                                                     #
#   # delete wrapper function                                                  #
#   unset -f tool                                                              #
#   # load completion and other bootstrapping                                  #
#   complete -C "$(call completion script)"                                    #
#   # call actual tool passing all arguments                                   #
#   tool "$@"                                                                  #
# }                                                                            #
#                                                                              #
################################################################################

##################################### aws ######################################

aws() {
  unset -f aws
  complete -C 'aws_completer' aws 2> /dev/null
  aws "$@"
}

################################ kubernernetes #################################

kubectl() {
  unset -f kubectl
  eval "$(kubectl completion bash 2> /dev/null)"
  kubectl "$@"
}

#################################### docker ####################################

docker() {
  unset -f docker
  eval "$(docker completion bash 2> /dev/null)"
  docker "$@"
}

##################################### java #####################################

jenv() {
  unset -f jenv
  [ -r "$HOME/.jenv/bin/jenv" ] && export PATH="$HOME/.jenv/bin:$PATH"
  [ -r "$HOME/.jenv/bin/jenv" ] && eval "$(jenv init -)"
  jenv "$@"
}

################################### python #####################################

export PYENV_ROOT="$HOME/.pyenv"
# hide ugly python virtual environmnet prefix (handled in prompt_command)
export VIRTUAL_ENV_DISABLE_PROMPT=1

pyenv() {
  unset -f pyenv
  [ -r "$PYENV_ROOT/bin/pyenv" ] && {
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  }
  pyenv "$@"
}

################################### node.js ####################################

export NVM_DIR="$HOME/.nvm"

nvm() {
  unset -f nvm
  [ -r "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -r "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  type npm &> /dev/null && source <(npm completion)
  nvm "$@"
}

################################################################################
#                                    PROMPT                                    #
################################################################################

# only show 2 folders in prompt path
export PROMPT_DIRTRIM=2

# the function contained in PROMPT_COMMAND constructs PS1
export PROMPT_COMMAND='prompt_command'

prompt_command() {
  # preserve exit value
  local exit=$?

  # construct potential additions
  declare -A prompt
  # ssh remote host
  [ -n "$SSH_TTY" ] && prompt[ssh]='\e[30m\u@\h' || { prompt[ssh]='\e[30m\u'; }
  # exit status of last command
  [ $exit -ne 0 ] && prompt[exit]='\e[1D\e[101m \e[30m✗ '$exit'\e[91;49m'
  # background jobs
  [ "$(jobs | wc -l)" -gt 0 ] && prompt[job]='\e[1D\e[103m \e[30m '$(jobs | wc -l | tr -d " \t")'\e[93;49m'
  # node.js version
  [ -n "$NVM_BIN" ] && prompt[nvm]='\e[1D\e[105m \e[30m󰎙 '${NVM_BIN//@(*\/node\/|\/bin)/}'\e[95;49m'
  # python via pyenv
  [ -n "$PYENV_VERSION" ] && {
    prompt[pyenv]='\e[1D\e[105m \e[30m '$PYENV_VERSION'\e[95;49m'
  }
  # java via jenv
  [ -n "$JENV_LOADED" ] && {
    local java_version=$(jenv version-name 2>/dev/null)
    [ "$java_version" != "system" ] && prompt[jenv]='\e[1D\e[105m \e[30m '$java_version'\e[95;49m'
  }
  # kubernetes context
  declare -F | grep -qe '-f kubectl' || {
    local kctx=$(kubectl config current-context 2>/dev/null)
    [ -n "$kctx" ] && prompt[kube]='\e[1D\e[106m \e[30m󰠳 '$kctx'\e[96;49m'
  }
  # docker context
  declare -F | grep -qe '-f docker' || {
    local dctx=$(docker context show 2>/dev/null)
    [ -n "$dctx" -a "$dctx" != "default" ] && prompt[docker]='\e[1D\e[106m \e[30m '$dctx'\e[96;49m'
  }
  # aws info
  [ -z "$AWS_ARN" -a -z "$(declare -F | grep -e '-f aws')" ] && {
    AWS_ARN=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null || echo "-")
  }
  [[ "$AWS_ARN" =~ ^(arn:[^:]+:[^:]+:[^:]*:[0-9]*:)?((assumed-role/([^/]+)_([^/]+)_([^/]+)/([^/]+))|(user/([^/]+)))$ ]] && {
    #               ╰───────────── 1 ─────────────╯ ││             ╰─ 4 ─╯ ╰─ 5 ─╯ ╰─ 6 ─╯ ╰─ 7 ─╯│ │     ╰─ 9 ─╯││
    # BASH_REMATCH indices                          │╰───────────────────── 3 ────────────────────╯ ╰───── 8 ────╯│
    #                                               ╰───────────────────────────── 2 ─────────────────────────────╯
    prompt[aws]="\e[1D\e[106m \e[30m󰅟 ${BASH_REMATCH[5]}${BASH_REMATCH[5]:+/}${BASH_REMATCH[7]}${BASH_REMATCH[8]}\e[96;49m"
  }
  # git status
  [[ "$(git status 2>/dev/null)" =~ ^((HEAD detached at)|(On branch))\ ([^[:space:]]+) ]] && {
    # BASH_REMATCH indices           │╰─────── 2 ──────╯ ╰─── 3 ───╯│  ╰───── 4 ─────╯
    #                                ╰────────────── 1 ─────────────╯
    prompt[git]="\e[1D\e[102m \e[30m${BASH_REMATCH[2]:+󰜛}${BASH_REMATCH[3]:+󰘬} ${BASH_REMATCH[4]}\e[92;49m"
  }

  # construct PS1
  PS1='\n\e[34m╭──\e[44m'${prompt[ssh]}'\e[34;47m \e[30m\w\e[37;49m'${prompt[jenv]}${prompt[pyenv]}${prompt[nvm]}${prompt[git]}${prompt[aws]}${prompt[docker]}${prompt[kube]}${prompt[job]}${prompt[exit]}'\n\e[34m│\e[0m  \n\[\e[34m\]╰─▶ \[\e[0m\]'

  # reset exit value
  return $exit
}

# secondary prompt
PS2='\[\e[1A\e[34m│ \e[37m▷\[\e[1B\e[3D\e[34m\]╰─▶ \[\e[0m\]'

################################### bindings ###################################

# select vi key bindings
set -o vi

# bind Ctrl-l to clear screen in vi mode
bind -m vi-insert "\C-l":clear-screen

################################################################################
#                                   ALIASES                                    #
################################################################################

# configuration management with bare repository
# https://news.ycombinator.com/item?id=11071754
# https://www.atlassian.com/git/tutorials/dotfiles
# https://www.youtube.com/watch?v=tBoLDpTWVOM
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# use nvim
alias vim='nvim'

# colorized ls
alias ls='ls --color=always'
alias ll='ls --color=always -lh'
alias la='ls --color=always -lhA'

# colorized `grep'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias fgrep='fgrep --color=always'

# `tree' with colors
alias tree='tree -C'

# accept colored pipe input
alias less='less -R'

# create parent directories on demand
alias mkdir='mkdir -pv'

# avoid deathbed regrets
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# fast folder climbing
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# start bc with the mathlib and personal augmentations
alias bc='bc -q -l ~/.config/bc/lib'

################################################################################
#                                   HELPERS                                    #
################################################################################

get_aws_creds() {
  [ -z "$1" ] && {
    read -p 'MFA Token Code: ' MFA_CODE
  }
  cat \
    <(sed -n '/\[mfa\]/q;p' "$HOME/.aws/credentials") \
    <(aws sts get-session-token --serial-number "$(aws configure get mfa_serial)" --token-code "${1:-$MFA_CODE}" \
      | jq -r '.Credentials | "[mfa]\naws_access_key_id = \(.AccessKeyId)\naws_secret_access_key = \(.SecretAccessKey)\naws_session_token = \(.SessionToken)\n"' \
      | sed 's/\\n/\n/g'
    ) | tee "$HOME/.aws/new_credentials"

  [ -s "$HOME/.aws/new_credentials" ] && {
    mv -i "$HOME/.aws/new_credentials" "$HOME/.aws/credentials"
  }
  export AWS_ARN=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
}

mkcd() {
  mkdir "$1" && cd "$1"
}

colortest() {
  echo
  # standard 16 colors
  for i in $(seq 0 15); do
    echo -en "\e[38;5;"$i"m██"
    [ "$(( (i + 1) % 8   ))" -eq 0 ] && echo
  done
  echo

  # grayscale ramp
  for i in $(seq 232 255); do
    echo -en "\e[38;5;"$i"m██"
    #[ "$(( (i - 231) % 4 ))" -eq 0 ] && echo
  done
  echo ; echo

  # 6x6x6 color cube
  for i in $(seq 16 231); do
    echo -en "\e[38;5;"$i"m██"
    [ "$(( (i - 15) % 36 ))" -eq 0 ] && echo
  done
}
