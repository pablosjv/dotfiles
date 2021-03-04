#!/bin/sh

brew-bump() {
    tput bold
    echo "--> Bumping homebrew..."
    tput sgr0
    command brew update
    brew outdated | xargs brew fetch
    command brew upgrade
    brew cleanup
}

brew-cleanup() {
    tput bold
    echo "--> Cleanup homebrew..."
    tput sgr0
    (cd "$(brew --repo)" && git prune && git gc)
    command brew cleanup
    brew bundle cleanup --global --force
    rm -rf "$(brew --cache)"
}

brew-repair() {
    tput bold
    echo "--> Try to repair homebrew..."
    tput sgr0
    (cd "$(brew --repo)" && git fetch && git reset --hard origin/master)
    brew update
}

if command -v brew >/dev/null 2>&1; then
    brew() {
        case "$1" in
        cleanup)
            brew-cleanup
            ;;
        bump)
            brew-bump
            ;;
        repair)
            brew-repair
            ;;
        *)
            command brew "$@"
            ;;
        esac
    }
fi
