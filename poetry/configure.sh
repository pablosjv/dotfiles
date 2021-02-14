#!/bin/sh

export PATH="$HOME/.poetry/bin:$PATH"
# Install Completions
poetry completions zsh >$(brew --prefix)/share/zsh/site-functions/_poetry
