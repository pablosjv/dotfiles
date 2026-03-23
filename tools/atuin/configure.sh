#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

# Install Atuin Completions
if command -v atuin >/dev/null 2>&1; then
    info "Installing Atuin completions"
    atuin gen-completions --shell zsh >"$ZSH_GENERATED_COMPLETIONS/_atuin"
    success "Atuin completions installed."
else
    warning "atuin command not found. Skipping completion installation."
fi
