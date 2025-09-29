#!/usr/bin/env sh

# shellcheck source=scripts/tools
. "$DOTFILES/scripts/tools"

check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        fail "Not in a git repository"
    fi
}

branch_exists() {
    branch="$1"
    if [ -z "$branch" ]; then
        fail "Branch is required"
    fi
    git show-ref --verify --quiet "refs/heads/$branch" || git show-ref --verify --quiet "refs/remotes/origin/$branch"
}
