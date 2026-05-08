#!/usr/bin/env sh

set -e

HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure all hook scripts are executable.
chmod +x "$HARNESS_DIR/hooks/"*.py 2>/dev/null || true
chmod +x "$HARNESS_DIR/hooks/hook_lib/"*.py 2>/dev/null || true
chmod +x "$HARNESS_DIR/config-diff.sh" 2>/dev/null || true

# Fix CLI homebrew install -> https://forum.cursor.com/t/cursor-cli-installation-method-zsh-vs-bash/158601
if [ "$(uname -s)" = Darwin ] && [ -d /opt/homebrew/Caskroom/cursor-cli ]; then
    xattr -cr /opt/homebrew/Caskroom/cursor-cli/
fi
