#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

# Install Completions
if command -v gh >/dev/null 2>&1; then
    info "Installing github cli completions"
    gh completion -s zsh >"$ZSH_GENERATED_COMPLETIONS/_gh"
    success "github cli completions installed."
else
    warning "gh command not found. Skipping completion installation."
fi
