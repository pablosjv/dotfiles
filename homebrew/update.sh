#!/bin/sh

[ "$(uname -s)" != "Darwin" ] && exit 0
echo "› Update Brewfile"
brew bundle dump --force --describe --file="$HOME/.dotfiles/homebrew/Brewfile"
