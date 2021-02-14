#!/bin/sh
[ "$(uname -s)" != "Darwin" ] && exit 0
sed "s;$HOME;/Users/Pablo;g" \
    "$DOTFILES"/iterm/com.googlecode.iterm2.plist >"$DOTFILES"/iterm/com.googlecode.iterm2.plist.example
