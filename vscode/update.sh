#!/bin/sh
[ "$(uname -s)" != "Darwin" ] && exit 0
set -e
code --list-extensions >"$DOTFILES/vscode/extensions.txt"
jq --indent 4 -S <"$DOTFILES/vscode/settings.json" >"$DOTFILES/vscode/settings.json.new"
mv "$DOTFILES/vscode/settings.json.new" "$DOTFILES/vscode/settings.json"
