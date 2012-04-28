# setup zsh for screen
# To be sourced from .zshrc

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
    local title="$*"
    if [[ -z $title ]] ; then
        title=$(basename "$PWD")
    fi
    screen -X title "$title"
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

# Send text to another window.
sendto() {
    local win="$1"
    shift
    if [[ -n $* ]] ; then
        screen -p "$win" -X stuff "$*"
    else
        screen -p "$win" -X stuff "$(cat)"
    fi
}

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
