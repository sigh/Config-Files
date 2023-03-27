# populate our path properly
[[ -f ~/.profile ]] && . ~/.profile

# reset as much as possible (mostly this is for when we are reloading).
# do NOT unset functions, zsh does some magic with them.
unhash -am '*' # aliases
trap -
zstyle -d
bindkey -d

# Add my own functions directory
fpath=(~/.zsh/functions $fpath)

# Ensure path only has unique entries.
typeset -gU PATH

# warn me if I create globals in a function
# setopt warn_create_global

# advanced input redirection (no need for tee)
setopt multios

# disable flow control (C-s, C-r)
stty -ixon

# don't echo control characters (in particular don't echo ^C on the command line).
stty -ctlecho

# Auto suggestions
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

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

# Completion for the extract program
zstyle ':completion:*:*:extract:*' file-patterns \
    '*.(tar|bz2|rar|gz|tbz2|tgz|zip|Z|7z):zip\ files *(-/):directories'

# tab completion # -u avoid unnecessary security check.
autoload -U compinit && compinit -u
source ~/.git-completion.bash

_git-restore() {
    compadd - $( git tag -l )
}
compdef _git-restore git-restore

_git_cat_files() {
  local -a lines
  local -a parts
  local dir
  local name
  local line
  local cur=${words[$CURRENT]}
  local gitprefix="$(git rev-parse --show-prefix)"

  if [[ $cur == */* ]]; then
    dir="${cur%/*}/"
  fi
  # collect lines from ls-tree into an array
  lines=("${(@f)$(git ls-tree --full-tree "${words[2]}" "${gitprefix}${dir}")}")

  # add each file to the completion using the appropriate $prefix
  for line in $lines ; do
    # split line into words
    parts=("${(z)line}")
    # because we are always just listing the files from one directory
    # it's fine to take the last part of the name
    name="${parts[4]##*/}"
    if [[ $parts[2] == tree ]] ; then
      # directory
      compadd -p "$dir" -S '/' $* - "$name"
    else
      # normal file
      compadd -p "$dir" $* - "$name"
    fi
  done
}
_git-cat() {
  _arguments -C '1:commit:__git_commits' '*:file:_git_cat_files'
}
compdef _git-cat git-cat

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
setopt globstarshort
# Allow for correction of inaccurate commands
setopt correct
# Don't offer values starting with _ as corrections.
CORRECT_IGNORE='_*'

# run-help is awesome... get help about the current command.
# By default it is bound to ESC-h (Alt-h)
autoload -U run-help
HELPDIR=~/.zsh/help
alias help=run-help

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

# Mark files in the output. Put them into the array variable $m and the
# scalar variables $m1, $m2, ...
function m() {
  declare -ag m
  m=()

  # Allow perl to write directly to our stdout using file descriptor 3.
  exec 3>&1

  # Meanwhile perl's stdout will be eval'd.
  eval $(perl -e '
    open($real_stdout, ">&3") or die;
    $count = 0;

    sub insert_ref {
      $t = shift;
      if (-r $t) {
        $count += 1;
        print "m$count=\"$t\";";
        print "m+=(\"$t\");";
        $t = "[$count]$t";
      }
      return $t;
    }

    while(<>) {
      $_ =~ s|([\w./]+)|insert_ref($1)|eg;
      print $real_stdout $_;
    }
  ');
}

# Other global aliases
alias -g M='| m'
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

# Move up and down move through multi-line buffer or through history using
# LBUFFER as a prefix.
autoload -U my-history-search
zle -N my-up-line-or-history-search-backward my-history-search
zle -N my-down-line-or-history-search-forward my-history-search
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

# Show dots when the command line is completing so that we have some visual
# indication of when the shell is busy.
autoload -U expand-or-complete-with-dots
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

# Quote current line and current argument keeping the cursor on the same
# character.
autoload -U quote-chars
zle -N quote-current-arg quote-chars
zle -N quote-current-line quote-chars
# Alt-' quotes current argument
# Alt-' Alt-' quote entire line
bindkey "\e'" quote-current-arg
bindkey "\e'\e'" quote-current-line

# Expand real name of file
autoload -U modify-current-argument
current-arg-real-path() {
    modify-current-argument '$(realpath "$ARG" 2> /dev/null)'
}
zle -N current-arg-real-path
bindkey "^X^R" current-arg-real-path

# move with control
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

# delete with alt
bindkey "\ea" backward-kill-line
bindkey "\ee" kill-line
bindkey "\e[1;3C" kill-word
bindkey "\e[1;3D" backward-kill-word

WORDCHARS="${WORDCHARS:s#/#}"

# map shift-enter to ^J and then it will allow easy multiline editing.
bindkey "^J" self-insert

# directory colors
eval $(dircolors -b ~/.dircolors)

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
setopt ignoreeof
autoload -U bash-ctrl-d
zle -N bash-ctrl-d
bindkey "^D" bash-ctrl-d

# allow comments in the shell
setopt interactive_comments
# allow short loop syntax
setopt short_loops

# fancy mv
autoload -U zmv

# make fg work like in bash
fg() { builtin fg "${@/#(\%|)/%}" }

# helper function to determine how command line args are being split
args() { echo ${(j:\n:)@} }

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
autoload -U rationalise-dot
zle -N rationalise-dot
bindkey . rationalise-dot

# Ensure that rationalise dot doesn't break incremental history search
function history-incremental-search-backward () {
  bindkey . self-insert
  zle .history-incremental-search-backward
  bindkey . rationalise-dot
}
zle -N history-incremental-search-backward
bindkey "^R" history-incremental-search-backward

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
TIMEFMT="$(tput setaf 4)%E real  %U user  %S system  %P cpu  %MkB mem $(tput sgr0)$ %J"

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"

# editor setup
export EDITOR=vim
export VISUAL=vim
if [[ -n $(vim --version | grep +clientserver) ]] ; then
    vim() {
        local server_name=$$
        if [[ -n $STY ]] ; then
            server_name="$STY-$WINDOW-$$"
        fi
        command vim -X --servername "$server_name" "$@"
    }
else
  vim() {
    command vim -X "$@"
  }
fi
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
alias p=python3
alias pe='python3 ~/bin/python_eval'

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

# ack
export ACK_COLOR_LINENO="yellow"
export ACK_COLOR_FILENAME="green"
alias ackp="ack --pager=less"

# monitor

monitor() { watch -d -n1 -t "$@"; }

# screen/tmux commands

# commands for outside screen/tmux

# I use session_wrapper a lot
alias s="session_wrapper tmux"
_session_wrapper() {
    compadd - $(session_wrapper tmux --complete "$PREFIX")
}
compdef _session_wrapper session_wrapper

# screen/tmux specific setup
if [[ -n $STY ]] ; then
    source ~/.zsh/screen.zsh
elif [[ -n $TMUX ]] ; then
    source ~/.zsh/tmux.zsh
fi

# reload zshrc for the current shell
reload() { . ~/.zshrc }
# use SIGCONT because it is does not terminate the shell by default
trap 'touch "$HOME/.zshrc"' CONT

# full history file is used to create a verbose detailed record of my commands.
if [[ -z $FULLHISTFILE ]] ; then
    readonly FULLHISTFILE=~/._full_zsh_history
fi

if [[ -z $_ALREADY_LOADED ]] ; then
    session_info=
    if [[ -n $STY ]] ; then
        session_info=" screen:$STY"
    elif [[ -n $TMUX ]] ; then
        session_info=" tmux:$(tmux display-message -p '#S.#I')"
    fi
    cat <<<"$$ 0 $(date +%FT%T) $PWD \$ # PPID=$PPID SHLVL=$SHLVL ZSH_VERSION=$ZSH_VERSION$session_info" >> "$FULLHISTFILE"
    unset session_info
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

# For debugging bash scripts (must be defined before PROMPT4)
export PS4="\[$(tput setaf 5)\]+\[$(tput sgr0)\] "

# Rename prompt variables so that they don't confuse other subshells.
#   A visual bell is at the start, as tmux is configured to highlight the tab in
#   this case. This allows us to see when long running commands in another tab
#   completes.
PROMPT=$'\a$(_status_ps1)%F{blue}[%D{%H:%M}] [%j] %n@%m:$(_dir_ps1)$(__git_ps1)\n%h %(!.#.$) %f'
PROMPT2=$'%F{blue}> %f'
PROMPT4=$'%F{magenta}+%N:%i> %f'
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

# Syntax highlighting
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
