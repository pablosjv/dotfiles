#!/bin/sh

alias reload='exec "$SHELL" -l'
alias dot-date='git config --global dotfiles.lastupdate'
alias dot-refresh='${DOTFILES}/scripts/update'
alias dot-log='less -R ${DOTFILES}/dot-update.log'
alias e-dot='e ${DOTFILES}'
alias zsh-profile='(time zsh -i -c exit) 2>&1 >/dev/null | (head -10 ; tail -1)'

alias myip='curl https://checkip.amazonaws.com/'
