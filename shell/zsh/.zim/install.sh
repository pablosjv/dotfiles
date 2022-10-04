#!/usr/bin/env sh

if ! command -v ls "${HOME}/.zim" >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

zimfw uninstall -v && zimfw upgrade -v && zimfw install -v
