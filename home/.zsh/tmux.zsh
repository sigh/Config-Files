# setup zsh for tmux
# To be sourced from .zshrc

sessionname() {
    tmux rename-session "$@"
}

title() {
    local title="$*"
    if [[ -z $title ]] ; then
        title=$(basename "$PWD")
    fi
    tmux rename-window "$title"
}

scrollback() {
    setopt localtraps
    local filename="$(mktemp)"
    trap "rm -f -- '$filename'" 0
    trap 'exit 2' 1 2 3 15
    tmux capture-pane -S -32000
    tmux save-buffer "$filename"
    tmux delete-buffer
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

# monitor activity on a command
monitor() {
    trap "tmux setw monitor-activity off" 0
    trap 'exit 2' 1 2 3 15
    tmux setw monitor-activity on
    watch -n1 -d -t "$@"
}
