#!/usr/bin/env sh

set -e

if command -v cursor >/dev/null; then
    if [ "$(uname -s)" = "Darwin" ]; then
        CURSOR_HOME="$HOME/Library/Application Support/Cursor"
    else
        CURSOR_HOME="$HOME/.config/Cursor"
    fi
    mkdir -p "$CURSOR_HOME/User"
fi
