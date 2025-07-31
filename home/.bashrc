# only run if we are interactive
[ -z "$PS1" ] && return

# remove all aliases so that we can redefine them without errors
unalias -a

# disable flow control (C-s, C-r)
stty -ixon

# don't echo control characters (in particular don't echo ^C on the command line).
stty -ctlecho

# Report immediately when background jobs finish.
# (Trial only, see if this annoys me).
set -b

# allow for correction of inaccurate cd commands
shopt -s cdspell

# turn off before bash_completion setup
# otherwise all variables match for cd
shopt -u cdable_vars

# turn on smart tab completion
shopt -s progcomp
. "$HOME/.bash_completion"
. "$HOME/.git-completion.bash"

# don't bother trying to complete all commands on empty prompt
shopt -s no_empty_cmd_completion

# allow us to cd to variables (turn on AFTER bash_completion)
shopt -s cdable_vars

# allow for correction of inaccurate cd commands
shopt -s cdspell

# customise cd

cd() {
    pushd "$@" > /dev/null
    local path
    # remove all previous instances of the current directory from $DIRSTACK.
    for ((i=${#DIRSTACK[@]} - 1; i > 0; i--)) ; do
        # eval required for ~ expansion.
        eval path=\"${DIRSTACK[$i]}\"
        if [[ $path == $PWD ]] ; then
            popd +"$i" -n > /dev/null
        fi
    done
}

cd..() { cd "$@" .. ; }
..()   { cd "$@" .. ; }
d()    { dirs -v "$@" ; }

mcd() { mkdir -p "$@" && cd "${!#}" ; }
complete -F _cd -o filenames -o nospace mcd

# job control

j() { jobs -l "$@"; }

_fg() {
    local IFS=$'\n\t' cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(jobs | \
        perl -ne '
            s/\(.*\)$//;
            my @s = split;
            my $c = "@s[2..$#s]\n";
            $c =~ s/ /\\ /g;
            print $c if $c =~ /^\Q'$cur'\E/
        ' \
    ) )
}
# Note: This works better than `complete -A jobs fg` because it shows the full command
complete -F _fg fg

# Any single word command which is a prefix of a stopped job will resume it
#   (trying out on a trial basis)
export auto_resume=prefix

# ignore files with the following suffixes for tab completion
export FIGNORE='.swp:.svn:.0:~';

_make_prompt() {
    # make a colorful prompt
    # (this must be done after git-completion has been initialised)

    # if tput doesn't exist then replace it with a python implementation
    if ! type tput > /dev/null 2>&1 ; then
        tput() {
python - "$@" <<EOF
from curses import *
import sys
setupterm()
sys.stdout.buffer.write(tparm(tigetstr(sys.argv[1]), *map(int, sys.argv[2:])))
EOF
        }
    fi

    NONE="\[$(tput sgr0)\]"    # reset formatting to default

    if [[ "$USER" == root ]] ; then
        RAW_PROMPT_COLOR="$(tput setaf 1)" # red for root
    else
        RAW_PROMPT_COLOR="$(tput setaf 2)" # green for other
    fi
    PROMPT_COLOR="\[$RAW_PROMPT_COLOR\]"

    if [[ "$TERM" == xterm* ]] ; then
        TITLEBAR='\[\033]0;\u@\h\007\]'
    else
        TITLEBAR=
    fi

    export PS1="$TITLEBAR$PROMPT_COLOR[\A] [\j] \u@\h:\w\$(__git_ps1)\n$PROMPT_COLOR\! \$$NONE "
    # tell __git_ps1 to show us when we've modified the state
    export GIT_PS1_SHOWDIRTYSTATE=true

    # set other prompts
    export PS2="$PROMPT_COLOR>$NONE "
    export PS4="\[$(tput setaf 5)\]+$NONE "

    # mysql prompt
    export MYSQL_PS1="$RAW_PROMPT_COLOR[\R:\m] \U:\d$(tput setaf 0)\nmysql> "
}

_make_prompt
unset _make_prompt

# customise history

# Change the location of HISTFILE
# this way if .bashrc isn't run, our HISTFILE isn't truncated
hist_old="$HISTFILE"
export HISTFILE="$HOME/._bash_history"

# if it doesn't exist, then initialise with
# current history
if [[ -f "$hist_old" && ! -f "$HISTFILE" ]] ; then
    cp "$hist_old" "$HISTFILE"
fi

unset hist_old

export HISTIGNORE='&:ls:fg:bg:ssh-fix:[ ]*'
unset  HISTFILESIZE            # never delete from history
export HISTFILESIZE
export HISTSIZE=10000
export HISTTIMEFORMAT='%FT%T ' # save timestamps (and display in ISO format)

shopt -s histappend
shopt -s cmdhist
shopt -s histreedit

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
realpath() { readlink --verbose -e "${1:-.}" ; }
rp() { realpath "$@" ; }

# make disk usage display nicer
du()  { command du -hc "$@" ; }
dus() { du -s  "$@" ; }

# globbing options
shopt -s nocaseglob
shopt -s extglob

# colorize search results for grep
zgr() { zgrep -e  --color=always "$@" ; }
zgi() { zgrep -ei --color=always "$@" ; }
gr()  { egrep     --color=always "$@" ; }
gi()  { egrep -i  --color=always "$@" ; }

# make git easier to type :)
g() { git "$@"; }
complete -o default -o nospace -F _git g

# make less display colors
less() { command less -R "$@" ; }

# print short wikipedia lookup
wiki() {
    dig +short txt "`echo $@`".wp.dg.cx \
    | sed -e 's/" "//g' -e 's/^"//g' -e 's/"$//g' \
    | fmt -w `tput cols`
}

# echo shortcut
e() { echo "$@" ; }

# Make bash check it's window size after a process completes
shopt -s checkwinsize

# open man page as a PDF in preview
if [[ -d /Applications/Preview.app ]] ; then
    pman() { command man -t "$@" | open -f -a /Applications/Preview.app; }
    complete -F _man -o filenames pman
fi

# unmount an OSX volume
unmount() {
    diskutil unmount "/Volumes/$1"
}
_unmount() {
    # unmount only takes one argument, so don't complete any more
    if [[ $COMP_CWORD -ne 1 ]] ; then
        return
    fi

    local IFS=$'\t\n' cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(command cd /Volumes; compgen -d -- $cur ) )
}
complete -F _unmount -o filenames unmount

# make it easy to use vim as our pager
vless() { vimless "$@" ; }

# shortcut vim and set it as our editor
vi() { vim -X "$@" ; }
v() { vim -X "$@" ; }
complete -o filenames -F _filedir_xspec v
export EDITOR=vim
export SVNEDITOR=vim

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"

s() { session_wrapper "$@"; }

# completion for session_wrapper
_session_wrapper() {
    COMPREPLY=( $(session_wrapper --complete "${COMP_WORDS[COMP_CWORD]}" ))
}

complete -F _session_wrapper session_wrapper
complete -F _session_wrapper s

if [[ -n $TMUX ]] ; then
    sessionname() {
        tmux rename-session "$@"
    }

    # set title for current session
    #   new title can contain spaces
    title() {
        local title="$*"
        if [[ -z $title ]] ; then
            title=$(basename "$PWD")
        fi
        tmux rename-window "$title"
    }
fi

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# reload the bashrc for the current shell
reload() {
  . ~/.bashrc
}
# use SIGCONT because it is does not terminate bash by default
trap reload CONT

# Full log and history updating
# This must go after everything else
unset PROMPT_COMMAND
if [[ ! $_ALREADY_LOADED ]] ; then
    # we don't want the first line when we reload
    cat <<<"$$ 0 $(date +%FT%T) $PWD \$ # PPID=$PPID SHLVL=$SHLVL SHELL=$SHELL BASH_VERSION=$BASH_VERSION" >> ~/._full_bash_history
    readonly _ALREADY_LOADED=1
fi
trap 'awk -v prefix="$$ $LINENO $(date +%FT%T) $PWD \$" "{ print prefix, \$0 }" <<<"$BASH_COMMAND" >> ~/._full_bash_history; history -a' DEBUG
