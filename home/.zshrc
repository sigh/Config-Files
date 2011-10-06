# populate our path properly
[[ -f ~/.profile ]] && . ~/.profile

# reset as much as possible (mostly this is for when we are reloading).
# do NOT unset functions, zsh does some magic with them.
unhash -am '*' # aliases
trap -
zstyle -d
bindkey -d

# Ensure path only has unique entries.
typeset -gU PATH

# warn me if I create globals in a function
# setopt warn_create_global

# advanced input redirection (no need for tee)
setopt multios

# zsh reprints the prompt on window resize, but it messes with multiline
# prompts. This work around moves the cursor up one row on window resize.
trap 'tput cuu1' WINCH

# disable flow control (C-s, C-r)
stty -ixon

# don't echo control characters (in particular don't echo ^C on the command line).
stty -ctlecho

# Turn caching on
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

# Don't complete usernames without a ~
zstyle ':completion::complete:(mcd|chdir)::' tag-order '! users' -
zstyle ':completion::complete:cd::' tag-order local-directories named-directories directory-stack
# tab through previous directories automatically
zstyle ':completion::complete:cd::directory-stack' menu yes select
# tab through fg process automatically
zstyle ':completion::complete:fg:*:*' menu yes select

# stop when reaching beginning/end of history (further attempts then wrap)
zstyle ':completion:*:history-words' stop yes
# remove all duplicate words
zstyle ':completion:*:history-words' remove-all-dups yes
# don't list all the options (will often get the "too many options" prompt)
zstyle ':completion:history-words:*' list no
# we want the options to be filled in immediatly.
zstyle ':completion:*:history-words' menu yes

# This stops completion if we paste text into the terminal which has tabs.
zstyle ':completion:*' insert-tab pending

# tab completion # -u avoid unnecessary security check.
autoload -U compinit && compinit -u
source ~/.git-completion.bash

# Completion is done from both ends.
setopt complete_in_word
# Show the type of each file with a trailing identifying mark.
setopt list_types
# if there are other completions, always show them
unsetopt rec_exact
# don't expand glob automatically when completing.
setopt glob_complete
# case insensitive globbing
setopt no_case_glob
# don't print an error when there are no glob matches
setopt no_nomatch
# More globbing stuff.
setopt extended_glob
# Allow for correction of inaccurate commands
setopt correct
# Don't offer values starting with _ as corrections.
CORRECT_IGNORE='_*'

# run-help is awesome... get help about the current command.
# By default it is bound to ESC-h (Alt-h)
autoload -U run-help
HELPDIR=~/.zsh/help
alias man=run-help

