#!/bin/bash

if command -v code >/dev/null; then
    if [ "$(uname -s)" = "Darwin" ]; then
        VSCODE_HOME="$HOME/Library/Application Support/Code"
    else
        VSCODE_HOME="$HOME/.config/Code"
    fi
    mkdir -p "$VSCODE_HOME/User"

    ln -sf "$DOTFILES/vscode/settings.json" "$VSCODE_HOME/User/settings.json"
    ln -sf "$DOTFILES/vscode/keybindings.json" "$VSCODE_HOME/User/keybindings.json"
    ln -sf "$DOTFILES/vscode/snippets" "$VSCODE_HOME/User/"

    echo "  › Installing extensions from $DOTFILES/vscode/extensions.txt"
    tput setaf 2
    printf "    [ "
    while read -r module; do
        # TODO: hide output and use progress bar
        code --install-extension "$module" &
        >/dev/null
        printf "#"
    done <"$DOTFILES/vscode/extensions.txt"
    printf " ] \n"
    tput sgr0
    echo "  › Extensions installed"
fi
