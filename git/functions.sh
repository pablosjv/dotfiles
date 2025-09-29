#!/usr/bin/env bash

# shellcheck source=scripts/tools
. "$DOTFILES/scripts/tools"
. "$DOTFILES/git/_helpers.sh"

git-undo() {
    N_COMMITS="${1:-1}"
    git reset --soft HEAD~"${N_COMMITS}"
}

git-lb() {
    BRANCH="${1:-master}"
    git log --pretty=format:'- %s' --no-merges --first-parent ${BRANCH}..HEAD
}
