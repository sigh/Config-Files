#!/bin/bash
# Simple VS Code config backup script for macOS
# Copies settings.json and keybindings.json from VS Code to configs/vscode/

# Paths
VSCODE_USER="$HOME/Library/Application Support/Code/User"
REPO_VSCODE="$(dirname "$0")/configs/vscode"

# Create directory if needed
mkdir -p "$REPO_VSCODE"

# Copy files
for file in "settings.json" "keybindings.json"; do
    src="$VSCODE_USER/$file"
    dst="$REPO_VSCODE/$file"

    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
        echo "✓ Saved $file"
    else
        echo "⚠ $file not found"
    fi
done
