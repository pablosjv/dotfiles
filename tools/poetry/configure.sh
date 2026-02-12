#!/usr/bin/env bash

# Install Completions
if command -v poetry >/dev/null 2>&1; then
    poetry completions zsh >"$ZSH_EXTRA_COMPLETIONS/_poetry"
    echo "poetry completion installed."
else
    echo "poetry command not found. Skipping completion installation."
fi
