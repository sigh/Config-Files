#!/bin/sh
# These are commands to help setup a new install on macos.
set -eu

cd "$(dirname "$0")"

# Reset path in case it is mangled
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Homebrew and Ruby builds need the Command Line Tools.
if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    printf '%s\n' 'Finish installing the Command Line Tools, then rerun this script.' >&2
    exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    brew_installer=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
    /bin/bash -c "$brew_installer"
fi
eval "$(brew shellenv bash)"

brew install -y git
brew install -y bash-completion
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

brew install -y chruby ruby-install
if [ ! -x "$HOME/.rubies/ruby-3.4.1/bin/ruby" ]; then
    ruby-install ruby 3.4.1
fi

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
# Hot corners: top left Mission Control, top right Lock Screen,
# bottom left Application Windows, bottom right Desktop.
defaults write com.apple.Dock wvous-tl-corner -int 2
defaults write com.apple.Dock wvous-tl-modifier -int 0
defaults write com.apple.Dock wvous-tr-corner -int 13
defaults write com.apple.Dock wvous-tr-modifier -int 0
defaults write com.apple.Dock wvous-bl-corner -int 3
defaults write com.apple.Dock wvous-bl-modifier -int 0
defaults write com.apple.Dock wvous-br-corner -int 4
defaults write com.apple.Dock wvous-br-modifier -int 0
# Restart dock to apply changes.
killall Dock

# Show hidden files, the path bar, and the status bar in Finder.
defaults write com.apple.Finder AppleShowAllFiles -bool TRUE
defaults write com.apple.Finder ShowPathbar -bool TRUE
defaults write com.apple.Finder ShowStatusBar -bool TRUE
# Open new Finder windows to the home folder.
defaults write com.apple.Finder NewWindowTarget -string PfHm
# Show all filename extensions and disable double-space periods.
defaults write -g AppleShowAllExtensions -bool TRUE
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool FALSE
killall Finder

# Turn off 2-finger swipe/scroll as it's really annoying.
defaults write "Apple Global Domain" AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 2
# Enable tap to click on built-in trackpad.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool TRUE

# Show the day of the week in the menu bar clock.
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool TRUE
killall SystemUIServer

# Keep the Mac awake on AC power and sleep the display after 60 minutes.
sudo pmset -c sleep 0 displaysleep 60

# Don't write DS_Store files to network shares.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool TRUE

if [ -f "$HOME/.ssh/id_rsa" ]; then
    ssh-add -K "$HOME/.ssh/id_rsa" || printf '%s\n' 'Could not add the SSH key to the agent.' >&2
fi

# Copy fonts to the user fonts directory.
mkdir -p "$HOME/Library/Fonts"
find fonts -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp -f {} "$HOME/Library/Fonts/" \;

HOME_DIR=~
cat <<EOF >> ~/.profile
PATH="/usr/local/bin:\$PATH"
PATH="$HOME_DIR/bin:\$PATH"
PATH="$HOME_DIR/.local/bin:\$PATH"
PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:\$PATH"
PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:\$PATH"
eval "\$($HOMEBREW_PREFIX/bin/brew shellenv bash)"
EOF

if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    sudo chsh -s "$(command -v zsh)" "$(id -un)"
fi
