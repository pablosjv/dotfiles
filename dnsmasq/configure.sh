#!/bin/sh
[ "$(uname -s)" != "Darwin" ] && exit 0
brew services start dnsmasq
cp ${DOTFILES}/dnsmasq/resolver/* /etc/resolver/
