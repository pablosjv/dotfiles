#!/usr/bin/env sh

# shellcheck source=/usr/local/opt/asdf/libexec/asdf.sh
. "$(brew --prefix asdf)/libexec/asdf.sh"

# Automatically sets JAVA_HOME
. ~/.asdf/plugins/java/set-java-home.zsh
