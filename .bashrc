# only run if we are interactive

[ -z "$PS1" ] && return

# put our bin folder in the path
export PATH="${PATH}:$HOME/bin"

# only set the prompt if interactive
if [ -n "$PS1" ] ; then

    # make a colorful prompt
    NONE="\[$(tput setf 0)\]"    # unsets color to term's fg color

    if [ "$USER" = 'root' ] ; then
        RAW_PROMPT_COLOR="$(tput setf 4)" # red for root
    else
        RAW_PROMPT_COLOR="$(tput setf 2)" # green for other
    fi
    PROMPT_COLOR="\[$RAW_PROMPT_COLOR\]"

    case $TERM in
        xterm*) TITLEBAR='\[\033]0;\u@\h:\w\007\]' ;;
        *)      TITLEBAR='' ;;
    esac

    export PS1="$TITLEBAR$PROMPT_COLOR[\A] \u@\h:\w\n$PROMPT_COLOR\! \$$NONE "

    # set other prompts
    export PS2="$PROMPT_COLOR>$NONE "
    export PS4="\[$(tput setf 5)\]+$NONE "

    # mysql prompt
    export MYSQL_PS1="$RAW_PROMPT_COLOR\d > $(tput setf 0)"

    unset NONE
    unset PROMPT_COLOR
    unset RAW_PROMPT_COLOR

    # disable flow control (C-s, C-r)
    stty -ixon
fi

# customise cd

cd() { pushd "$1" > /dev/null; }

alias cd..='cd ..'
alias ..='cd ..'
alias d='dirs -v'

mkdcd() { mkdir "$@" && cd "$1" ; }

# allow for correction of inaccurate cd commands
shopt -s cdspell

# turn off before bash_completion setup
# otherwise all variables match for cd
shopt -u cdable_vars

# turn on smart tab completetion
shopt -s progcomp
source "$HOME/.bash_completion"

# allow us to cd to variables (turn on AFTER bash_completion)
shopt -s cdable_vars

# allow for correction of inaccurate cd commands
shopt -s cdspell
shopt -s cdable_vars

# ignore files with the following suffixes for tab completion
export FIGNORE='.swp:.svn:.0:~';

# customise history
export HISTIGNORE='&:ls:[ ]*'
unset  HISTFILESIZE                 # never delete from history
export HISTFILESIZE
export HISTSIZE=10000
export PROMPT_COMMAND='history -a'  # update history file after each command

shopt -s histappend
shopt -s cmdhist

# make sure we don't leave accidentally
export IGNOREEOF=1

# customise ls 
eval `dircolors`
alias ls='ls --color -hF'
alias ll='ls -l'
alias lt='ll -t'
alias la='ls -A'
alias lla='ll -A'
lth() { lla -t "$@" | head ; }
lsd() { ls "$@" | grep '/$' ; }

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
alias zg='zgrep -e --color=always'
alias zgi='zgrep -ei --color=always'
alias g='egrep --color=always'
alias gi='egrep -i --color=always'
function gh() { gi "$@" "$HISTFILE"; }

# Handy Extract Program.
extract()      
{
     if [ -f "$1" ] ; then
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
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# make less display colors
alias less='less -R'

# share directory on the web
alias webshare='python -c "import SimpleHTTPServer; SimpleHTTPServer.test()"'

# echo shortcut
alias e='echo'

# Make bash check it's window size after a process completes
shopt -s checkwinsize

# open man page as a PDF in preview
if [[ -f /Applications/Preview.app ]] ; then
    pman() { man -t "$@" | open -f -a /Applications/Preview.app; }
fi

# shortcut vim and set it as our editor
alias vi=vim
export EDITOR=vim
export SVNEDITOR=vim

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"
