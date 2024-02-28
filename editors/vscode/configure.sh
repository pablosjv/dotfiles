#!/usr/bin/env sh

set -e

if command -v code >/dev/null; then
    if [ "$(uname -s)" = "Darwin" ]; then
        VSCODE_HOME="$HOME/Library/Application Support/Code"
    else
        VSCODE_HOME="$HOME/.config/Code"
    fi
    mkdir -p "$VSCODE_HOME/User"
fi
