# only run if we are interactive

[ -z "$PS1" ] && return

# make a colorful prompt
NONE="\[\033[0m\]"    # unsets color to term's fg color

if [ "$USER" = 'root' ] ; then
    PROMPT_COLOR="\[\033[0;31m\]" # red for root 
else
    PROMPT_COLOR="\[\033[0;32m\]" # green for other
fi
case $TERM in
    xterm*) TITLEBAR='\[\033]0;\u@\h:\w\007\]' ;;
    *)      TITLEBAR='' ;;
esac

export PS1="$TITLEBAR$PROMPT_COLOR[\A] \u@\h:\w\n$PROMPT_COLOR\! \$$NONE "
export PS1_BASE="$TITLEBAR$PROMPT_COLOR[\A] \u@\h:\x\n$PROMPT_COLOR\! \$$NONE "
PROMPT_COMMAND=' test -e $SHORTCUT_FILE && source $SHORTCUT_FILE;' 
PROMPT_COMMAND=$PROMPT_COMMAND' PS1="`create_ps1`";'
export PROMPT_COMMAND;

export PS2="$PROMPT_COLOR>$NONE "
export PS4="\[\033[0;35m\]+$NONE "

export SHORTCUT_FILE=~/.shortcuts;
export usb

unset NONE
unset PROMPT_COLOR

export SHORTCUT_FILE=~/.shortcuts

alias sc='shortcut'
alias usc='sc -u'

# customise cd to use pushd and popd

function cd {
    if  [ -z "$1" ] ; then
        pushd ~ > /dev/null 
    elif [ "$1" = '-' ] ; then
        popd > /dev/null
    elif [ "$1" = '--' ] ; then
        popd > /dev/null 2>&1
        popd > /dev/null
    elif [ "$1" = '---' ] ; then
        popd > /dev/null 2>&1
        popd > /dev/null 2>&1
        popd > /dev/null
    elif [ "$1" = '...' ] ; then
        pushd ../.. > /dev/null
    elif [ "$1" = '....' ] ; then
        pushd ../../.. > /dev/null
    elif [ "$1" = '.....' ] ; then
        pushd ../../../.. > /dev/null
	else
		pushd "$1" > /dev/null
	fi
}

alias cd-='cd -'
alias cd--='cd --'
alias cd---='cd ---'

alias cd..='cd ..'
alias cd...='cd ...'
alias cd....='cd ....'
alias cd.....='cd .....'

alias ..='cd ..'
alias ...='cd ...'
alias ....='cd ....'
alias .....='cd .....'

function mkdcd { mkdir "$@" && cd "$1" ; }

# turn on smart tab completetion
if [ -f /etc/bash_completion ] ; then
    shopt -s progcomp
    source /etc/bash_completion
fi 

# allow for correction of inaccurate cd commands
shopt -s cdspell

shopt -s cdable_vars

# ignore files with the following suffixes for tab completion
export FIGNORE='.swp:.svn:.0:~';


# disable flow control (C-s, C-r)
stty -ixon

# customise history
export HISTIGNORE='&:ls:[bf]g:clear:exit:[ ]*'
export HISTSIZE=5000
export HISTFILESIZE=1000

shopt -s histappend
shopt -s cmdhist

# make sure we don't leave accidentally
export IGNOREEOF=1

# easier directory browsing
alias ls='ls -hFG'
alias ll='ls -l'
alias lt='ll -t'
alias la='ls -A'
alias lla='ll -A'
function lth { lla -t "$@" | head ; }
function lsd { ls "$@" | grep '/$' ; }

# display full paths
alias realpath='readlink -f'
alias rp='realpath'

# make disk usage display nicer
alias du='du -hc'
alias dus='du -s'

# globbing options
shopt -s nocaseglob
shopt -s extglob

# colorize search results for grep
alias g='egrep --color=always'
alias gi='egrep -i --color=always'
alias gh='history | gi'

# make less display colors
alias less='less -R'

# terminal calculator
function calc { echo "$@" | bc -l ; }

# share directory on the web
alias webshare='python -c "import SimpleHTTPServer; SimpleHTTPServer.test()"'

# echo shortcut
alias e='echo'

# Make bash check it's window size after a process completes
shopt -s checkwinsize

# shortcut vim and set it as our editor
alias vi=vim
export EDITOR=vim
