#!/bin/sh

alias reload='exec "$SHELL" -l'
alias ls-ports='lsof -i -P | grep --color=never LISTEN'
