# TODO: move this into profile and make profile smart enough to deal with it.
#       I can source profile from here then.
# MacPorts Installer addition on 2011-08-26_at_21:21:54: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Ensure GNU tools are used by default
export PATH=/opt/local/libexec/gnubin:$PATH
# put our bin folder in the path
export PATH="${PATH}:$HOME/bin"

# TODO: Fix colors once we are ready to switch.
PS1=$'%F{blue}[%T] [%j] %n@%m:%d\n%h $ %f'
PS2=$'%F{blue}> %f'
PS4=$'%F{blue}+%N:%i> %f'

# disable flow control (C-s, C-r)
stty -ixon

# don't echo control characters (in particular don't echo ^C on the command line).
stty -ctlecho

# tab completion
autoload -U compinit && compinit

# allow me to use arrow keys to select items.
zstyle ':completion:*' menu select

# Completion is done from both ends.
setopt complete_in_word
# Show the type of each file with a trailing identifying mark.
setopt list_types

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=10000
setopt append_history
setopt bang_hist
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_lex_words
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey ' ' magic-space
bindkey '\e#' pound-insert
bindkey -s "\C-q" "\e#!!:s/#//:x \n"

# move with control
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

# delete with alt
bindkey "\ea" backward-kill-line
bindkey "\ee" kill-line
bindkey "\e[1;9C" kill-word
bindkey "\e[1;9D" backward-kill-word

# directory colors
eval $(dircolors -b)
alias ls="ls --color=tty -hF"
alias ll="ls -l"
alias lt="ll -t"
alias la="ls -A"
alias lla="ll -A"
l.()  { ls  -d "$@" .* ; }
lth() { lla -t "$@" | head ; }
lsd() { ls     "$@" | grep '/$' ; }

# make sure we don't leave accidentally
IGNOREEOF=1
bash-ctrl-d() {
  if [[ $CURSOR == 0 && -z $BUFFER ]]
  then
    [[ -z $IGNOREEOF || $IGNOREEOF == 0 ]] && exit
    if [[ $LASTWIDGET == bash-ctrl-d ]]
    then
      (( --__BASH_IGNORE_EOF <= 0 )) && exit
    else
      (( __BASH_IGNORE_EOF = IGNOREEOF-1 ))
    fi
  else
  fi
  zle send-break
}
setopt ignoreeof
zle -N bash-ctrl-d
bindkey "^D" bash-ctrl-d

# allow comments in the shell
setopt interactive_comments

# customise cd

# If a command is issued that can’t be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory. 
setopt auto_cd
# Make cd push the old directory onto the directory stack.
setopt auto_pushd
# Don’t push multiple copies of the same directory onto the directory stack. 
setopt pushd_ignore_dups
# iallow cd to variables
setopt cdable_vars
# Allow for correction of inaccurate commands
setopt correct

alias ...="cd ../.."
alias d="dirs -v"
mcd() { mkdir -p "$@" && cd "${@:$#}" ; }
# TODO: command line completion for mcd

# TODO: fg completion

# Stopped jobs that are removed from the job table with the disown builtin
# command are automatically sent a CONT signal to make them running.
setopt auto_continue
# Treat single word simple commands without redirection as candidates for
# resumption of an existing job.
setopt auto_resume
# jobs -l by default
setopt long_list_jobs
# Report the status of background jobs immediately. (Trial only).
setopt notify

# empty input redirection goes to less
export READNULLCMD="less -Ri"
# Report timing stats for any command longer than 10 seconds
export REPORTTIME=10
