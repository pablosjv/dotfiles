#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

# Install Completions
if command -v glab >/dev/null 2>&1; then
    info "Installing glab completions"
    glab completion -s zsh >"$ZSH_GENERATED_COMPLETIONS/_glab"
    success "glab completions installed."
else
    warning "glab command not found. Skipping completion installation."
fi
