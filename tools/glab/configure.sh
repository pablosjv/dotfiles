#!/usr/bin/env bash

# Install Completions
if command -v glab >/dev/null 2>&1; then
    glab completion -s zsh >"$ZSH_EXTRA_COMPLETIONS/_glab"
else
    echo "glab command not found. Skipping completion installation."
fi
