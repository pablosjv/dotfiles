#!/bin/sh

log() {
    tput bold
    echo ${1}
    tput sgr0
}

brew-bump() {
    log "--> Bumping homebrew..."
    command brew update
    brew outdated | xargs brew fetch
    brew bundle install --verbose --global
    command brew upgrade
    command brew upgrade --cask --greedy
    brew cleanup
}

brew-cleanup() {
    log "--> Cleanup homebrew..."
    (cd "$(brew --repo)" && git prune && git gc)
    command brew cleanup
    brew bundle cleanup --global --force --zap
    rm -rf "$(brew --cache)"
}

brew-repair() {
    log "--> Try to repair homebrew..."
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
