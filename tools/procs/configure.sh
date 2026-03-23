#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

# Install Completions
if command -v procs >/dev/null 2>&1; then
    info "Installing procs completions"
    procs --gen-completion-out zsh >"$ZSH_GENERATED_COMPLETIONS/_procs"
    success "procs completions installed."
else
    warning "procs command not found. Skipping completion installation."
fi
