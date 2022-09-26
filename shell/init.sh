#!/usr/bin/env bash

# This is a useful file to have the same aliases/functions in bash and zsh
# shellcheck source=/dev/null
for f in "${DOTFILES}"/**/{exports.sh,functions.sh,aliases.sh}; do source "$f"; done
