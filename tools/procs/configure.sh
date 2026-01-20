#!/usr/bin/env bash

# Install Completions
if command -v procs >/dev/null 2>&1; then
    procs --gen-completion-out zsh >"$ZSH_EXTRA_COMPLETIONS/_procs"
else
    echo "procs command not found. Skipping completion installation."
fi
