# TODO: move this into profile and make profile smart enough to deal with it.
#       I can source profile from here then.
# MacPorts Installer addition on 2011-08-26_at_21:21:54: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Ensure GNU tools are used by default
export PATH=/opt/local/libexec/gnubin:$PATH
# put our bin folder in the path
export PATH="${PATH}:$HOME/bin"

# warn me if I create globals in a function
setopt warn_create_global

# Set up prompt

# TODO: Fix colors once we are ready to switch.
setopt prompt_subst
PS1=$'%F{blue}[%T] [%j] %n@%m:%d$(__git_ps1)\n%h $ %f'
PS2=$'%F{blue}> %f'
PS4=$'%F{blue}+%N:%i> %f'
export GIT_PS1_SHOWDIRTYSTATE=true

# disable flow control (C-s, C-r)
stty -ixon

# don't echo control characters (in particular don't echo ^C on the command line).
stty -ctlecho

# tab completion
autoload -U compinit && compinit
autoload bashcompinit && bashcompinit
source ~/.git-completion.bash

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

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"

# editor setup
export EDITOR=vim
alias vi=vim
alias v=vim
# TOOD: Ensure command line completion work correctly for v and vi

alias vless=vimless

# unmount an OSX volume
unmount() {
    diskutil unmount "/Volumes/$1"
}
# TODO: completion for unmount

alias e=echo
# make less display colors
alias less="less -Ri"
alias g=git

# Handy Extract Program.
extract()
{
     if [[ -f $1 ]] ; then
         case "$1" in
             *.tar.bz2)   tar xvjf "$1"     ;;
             *.tar.gz)    tar xvzf "$1"     ;;
             *.bz2)       bunzip2 "$1"      ;;
             *.rar)       7za x "$1"        ;;
             *.gz)        gunzip "$1"       ;;
             *.tar)       tar xvf "$1"      ;;
             *.tbz2)      tar xvjf "$1"     ;;
             *.tgz)       tar xvzf "$1"     ;;
             *.zip)       unzip "$1"        ;;
             *.Z)         uncompress "$1"   ;;
             *.7z)        7za x "$1"         ;;
             *)           echo "'$1' cannot be extracted via >extract<" 1>&2 ;;
         esac
     else
         echo "'$1' is not a valid file" 1>&2
     fi
}
# TODO: completion for extract

alias du="du -hc --max-depth=1"
alias dus="command du -hs"

# display full paths
realpath() { readlink --verbose -e "${1:-.}" ; }
alias rp=realpath

# colorize search results for grep
alias zgr="zgrep -e --color=always"
alias zgi="zgrep -ei --color=always"
alias gr="egrep --color=always"
alias gi="egrep -i --color=always"
gh() { gi "$@" "$HISTFILE" }

# Grep all files in the current directory recursively
#   ignoring any files and folders that start with a .
g.() {
    find . -name '.?*' -prune -o -exec egrep --color=always -H "$@" {} \; 2> /dev/null
}

# screen commands

# I use screen_wrapper a lot
alias s=screen_wrapper

# TODO: completion for screen_wrapper

if [[ -n $STY ]] ; then
    # commands for use inside screen

    # ensure screendir is populated with the directory
    #   that screen is actually using
    SCREENDIR="$(screen -ls | tail -2 | sed -ne 's/^.* in \(\S\+\).$/\1/p')"

    # fix the STY variable which gets messed up if we change the session name
    sty-fix() {
        export STY="$(basename $SCREENDIR/${STY%%.*}.*)"
    }

    # ensure that $STY is correct before running any screen commands
    screen() {
        sty-fix
        command screen "$@"
    }

    # update the status to display the sessionname.
    # if the displayname is the default sessioname (_) then show the hostname.
    update-status() {
        sty-fix
        local display_name
        if [[ ${STY#*.} == _ ]] ; then
            display_name="${HOSTNAME%%.*}"
        else
            display_name="${STY#*.}"
        fi
        screen -X hardstatus string '%{= kG}'"$display_name"' %{= kW}%-Lw%{= BW}%50>%n%f* %t%{-}%+Lw%<%{= kW} %='
    }

    # change the session name
    sessionname() {
        screen -X sessionname "$1"
        update-status
    }

    # set title for current session
    #   new title can contain spaces
    title() {
        screen -X title "$*"
    }

    # change the default directory that screens open in
    #   screen -X chdir doesn't seem to work
    chdir() {
        local abs_path=$(cd "${1:-.}" 2> /dev/null && pwd)
        if [[ -n $abs_path ]] ; then
            screen -X setenv SCREEN_SHELLDIR "$abs_path"
        else
            echo "chdir: $1: No such directory"
        fi
    }
    # TODO: chdir should have the same completion as cd

    # print entire scrollback to stdout
    scrollback() {
        (
            local filename="$(mktemp)"
            trap "rm -f -- '$filename'" 0
            trap 'exit 2' 1 2 3 15
            command screen -X hardcopy -h "$filename"
            vim -u NONE -c "runtime! macros/scrollback_less.vim" "$filename"
        )
    }
    alias sb=scrollback

    # revert titlebar if screen messes with it
    printf "\033];$USER@${HOSTNAME%%.*}\007"

    # ensure that the status is up-to-date
    #   in particular if this the start of the session
    update-status

    # change the directory we start in if it has been specified
    if [[ -n $SCREEN_SHELLDIR && -z $_ALREADY_LOADED ]] ; then
        cd "$SCREEN_SHELLDIR"
        # clear the directory stack so that only the current directory is there.
        dirs -c
    fi
fi

# let us know that this has been loaded so that we can prevent somethings from
# loading twice.
readonly _ALREADY_LOADED=1