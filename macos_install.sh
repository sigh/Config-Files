#!/bin/sh
# These are commands to help setup a new install on macos.

# Reset path in case it is mangled
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# Uninstall homebrew to start from a clean slate
# curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
brew install -y git
brew install -y tmux
brew install -y coreutils
brew install -y git-filter-repo
brew install -y watch
brew install -y imagemagick
brew install -y jekyll
brew install -y sqlite
brew install -y nasm
brew install -y gdb
brew install -y rename
brew install -y telnet
brew install -y jq
brew install -y node
brew install -y fzf
brew install -y git-delta
brew install -y jj
brew install -y fd
brew install -y zoxide
brew install -y ripgrep
brew install -y pipx
brew install -y starship

brew install -y --cask macfuse

brew install -y ipython
brew install -y numpy
brew install -y autopep8

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

# Don't write DS_Store files to network shares.
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

ssh-add -K ~/.ssh/id_rsa

# Copy fonts to the user fonts directory.
mkdir -p ~/Library/Fonts
cp -r fonts/* ~/Library/Fonts/

HOME_DIR=~
cat <<EOF >> ~/.profile
PATH="/usr/local/bin:\$PATH"
PATH="$HOME_DIR/bin:\$PATH"
PATH="$HOME_DIR/.local/bin:\$PATH"
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:\$PATH"
PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:\$PATH"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
EOF

sudo chsh "$(which zsh)" "$USER"
