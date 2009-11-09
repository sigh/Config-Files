# put our bin folder in the path
export PATH="${PATH}:$HOME/bin"

# only run if we are interactive
[ -z "$PS1" ] && return

# remove all aliases so that we can redfine them without errors
unalias -a

# make a colorful prompt
NONE="\[$(tput sgr0)\]"    # reset formatting to default

if [ "$USER" = 'root' ] ; then
    RAW_PROMPT_COLOR="$(tput setf 4)" # red for root
else
    RAW_PROMPT_COLOR="$(tput setf 2)" # green for other
fi
PROMPT_COLOR="\[$RAW_PROMPT_COLOR\]"

if [[ "$TERM" == xterm* ]] ; then
    TITLEBAR='\[\033]0;\u@\h\007\]'
else
    TITLEBAR=
fi

PARENT_NAME=$(ps -o command -p $PPID | tail -n +2)
PARENT_NAME=${PARENT_NAME%%[: ]*}
export PS1="$TITLEBAR$PROMPT_COLOR[\A] [$PARENT_NAME] \u@\h:\w\n$PROMPT_COLOR\! \$$NONE "

# set other prompts
export PS2="$PROMPT_COLOR>$NONE "
export PS4="\[$(tput setf 5)\]+$NONE "

# mysql prompt
export MYSQL_PS1="$RAW_PROMPT_COLOR[\R:\m] \U:\d$(tput setf 0)\nmysql> "

unset NONE
unset PROMPT_COLOR
unset RAW_PROMPT_COLOR
unset PARENT_NAME
unset TITLEBAR

# disable flow control (C-s, C-r)
stty -ixon

# customise cd

cd()   { pushd "$@" > /dev/null; }

cd..() { cd "$@" .. ; }
..()   { cd "$@" .. ; }
d()    { dirs -v "$@" ; }

mkdcd() { mkdir -p "$@" && cd "${!#}" ; }

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
export HISTIGNORE='&:ls:fg:bg:ssh-fix:[ ]*'
unset  HISTFILESIZE                 # never delete from history
export HISTFILESIZE
export HISTSIZE=10000
export PROMPT_COMMAND='history -a'  # update history file after each command

shopt -s histappend
shopt -s cmdhist

# make sure we don't leave accidentally
export IGNOREEOF=1

# customise ls 
eval $(dircolors)
ls()  { command ls --color=tty -hF "$@" ; }
l.()  { ls  -d "$@" .* ; }
ll()  { ls  -l "$@" ; }
lt()  { ll  -t "$@" ; }
la()  { ls  -A "$@" ; }
lla() { ll  -A "$@" ; }
lth() { lla -t "$@" | head ; }
lsd() { ls     "$@" | grep '/$' ; }

# display full paths
realpath() { readlink -f "$@" ; }
rp() { realpath "$@" ; }

# make disk usage display nicer
du()  { command du -hc "$@" ; }
dus() { du -s  "$@" ; }

# globbing options
shopt -s nocaseglob
shopt -s extglob

# colorize search results for grep
zg()  { zgrep -e  --color=always "$@" ; }
zgi() { zgrep -ei --color=always "$@" ; }
g()   { egrep     --color=always "$@" ; }
gi()  { egrep -i  --color=always "$@" ; }
gh()  { gi "$@" "$HISTFILE"; }

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
less() { command less -R "$@" ; }

# share directory on the web
webshare() { python -c "import SimpleHTTPServer; SimpleHTTPServer.test()" "$@" ; }

# echo shortcut
e() { echo "$@" ; }

# Make bash check it's window size after a process completes
shopt -s checkwinsize

# open man page as a PDF in preview
if [[ -d /Applications/Preview.app ]] ; then
    pman() { command man -t "$@" | open -f -a /Applications/Preview.app; }
fi

# use vim as our pager for everything 
 
export MANPAGER="vimless -f man"
export MANWIDTH=80
export PERLDOC_PAGER="vimless -f man"
export PERLDOC="-otext"

vless() { vimless "$@" ; }

export PAGER="vimless"
 
# shortcut vim and set it as our editor
vi() { vim "$@" ; }
export EDITOR=vim
export SVNEDITOR=vim

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"

# screen commands

if [[ -z "$STY" ]] ; then
    # commands for outside screen

    # attach to an existing screen session or create one if it doesn't exist
    attach() {
        # store ssh session data in screen variables
        if [ -n "$SSH_CLIENT" ]; then
            # Variables to save
            SSHVARS="SSH_CLIENT SSH_TTY SSH_AUTH_SOCK SSH_CONNECTION DISPLAY"

            string=' ' # start with a space so it is ignored by history
            for x in ${SSHVARS} ; do
                string="$string export $x='$(eval echo \$$x)' ; "
            done
            string="$string
"           # intentional newline

            opt=
            if [[ -n "$1" ]] ; then
                opt="-S $1"
            fi

            screen $opt -X register z "$string" > /dev/null 2>&1
        fi

        # run screen
        screen -d -R $1
    }
else
    # commands for use inside screen

    title() { screen -X title "$@" ; }

    # import ssh session
    ssh-fix() {
        screen -X process z
    }
    
    # revert titlebar if screen messes with it
    printf "\033];$USER@${HOSTNAME%%.*}\007"
fi

