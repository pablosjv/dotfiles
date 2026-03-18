#!/usr/bin/env bash

[ "$(uname -s)" != "Darwin" ] && exit 0

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

info "Update Brewfile"
brew bundle dump \
    --verbose \
    --force \
    --describe \
    --no-restart \
    --global

info "Filtering Brewfile"
"$DOTFILES_ROOT/scripts/brew" bundle-clean

info "Cleaning up"
brew bundle cleanup --global --force --zap
brew cleanup --prune=all
success "Done"
