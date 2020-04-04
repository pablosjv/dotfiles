#!/bin/sh
alias reload='exec "$SHELL" -l'
alias dot-date='git config --global dotfiles.lastupdate'
alias dot-refresh='${DOTFILES}/scripts/update'
alias dot-log='less -R ${DOTFILES}/dot-update.log'
alias e-dot='e ${DOTFILES}'
