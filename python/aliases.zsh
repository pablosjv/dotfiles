#!/bin/sh
# NOTE: depends on zsh-autoswitching mkvenv alias
alias mkvenv="PYTHONPATH='' mkvenv"
alias remkvenv='rmvenv && mkvenv'

alias fix-pipenv="pipenv --rm && PYTHONPATH='' pipenv install --dev"
