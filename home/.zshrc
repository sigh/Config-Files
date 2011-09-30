# populate our path properly
[[ -f ~/.profile ]] && . ~/.profile

# clean up all existing aliases
unhash -am '*'

# warn me if I create globals in a function
setopt warn_create_global

# advanced input redirection (no need for tee)
setopt multios

# disable flow control (C-s, C-r)
stty -ixon

# don't echo control characters (in particular don't echo ^C on the command line).
stty -ctlecho

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# allow me to use arrow keys to select items.
zstyle ':completion:*' menu select
# case-insensitive completion. Partial-word and then substring completion commented out
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # \
       # 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# don't complete the same filenames again
zstyle ':completion:*:(rm|cp|mv|zmv|vim|git):*' ignore-line other

zstyle ':completion:*:*:*' ignore-parents parent pwd

# fuzzy matching of completions
zstyle ':completion:*' completer _complete _match _approximate
# zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Stop trying to complete things in the path which already match!
zstyle ':completion:*' accept-exact-dirs true
# The following option is a stricter version of the above which prohibits
# *any* completion on the path.
# zstyle ':completion:*' path-completion false

# tab completion
autoload -U compinit && compinit
source ~/.git-completion.bash

# Completion is done from both ends.
setopt complete_in_word
# Show the type of each file with a trailing identifying mark.
setopt list_types
# if there are other completions, always show them
unsetopt rec_exact
# don't expand glob automatically when completing.
setopt glob_complete

# Other global aliases
alias -g C='| wc -l'
alias -g L='| less'
alias -g V='| vimless'
alias -g NO="&> /dev/null"
alias -g NE="2> /dev/null"
alias -g NS="> /dev/null"
alias -g G='| egrep --color=always'
alias -g GI='| egrep -i --color=always'
alias -g H='| head'

# history
export HISTFILE="$HOME/._zsh_history"
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

bindkey -e # use emacs mode by default
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey ' ' magic-space
bindkey '\e#' pound-insert
bindkey -s "\C-s" "\C-a\e[1;5C"
bindkey "\e[Z" reverse-menu-complete # Shift-tab

# map alt-, to complete files regardless of context
zle -C complete-files complete-word _generic
zstyle ':completion:complete-files:*' completer _files
bindkey '^[,' complete-files

