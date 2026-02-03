#!/bin/sh
# Minimal install for rc configs to run on Linux (Debian/Ubuntu)

sudo apt-get update
sudo apt-get install -y \
    git \
    vim \
    tmux \
    zsh \
    fzf \
    zoxide \
    jq

# Set up PATH in .profile
cat <<'EOF' >> ~/.profile
PATH="$HOME/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
EOF

# Change shell to zsh
chsh -s "$(which zsh)"

echo "Install starship with: curl -sS https://starship.rs/install.sh | sh"
