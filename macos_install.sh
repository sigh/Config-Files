#!/bin/sh
# These are commands to help setup a new install on macos.

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
brew install tmux
brew install coreutils
brew install git-filter-repo
brew install watch
brew install imagemagick
brew install jekyll
brew install sqlite
brew install nasm
brew install gdb
brew install rename
brew install telnet
brew install jq

brew install --cask macfuse

pip3 install --upgrade pip
pip3 install --user ipython
pip3 install --user numpy
pip3 install --user autopep8

# Make dock appear instantly.
defaults write com.apple.Dock autohide -bool TRUE
defaults write com.apple.Dock autohide-delay -float 0
defaults write com.apple.Dock autohide-time-modifier -int 0
# Show hidden apps as transparent.
defaults write com.apple.Dock showhidden -bool TRUE
# Don't reorder spaces.
defaults write com.apple.Dock mru-spaces -bool FALSE
# Place dock on the right.
defaults write com.apple.Dock orientation right
# Dock magnification.
defaults write com.apple.Dock largesize -float 56
defaults write com.apple.Dock magnification -float 1
defaults write com.apple.Dock mineffect scale
# Restart dock to apply changes.
killall Dock

# Show hidden files in Finder
defaults write com.apple.Finder AppleShowAllFiles -bool TRUE
killall Finder

# Turn off 2-finger swipe/scroll as it's really annoying.
defaults write "Apple Global Domain" AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 2

ssh-add -K ~/.ssh/id_rsa

HOME_DIR=~
cat <<EOF >> ~/.profile
PATH="$HOME_DIR/bin:/usr/local/bin:\$PATH"
PATH="/usr/local/opt/coreutils/libexec/gnubin:\$PATH"
PATH="$HOME_DIR/Library/Python/3.7/bin:\$PATH"
PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:\$PATH"
EOF
