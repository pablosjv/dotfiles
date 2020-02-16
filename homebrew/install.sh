#!/bin/sh

[ "$(uname -s)" != "Darwin" ] && exit 0
if ! command -v brew >/dev/null 2>&1; then
    echo "› Installing Hombrew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "› Installing Hombrew packages from Brewfile"
brew bundle -v --file="$HOME/.dotfiles/homebrew/Brewfile"

echo "› Update Brewfile"
brew bundle dump --force --describe --file="$HOME/.dotfiles/homebrew/Brewfile"
