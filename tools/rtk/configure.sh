#!/usr/bin/env sh

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

if command -v rtk >/dev/null 2>&1; then
    for agent in claude cursor; do
        info "Configuring rtk for $agent"
        rtk init --global --auto-patch --agent "$agent"
        success "$agent configured"
    done

    # NOTE: these require special handling
    info "Configuring rtk for Codex CLI"
    rtk init --global --codex
    success "Codex configured"
    info "Configuring rtk for Gemini CLI"
    rtk init --global --auto-patch --gemini
    success "Gemini configured"

    success "rtk configured."
else
    warning "rtk not found. Skipping configuration."
fi
