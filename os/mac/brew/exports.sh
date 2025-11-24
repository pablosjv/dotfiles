#!/usr/bin/env sh

export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Hide hints on homebrew behavior
export HOMEBREW_NO_ENV_HINTS=1

# Disable Homebrew's auto-update
export HOMEBREW_NO_AUTO_UPDATE=1