# Make run help understand git subcommands
run-help-git() {
    if (( $# == 0 )); then
        man git
    else
        local al
        local subcmd="$1"
        if al=$(git config --get "alias.$1"); then
            subcmd="${al%% *}"
            echo "$1 is an alias for $al"
        fi
        man git-"$subcmd" 2> /dev/null
    fi
}

# Sudo should get help for the actual command
run-help-sudo() {
    if (( $# == 0 )); then
        man sudo
    else
        man "$1"
    fi
}

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

# Up and down move through multi-line buffer or through history using LBUFFER
# as a prefix.
my-up-line-or-history-search-backward() {
    if (( CURSOR == 0 )) ; then
        zle .up-history
    elif [[ $CURSOR -eq ${#BUFFER} && $LASTWIDGET == my-*-line-or-history-search-* ]]; then
        zle .up-history
    elif [[ $LBUFFER == *$'\n'* ]]; then
        zle .up-line-or-history
    else
        zle .history-beginning-search-backward
    fi
}
my-down-line-or-history-search-forward() {
    if (( CURSOR == 0 )) ; then
        zle .down-history
    elif [[ $CURSOR -eq ${#BUFFER} && $LASTWIDGET == my-*-line-or-history-search-* ]]; then
        zle .down-history
    elif [[ $LBUFFER != *$'\n'* && $LASTWIDGET == my-*-line-or-history-search-* ]]; then
        zle .history-beginning-search-forward
    elif [[ $RBUFFER == *$'\n'* ]]; then
        zle .down-line-or-history
    else
        zle .history-beginning-search-forward
    fi
}
zle -N my-up-line-or-history-search-backward
zle -N my-down-line-or-history-search-forward
bindkey "^[[A" my-up-line-or-history-search-backward
bindkey "^[[B" my-down-line-or-history-search-forward
# Complete using words from history (Ctrl-N, Ctrl-P are to mimic vi bindings).
bindkey "\C-n" _history-complete-older
bindkey "\C-p" _history-complete-newer

bindkey '^O' accept-and-infer-next-history
bindkey ' ' magic-space
bindkey '\e#' pound-insert
bindkey -s "\C-s" "\C-a\e[1;5C"
bindkey "\e[Z" reverse-menu-complete # Shift-tab

# Show dots when the command line is completing so that
# we have some visual indication of when the shell is busy.
expand-or-complete-with-dots() {
    echo -n "$(tput setf 4)...$(tput sgr0)"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# Edit command with vim.
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# map alt-, to complete files regardless of context
zle -C complete-files complete-word _generic
zstyle ':completion:complete-files:*' completer _files
bindkey '^[,' complete-files

# quote chars and keep cursor on the same character that it
# was before (not necessarily the same position).
# Characters are quoted in the range [$1, $2)
# Whitespace is ignored unless $3 is set.
_quote-chars-follow-cursor() {
    local new_cursor=$CURSOR
    local new_buffer=$BUFFER[1,$1]
    integer i

    for (( i = $1; i < $2; i++ )) ; do
        if [[ -z $3 && $BUFFER[$i+1] =~ $'[ \t\n\r]' ]] ; then
            new_buffer+=$BUFFER[$i+1]
        else
            new_buffer+=${(q)BUFFER[$i+1]}
        fi
        if [[ $i == $CURSOR ]] ; then
            new_cursor=$(( ${#new_buffer} - 1 ))
        fi
    done

    new_buffer+=$BUFFER[$2+1,$#BUFFER]

    # If the cursor is after the end of the region, then
    # move it forward by however much the buffer has increased.
    if (( CURSOR >= $2 )) ; then
        new_cursor=$(( CURSOR + ${#new_buffer} - ${#BUFFER} ))
    fi

    BUFFER=$new_buffer
    CURSOR=$new_cursor
}
# find the position of the current arg
_current-arg-position() {
    local start=0 end=${#BUFFER}
    integer i

    for (( i=0; i < ${#BUFFER}; i++ )) ; do
        if [[ $BUFFER[$i+1] =~ $'[ \t\r\n]' ]] ; then
            if (( i >= CURSOR )) ; then
                end=$i
            else
                start=$i
            fi
        fi
    done
    echo -n "$start $end"
}

# Alt-' quotes current argument
# Alt-' Alt-' quote entire line
quote-current-line() {
    _quote-chars-follow-cursor 0 ${#BUFFER}
}
quote-current-arg() {
    _quote-chars-follow-cursor $(_current-arg-position)
}
zle -N quote-current-arg
zle -N quote-current-line
bindkey "\e'" quote-current-arg
bindkey "\e'\e'" quote-current-line
# Alt enter just accepts the line like normal.
bindkey '^[^M' accept-line

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
# allow short loop syntax
setopt short_loops

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
# allow cd to variables
setopt cdable_vars

alias d="dirs -v"
mcd() { mkdir -p "$@" && cd "$@[-1]" ; }
compdef _cd mcd

# strings of dots are expanded to parents if they form the start of a word.
# TODO: Is there a way to make this display the target directory as a side effect?
# TODO: Look at the docs for recursive-edit
rationalise-dot() {
  if [[ $LBUFFER =~ ' \.\.(/\.\.)*$' ]]; then
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
READNULLCMD=less
# Report timing stats for any command longer than 1 second
REPORTTIME=1
TIMEFMT="$(tput setf 4)%E real  %U user  %S system  %P cpu  %MkB mem $(tput sgr0)$ %J"

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"

# editor setup
export EDITOR=vim
export VISUAL=vim
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
alias g=git
alias p=python2.7

# make less display colors, have case insensitive search, quit on Ctrl-C
# and skip search results on the current screen.
export LESS=RiKa
export PAGER=less

# This is mostly used to color man pages.
export LESS_TERMCAP_mb=$(tput setaf 3) # yellow
export LESS_TERMCAP_md=$(tput bold; tput setaf 1) # red
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput setaf 2) # green
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)

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

    # Display entire scrollback in vim.
    scrollback() {
        setopt localtraps
        local filename="$(mktemp)"
        trap "rm -f -- '$filename'" 0
        trap 'exit 2' 1 2 3 15
        command screen -X hardcopy -h "$filename"
        # Use - because we want to call scrollback from within zle
        OUTPUT_FILE="$1" command vim -u NONE -c "runtime! macros/scrollback_less.vim" - < "$filename"
        # Move back up over the annoying text which vim writes.
        tput cuu 2
    }
    alias sb=scrollback
    # Access scrollback with Alt-s, use S within vim to write to command line.
    inline-screen-scrollback() {
        setopt localtraps
        local filename="$(mktemp)"
        trap "rm -f -- '$filename'" 0
        trap 'exit 2' 1 2 3 15
        scrollback "$filename"
        LBUFFER+="$(<$filename)"
        zle redisplay
    }
    zle -N inline-screen-scrollback
    bindkey '\es' inline-screen-scrollback

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

# reload zshrc for the current shell
reload() { . ~/.zshrc }
# use SIGCONT because it is does not terminate the shell by default
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

# Show this at the end of commands which don't output a newline at the end.
PROMPT_EOL_MARK='%B%S %s%b'

# Only show right prompt for current line.
setopt TRANSIENT_RPROMPT

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

