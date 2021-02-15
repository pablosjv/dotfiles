#!/bin/sh

rm -rf "$(antibody home)"
antibody bundle <"$DOTFILES/antibody/bundles.txt" >"${HOME}/.zsh_plugins.sh"
antibody update
