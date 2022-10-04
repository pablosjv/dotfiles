#!/usr/bin/env sh

# shellcheck source=/usr/local/opt/asdf/asdf.sh
. "$(brew --prefix asdf)/asdf.sh"

# Automatically sets JAVA_HOME
. ~/.asdf/plugins/java/set-java-home.zsh
