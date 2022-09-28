#!/usr/bin/env sh

. "$DOTFILES/shell/source/.aliases.sh"
. "$DOTFILES/shell/source/.exports.sh"
. "$DOTFILES/shell/source/.functions.sh"

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
# shellcheck disable=SC1090
[ -f ~/.localrc ] && . ~/.localrc
