#!/usr/bin/env sh
set -e

jq --indent 4 -S <"$DOTFILES/editors/vscode/settings.json" >"$DOTFILES/editors/vscode/settings.json.new"
mv "$DOTFILES/editors/vscode/settings.json.new" "$DOTFILES/editors/vscode/settings.json"
