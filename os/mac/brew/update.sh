#!/usr/bin/env sh

[ "$(uname -s)" != "Darwin" ] && exit 0
echo "› Update Brewfile"
brew bundle dump \
    --verbose \
    --force \
    --describe \
    --no-restart \
    --global
