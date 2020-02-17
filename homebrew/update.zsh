#!/bin/sh

echo "› Update Brewfile"
brew bundle dump --force --describe --file="$HOME/.dotfiles/homebrew/Brewfile"
