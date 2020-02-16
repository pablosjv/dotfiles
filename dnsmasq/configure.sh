#!/bin/sh
cp ${DOTFILES}/dnsmasq/resolver/* /etc/resolver/

[ "$(uname -s)" != "Darwin" ] && exit 0
brew services start dnsmasq
