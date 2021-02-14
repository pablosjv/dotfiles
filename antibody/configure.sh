#!/bin/sh

rm -rf "$(antibody home)"
antibody bundle <"$DOTFILES/antibody/bundles.sh" >"${HOME}/.zsh_plugins.sh"
antibody update
