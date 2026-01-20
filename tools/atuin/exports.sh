#!/usr/bin/env sh

# Initialize Atuin shell integration
# This replaces the default ctrl-r and up arrow bindings with Atuin's search
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi
