# put our bin folder in the path
export PATH="${PATH}:$HOME/bin"

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

# make a colorful prompt
# (this must be done after git-completion has been initialised)

NONE="\[$(tput sgr0)\]"    # reset formatting to default

if [[ "$USER" == root ]] ; then
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

export PS1="$TITLEBAR$PROMPT_COLOR[\A] [\j] \u@\h:\w\$(__git_ps1)\n$PROMPT_COLOR\! \$$NONE "
# tell __git_ps1 to show us when we've modified the state
export GIT_PS1_SHOWDIRTYSTATE=true

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
gh()  { gi "$@" "$HISTFILE"; }

# Grep all files in the current directory recursively
#   ignoring any files and folders that start with a .
g.() {
    find . -name '.?*' -prune -o -exec egrep --color=always -H "$@" {} \; 2> /dev/null
}

# make git easier to type :)
g() { git "$@"; }
complete -o default -o nospace -F _git g

# Handy Extract Program.
extract()
{
     if [[ -f "$1" ]] ; then
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
webshare() { python -m SimpleHTTPServer "$@" ; }

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
vi() { vim "$@" ; }
v() { vim "$@" ; }
complete -o filenames -F _filedir_xspec v
export EDITOR=vim
export SVNEDITOR=vim

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"

# screen commands

# ensure screendir is populated with the directory
#   that screen is actually using
SCREENDIR="$(screen -ls | tail -2 | sed -ne 's/^.* in \(\S\+\).$/\1/p')"

# easy way to list screens
#   (and no risk of starting a new screen if we make a typo)
screens() { screen -ls ; }

if [[ -z "$STY" ]] ; then
    # commands for outside screen

    # store ssh session data in screen variables
    # only required if we are accessing an existing screen session
    # if the session doesn't exist then this command does nothing
    #   and that is OK.
    setup-ssh-fix() {
        if [[ -n "$SSH_CLIENT" ]]; then
            local string=' ' # start with a space so it is ignored by history
            for x in SSH_CLIENT SSH_TTY SSH_AUTH_SOCK SSH_CONNECTION DISPLAY; do
                string="$string export $x='$(eval echo \$$x)' ; "
            done
            string="$string"$'\n'

            # screenname is an optional argument
            opt=
            if [[ -n "$1" ]]; then
                opt="-S $1"
            fi

            # opt is unquoted on purpose. I could make this an array and do it
            # properly.
            screen $opt -X register z "$string" > /dev/null 2>&1
        fi
    }

    # default sessionname is the first part of the $HOSTNAME
    default-sessionname() {
        echo -n "${HOSTNAME%%.*}"
    }

    # _attach-helper "-a1 -a2 ..." -b1 -b2 ... [session_name]
    # Will call: screen -b1 -b2 ... -a1 -a2 ... session_name
    # If no session name is given then the default will be used.
    _attach-helper() {
        local session_name first_args last_args

        # determine the session name if user gave one, otherwise use the
        # default session name.
        if [[ ${!#} =~ ^- ]]; then
            session_name="$(default-sessionname)"
        else
            session_name="${!#}"
        fi

        # last args (given by attach function).
        last_args="$1"
        shift

        # first arguments (given by user).
        first_args=()
        while [[ $1 =~ ^- ]] ; do
            first_args=("${first_args[@]}" "$1")
            shift
        done

        # last_args is intentionally unquoted
        screen "${first_args[@]}" $last_args "$session_name"
    }

    # attach to an existing screen session or create one if it doesn't exist
    attach() {
        _attach-helper "-D -R" "$@"
    }

    # attach to an existing screen session or create one if it doesn't exist
    attach-again() {
        _attach-helper "-x -S" "$@"
    }

    # completion for attach* commands
    _attach() {
        # attach only takes one argument, so don't complete any more
        if [[ $COMP_CWORD -ne 1 ]] ; then
            return
        fi

        local cur=${COMP_WORDS[COMP_CWORD]}

        if [[ -n "$cur" ]]; then
            # if the user has already started typing then show all matches
            #   (both long and short names)
            COMPREPLY=( \
                $( command screen -ls | \
                    sed -ne 's|^['$'\t'']\+\('$cur'[0-9]\+\.[^'$'\t'']\+\).*$|\1|p' ) \
                $( command screen -ls | \
                    sed -ne 's|^['$'\t'']\+[0-9]\+\.\('$cur'[^'$'\t'']\+\).*$|\1|p' | \
                    sort | uniq -u ) )
        else
            # otherwise we don't want to show duplicate matches and stuff
            COMPREPLY=( $( command screen -ls | \
                sed -ne 's|^['$'\t'']\+\([0-9]\+\.[^'$'\t'']\+\).*$|\1|p' | \
                perl -e '
                    my @names = <STDIN>; my %counts;
                    map { my $n=$_; $n=~s/^[0-9]+\.//; $counts{$n}+=1 } @names;
                    while (my($value,$count) = each(%counts)) {
                        if ( $count == 1 ) {
                            # name is unique, so use short name
                            print "$value\n";
                        } else {
                            # name is not unique so show all matching full names
                            print "$_\n" foreach grep { /^[0-9]+\.$value$/ } @names;
                        }
                    }
                ' ) )
        fi
    }

    complete -F _attach attach
    complete -F _attach attach-again

    # I use attach a lot
    a() { attach "$@"; }
    complete -F _attach a
else
    # commands for use inside screen

    # fix the STY variable which gets messed up if we change the session name
    sty-fix() {
        export STY="$(basename $SCREENDIR/${STY%%.*}.*)"
    }

    # ensure that $STY is correct before running any screen commands
    screen() {
        sty-fix
        command screen "$@"
    }

    # update the status to display the sessionname
    update-status() {
        sty-fix
        screen -X hardstatus string '%{= kG}'${STY#*.}' %{= kW}%-Lw%{= BW}%50>%n%f* %t%{-}%+Lw%<%{= kW} %='
    }

    # change the session name
    sessionname() {
        screen -X sessionname $1
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
        if [[ -n "$abs_path" ]] ; then
            screen -X setenv SCREEN_SHELLDIR "$abs_path"
        else
            echo "chdir: $1: No such directory"
        fi
    }
    complete -F _cd -o nospace -o filenames chdir

    # print entire scrollback to stdout 
    scrollback() {
        local filename="/tmp/screen-$STY.$WINDOW"
        screen -X hardcopy -h "$filename"
        # output file with blank line deleted from the top
        sed '/./,$!d' "$filename"
        rm "$filename"
    }

    # import ssh session
    ssh-fix() {
        screen -X process z
    }

    # revert titlebar if screen messes with it
    printf "\033];$USER@${HOSTNAME%%.*}\007"

    # ensure that the status is up-to-date
    #   in particular if this the start of the session
    update-status

    # change the directory we start in if it has been specified
    if [ -n "$SCREEN_SHELLDIR" ]; then
        cd "$SCREEN_SHELLDIR"
    fi
fi

# reload the bashrc for the current shell
reload() {
  . ~/.bashrc
  bind -f ~/.inputrc
}
# use SIGCONT because it is does not terminate bash by default
trap reload CONT

# Full log and history updating
# This must go after everything else
unset PROMPT_COMMAND
if [[ ! $_ALREADY_LOADED ]] ; then
    # we don't want the first line when we reload
    cat <<<"$$ 0 $(date +%FT%T) $PWD \$ # PPID=$PPID SHLVL=$SHLVL STY=$STY SHELL=$SHELL BASH_VERSION=$BASH_VERSION" >> ~/._full_bash_history
    export _ALREADY_LOADED=1
fi
trap 'awk -v prefix="$$ $LINENO $(date +%FT%T) $PWD \$" "{ print prefix, \$0 }" <<<"$BASH_COMMAND" >> ~/._full_bash_history; history -a' DEBUG
