#!/usr/bin/env sh

[ "$(uname -s)" != "Darwin" ] && exit 0
if ! command -v brew >/dev/null 2>&1; then
    echo "› Installing Hombrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! brew bundle check --global --verbose 2>&1; then
    echo "› Installing Hombrew packages from Brewfile"
    brew bundle install \
        --verbose \
        --global \
        --cleanup \
        --no-upgrade
fi
