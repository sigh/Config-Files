#!/bin/sh
# These are commands to help setup a new install on osx.

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
brew install tmux
brew install coreutils

pip3 install --user ipython

HOME_DIR=~
cat <<EOF >> ~/.profile
PATH="$HOME_DIR/bin:/usr/local/bin:\$PATH"
PATH="/usr/local/opt/coreutils/libexec/gnubin:\$PATH"
PATH="$HOME_DIR/Library/Python/3.7/bin:\$PATH"
EOF
