#!/bin/sh
if [ "$(uname -s)" = "Darwin" ]; then
    echo "› Antibody should have been installed from hombrew"
else
    # Set this condition in case we are testing this from a container
    if command -v sudo >/dev/null; then
        alias sh="sudo sh"
    fi
    curl -sL https://git.io/antibody | sh -s -- -b /usr/local/bin
fi
antibody bundle <"$DOTFILES/antibody/bundles.sh" >~/.zsh_plugins.sh
antibody update
