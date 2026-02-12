#!/usr/bin/env bash

# Install Completions
if command -v pnpm >/dev/null 2>&1; then
    pnpm completion zsh >"$ZSH_EXTRA_COMPLETIONS/_pnpm"
else
    echo "pnpm command not found. Skipping completion installation."
fi