# Alt-' quotes current argument
# Alt-' Alt-' quote entire line
quote-after() {
    local result i
    for (( i=0; i < ${#RBUFFER}; i++ )) ; do
        if [[ ${RBUFFER:$i:1} == ' ' ]] ; then
            if [[ $1 == 'arg' ]]; then
                RBUFFER="$result${RBUFFER:$i}"
                return
            fi
            result+=' '
        else
            result+="${(q)RBUFFER:$i:1}"
        fi
    done
    RBUFFER="$result"
}
quote-before() {
    local result i
    for (( i=${#LBUFFER}-1; i >= 0; i-- )) ; do
        if [[ ${LBUFFER:$i:1} == ' ' ]] ; then
            if [[ $1 == 'arg' ]]; then
                LBUFFER="${LBUFFER:0:$i} $result"
                return
            fi
            result=" $result"
        else
            result="${(q)LBUFFER:$i:1}$result"
        fi
    done
    LBUFFER="$result"
}
quote-current-line() {
    quote-before
    quote-after
}
quote-current-arg() {
    quote-before arg
    quote-after arg
}
zle -N quote-current-arg
zle -N quote-current-line
bindkey "\e'" quote-current-arg
bindkey "\e'\e'" quote-current-line

# move with control
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

# delete with alt
bindkey "\ea" backward-kill-line
bindkey "\ee" kill-line
bindkey "\e[1;9C" kill-word
bindkey "\e[1;9D" backward-kill-word

WORDCHARS="${WORDCHARS:s#/#}"

# map shift-enter to ^J and then it will allow easy multiline editing.
bindkey "^J" self-insert

# directory colors
eval $(dircolors -b)
# Comandline completion has colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
alias ls="ls --color=tty -hF"
alias ll="ls -l"
alias lt="ll -t"
alias la="ls -A"
alias lla="ll -A"
l.()  { ls  -d "$@" .* ; }
lth() { lla -t "$@" | head ; }
# TODO: allow lsd to take directory argument.
lsd() { command ls --color=tty -hd "$@" */ }

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

# fancy mv
autoload -U zmv

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
# case insensitive globbing
setopt no_case_glob

alias d="dirs -v"
mcd() { mkdir -p "$@" && cd "${@:$#}" ; }
compdef _cd mcd

# strings of dots are expanded to parents if they form the start of a word.
# TODO: Is there a way to make this display the target directory as a side effect?
# TODO: Look at the docs for recursive-edit
rationalise-dot() {
  if [[ $LBUFFER =~ ' \.*\.\.' ]]; then
    LBUFFER+=/..
    # Make this work in a more robust way
    # PREDISPLAY="${LBUFFER% *} $(cd ${LBUFFER##* } 2> /dev/null && pwd)"$'\n'"$HISTCMD \$ "
    # region_highlight=("P0 ${#PREDISPLAY} fg=blue")
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

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
# ignores for vim
zstyle ':completion:*:*:vim:*:*files' ignored-patterns '*?.(aux|dvi|ps|pdf|bbl|toc|lot|lof|o|cm?)'

alias vless=vimless

# unmount an OSX volume
unmount() {
    diskutil unmount "/Volumes/$1"
}
_unmount() {
    local dirs
    dirs=( /Volumes/"$PREFIX"* )
    compadd - "${dirs[@]##/Volumes/}"
}
compdef _unmount unmount

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
zstyle ':completion:*:*:extract:*' file-patterns \
    '*.(tar|bz2|rar|gz|tbz2|tgz|zip|Z|7z):zip\ files *(-/):directories'

# open man page as a PDF in preview
if [[ -d /Applications/Preview.app ]] ; then
    pman() { command man -t "$@" | open -f -a /Applications/Preview.app; }
    compdef _man pman
fi

alias du="du -hc --max-depth=1"
alias dus="command du -hs"

# display full paths
realpath() {
    if (( $# == 0 )) ; then
        readlink --verbose -e .
        return
    fi
    for p in "$@" ; do
        readlink --verbose -e "$p"
    done
}
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

if [[ -z $STY ]] ; then
    # commands for outside screen

    # I use screen_wrapper a lot
    alias s=screen_wrapper
    _screen_wrapper() {
        compadd - $( screen_wrapper --complete "$PREFIX" )
    }
    compdef _screen_wrapper screen_wrapper
else
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
            display_name="${HOST%%.*}"
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
    zstyle ':completion:*:*:chdir:*' file-patterns 'files *(-/):directories'

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

# reload the bashrc for the current shell
reload() { . ~/.zshrc }
# use SIGCONT because it is does not terminate bash by default
trap reload CONT

# full history file is used to create a verbose detailed record of my commands.
if [[ -z $FULLHISTFILE ]] ; then
    readonly FULLHISTFILE=~/._full_zsh_history
fi

if [[ -z $_ALREADY_LOADED ]] ; then
    cat <<<"$$ 0 $(date +%FT%T) $PWD \$ # PPID=$PPID SHLVL=$SHLVL STY=$STY ZSH_VERSION=$ZSH_VERSION" >> "$FULLHISTFILE"
    # let us know that this has been loaded so that we can prevent somethings from
    # loading twice.
    readonly _ALREADY_LOADED=1
    _FULL_HIST_LINENO=0
fi
chmod 600 "$FULLHISTFILE"

# Set up prompt

setopt prompt_subst
_dir_ps1() {
    local dir="${PWD/#$HOME/~}"
    local git_path="$(git rev-parse --show-prefix 2> /dev/null)"
    if [[ -n $git_path ]] ; then
        git_path="${git_path%/}"
        dir="${dir%$git_path}%U$git_path%u"
    fi
    echo -n "$dir"
}
_status_ps1() {
    if [[ $_PS1_NEW_CMD == 2 ]] ; then
        echo -n "%(?..  %F{red}[exit %?]\n)"
    fi
}
PS1=$'$(_status_ps1)%F{blue}[%D{%H:%M}] [%j] %n@%m:$(_dir_ps1)$(__git_ps1)\n%h %(!.#.$) %f'
PS2=$'%F{blue}> %f'
PS4=$'%F{magenta}+%N:%i> %f'
export GIT_PS1_SHOWDIRTYSTATE=true

_PS1_NEW_CMD=2
precmd() {
    # helper to let us know the first time we show the prompt after a command finishs.

    local exit_status=$?
    # This value is set to 1 in preexec
    if [[ $_PS1_NEW_CMD == 1 ]] ; then
        echo "$$ $_FULL_HIST_LINENO $(date +%FT%T) [$exit_status]" >> "$FULLHISTFILE"
        _PS1_NEW_CMD=2
    else
        _PS1_NEW_CMD=0
    fi
}
preexec() {
    _FULL_HIST_LINENO=$((_FULL_HIST_LINENO + 1))
    # awk is used here so that multiline commands are shown on one line each.
    awk -v prefix="$$ $_FULL_HIST_LINENO $(date +%FT%T) $PWD \$" "{ print prefix, \$0 }" <<<"$1" >> "$FULLHISTFILE"
    _PS1_NEW_CMD=1
}
