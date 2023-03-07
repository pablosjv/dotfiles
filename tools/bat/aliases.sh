#!/usr/bin/env sh

alias cat="bat"

alias bathelp='bat --plain --language=help'

help() {
    "$@" --help 2>&1 | bathelp
}
