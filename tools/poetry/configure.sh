#!/usr/bin/env zsh

# Install Completions
poetry completions zsh >! $ZSH_EXTRA_COMPLETIONS/_poetry
