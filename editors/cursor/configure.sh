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

DOTFILES_CURSOR_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure all hook scripts are executable.
chmod +x "$DOTFILES_CURSOR_DIR/hooks/"*.sh "$DOTFILES_CURSOR_DIR/hooks/"*.py 2>/dev/null || true
