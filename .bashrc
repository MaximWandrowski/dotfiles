################################################################################
#                                 ENVIRONMENT                                  # 
################################################################################

# personal binaries
export PATH=$PATH:$HOME/.local/bin

# standard editor is (neo)vim
export EDITOR=nvim

# fancy man-pages
export MANWIDTH=80
#export MANPAGER="sh -c 'col -bx | bat -p -lman'"
export BAT_THEME="Solarized (dark)"

################################### android ####################################

export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/build-tools 
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator

################################### python #####################################

# pyenv
export PATH=$HOME/.pyenv/bin:$PATH
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# include python virtual environments within project
export PIPENV_VENV_IN_PROJECT=1

# hide ugly python virtual environmnet prefix (handled in prompt_command)
export VIRTUAL_ENV_DISABLE_PROMPT=1

################################### node.js ####################################

export NVM_DIR="$HOME/.nvm"

# load nvm only when necessary
nvm() {
  # remove nvm function
  unset -f nvm
  # load nvm
  [ -r "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  # load bash_completion
  [ -r "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  # call nvm
  nvm "$@"
  # load bash completion for npm
  type npm &> /dev/null && source <(npm completion)
}


################################################################################
#                                    PROMPT                                    #
################################################################################

# only show 3 folders in prompt path
export PROMPT_DIRTRIM=3

# the function contained in PROMPT_COMMAND constructs PS1
export PROMPT_COMMAND='prompt_command'

prompt_command() {
  # preserve exit value
  local exit=$?

  # construct potential additions
  declare -A prompt
  # background jobs
  [ `jobs | wc -l` -gt 0 ] && prompt[job]=' \e[31;1mjobs:'`jobs | wc -l`'\e[0m'
  # ssh remote host
  [ -n "$SSH_TTY" ] && prompt[ssh]='\e[37;1m@\e[36;1m\h\e[0m'
  # node.js version
  [ -n "$NVM_BIN" ] && prompt[nvm]=' \e[35;1mnvm:'${NVM_BIN//@(*\/node\/|\/bin)/}'\e[0m'
  # python virtual environment
  [ -n "$VIRTUAL_ENV" ] && {
    prompt[pve]=' \e[35;1mpve:'`basename $VIRTUAL_ENV`'\e[0m'
  } || {
    unset prompt[pve]
  }
  # git status
  [ -r /usr/share/git/git-prompt.sh ] && {
    source /usr/share/git/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWSTASHSTATE=true
    export GIT_PS1_SHOWUPSTREAM="auto"
    #export GIT_PS1_SHOWCOLORHINTS=true
    #export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_STATESEPARATOR=":"
    #export GIT_PS1_DESCRIBE_STYLE="default"
    #export GIT_PS1_HIDE_IF_PWD_IGNORED=true
    prompt[git]=' \e[32;1m'`__git_ps1 "git:%s"`'\e[0m'
  }

  # construct PS1
  PS1='┌┤ \e[32;1m\u'${prompt[ssh]}' \e[37;1m\w\e[0m │'${prompt[job]}${prompt[pve]}${prompt[nvm]}${prompt[git]}'\n└▶ '

  # reset exit value
  return $exit
}

# secondary prompt
PS2='\e[1A│ \e[1B\e[2D└▶ '

# use vi key bindings
# remember, that for C-L to clear the screen in insert mode you have to add
#
#    "\C-L": clear-screen
#
# to your .inputrc
set -o vi

# colorized `ls'
eval `dircolors ~/.config/dircolors/config`

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

# start bc with the mathlib and personal augmentations
alias bc='bc -q -l ~/.config/bc/lib'

# use the urxvt client/server support (see EXIT STATUS in urxvtc(1))
alias urxvt='urxvtcd'

# ncmpc with color by default
alias ncmpc='ncmpc -c'

# load .tmux.conf from $XDG_CONFIG_HOME/tmux
alias tmux='tmux -f ~/.config/tmux/config'


################################################################################
#                                  COMPLETION                                  # 
################################################################################

##################################### git ###################################### 

[ -r /usr/share/git/completion/git-completion.bash ] && {
  source /usr/share/git/completion/git-completion.bash
}
# also for dotfiles alias
eval `complete -p git | sed 's/\w*$//'` dotfiles

################################## terraform ################################### 

[ -r /usr/bin/terraform ] && {
  complete -C /usr/bin/terraform terraform
}
