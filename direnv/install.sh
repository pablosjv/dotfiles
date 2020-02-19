#!/bin/sh

[ -L ${HOME}/.config/direnv/lib ]  && exit 0
mkdir -p ~/.config/direnv
ln -sf "${HOME}/.dotfiles/direnv/lib/" "${HOME}/.config/direnv/lib"
