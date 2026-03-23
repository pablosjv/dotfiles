#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

# Install Completions
if command -v poetry >/dev/null 2>&1; then
    poetry completions zsh >"$ZSH_GENERATED_COMPLETIONS/_poetry"
    success "poetry completion installed."
else
    fail "poetry command not found. Skipping completion installation."
fi
