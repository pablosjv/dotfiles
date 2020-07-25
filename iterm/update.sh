#!/bin/sh
[ "$(uname -s)" != "Darwin" ] && exit 0
cp -f "$DOTFILES"/iterm/com.googlecode.iterm2.plist \
	"$DOTFILES"/iterm/com.googlecode.iterm2.plist.example
