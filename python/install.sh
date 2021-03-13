#!/usr/bin/env sh

MODULE_INSTALL_ROOT="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)"

DOTFILES_ROOT="$(
    cd -- "$(dirname "$0")/.." >/dev/null 2>&1 || return
    pwd -P
)"

# shellcheck source=../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

if asdf >/dev/null 2>&1; then
    asdf reshim python
fi

mkdir -p "${HOME}/.config/pip"
link_file "${MODULE_INSTALL_ROOT}/pip.conf" "${HOME}/.config/pip/pip.conf"
