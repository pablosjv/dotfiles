#!/bin/sh
[ "$(uname -s)" != "Darwin" ] && exit 0
set -e
code --list-extensions >"$DOTFILES/vscode/extensions.txt"
