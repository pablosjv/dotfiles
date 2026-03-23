#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

# Install Completions
if command -v pnpm >/dev/null 2>&1; then
    info "Installing pnpm completions"
    pnpm completion zsh >"$ZSH_GENERATED_COMPLETIONS/_pnpm"
    success "pnpm completions installed."
else
    warning "pnpm command not found. Skipping completion installation."
fi
