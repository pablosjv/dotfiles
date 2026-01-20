#!/usr/bin/env bash

# Install Atuin Completions
if command -v atuin >/dev/null 2>&1; then
    atuin gen-completions --shell zsh >"$ZSH_EXTRA_COMPLETIONS/_atuin"
else
    echo "atuin command not found. Skipping completion installation."
fi
