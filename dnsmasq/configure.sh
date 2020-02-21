#!/bin/sh

# TODO: Fix for linux
[ "$(uname -s)" != "Darwin" ] && exit 0
mkdir -pv "$(brew --prefix)/etc"
ln -sf "${DOTFILES}/dnsmasq/dnsmasq.conf" "$(brew --prefix)/etc/dnsmasq.conf"

brew services start dnsmasq

[ -L "/etc/resolver" ] && exit 0
if command -v sudo >/dev/null; then
	sudo ln -sf "${DOTFILES}/dnsmasq/resolver/" "/etc/resolver"
fi
