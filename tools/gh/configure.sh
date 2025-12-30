#!/usr/bin/env bash

# Install Completions
if command -v gh >/dev/null 2>&1; then
    gh completion -s zsh >"$ZSH_EXTRA_COMPLETIONS/_gh"
else
    echo "gh command not found. Skipping completion installation."
fi
