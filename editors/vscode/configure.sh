#!/usr/bin/env sh

install_vscode_extensions() {
    EXTENSIONS_FILE="$DOTFILES/editors/vscode/extensions.txt"
    echo "  › Installing extensions from $EXTENSIONS_FILE"
    tput setaf 2
    printf "    [ "
    while read -r module; do
        # TODO: hide output and use progress bar
        code --install-extension "$module" >/dev/null 2>&1
        printf "#"
    done <"$EXTENSIONS_FILE"
    printf " ] \n"
    tput sgr0
    echo "  › Extensions installed"
}

if command -v code >/dev/null; then
    if [ "$(uname -s)" = "Darwin" ]; then
        VSCODE_HOME="$HOME/Library/Application Support/Code"
    else
        VSCODE_HOME="$HOME/.config/Code"
    fi
    mkdir -p "$VSCODE_HOME/User"
    # NOTE: extensions are installed with homebrew now
    # install_vscode_extensions
fi
