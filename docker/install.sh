#!/bin/sh
mkdir -p "$HOME/.docker/completions"

if command -v docker-compose >/dev/null 2>&1; then
    curl -sL https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose \
        -o "$HOME/.docker/completions/_docker-compose"
fi
if command -v docker >/dev/null 2>&1; then
    curl -sL https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker \
        -o "$HOME/.docker/completions/_docker"
fi
if command -v colima >/dev/null 2>&1; then
    # NOTE: this overwrites if there is nerdctl installed
    colima nerdctl install -f
    mkdir -p "$HOME/.colima/completions"
    colima completion zsh > "$HOME/.docker/completions/_colima"
fi
