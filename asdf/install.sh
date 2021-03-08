#!/bin/sh

# NOTE: Linux only installation
[ "$(uname -s)" != "Linux" ] && exit 0
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf || exit
git checkout "$(git describe --abbrev=0 --tags)"
asdf update
