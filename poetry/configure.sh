#!/bin/sh

# Install Completions
poetry completions zsh > $(brew --prefix)/share/zsh/site-functions/_poetry
