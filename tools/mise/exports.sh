#!/usr/bin/env sh

# Check if we are in an interactive session
if [ -t 0 ]; then
    # echo "Interactive session"
    eval "$(mise activate zsh)" # this sets up interactive sessions
else
    # NOTE: for some reason, vscode/cursor are not interactive sessions, so we need to use the shims
    # echo "Non-interactive session"
    eval "$(mise activate zsh --shims)" # this sets up non-interactive sessions
fi

# NOTE: workaround for mise to be compatible with direnv `use node` directive
export NODE_VERSIONS="${MISE_DATA_DIR:-$HOME/.local/share/mise}/installs/node"
export NODE_VERSION_PREFIX=""
