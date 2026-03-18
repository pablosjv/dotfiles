#!/usr/bin/env sh

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

[ "$(uname -s)" != "Darwin" ] && exit 0
if ! command -v brew >/dev/null 2>&1; then
    info "Installing Hombrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! brew bundle check --global --verbose 2>&1; then
    info "Installing Hombrew packages from Brewfile"
    brew bundle install \
        --verbose \
        --global \
        --cleanup \
        --no-upgrade
fi
