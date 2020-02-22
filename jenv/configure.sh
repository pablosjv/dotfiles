#!/bin/bash

# Hook Jenv to the shell of the script
# shellcheck disable=SC1090
source "${DOTFILES}/jenv/path.zsh"

# Enable jenv plugins
jenv enable-plugin export
jenv enable-plugin springboot
jenv enable-plugin gradle
jenv enable-plugin sbt
jenv enable-plugin scala

for java_version in /Library/Java/JavaVirtualMachines/*; do
	if [ "$(uname -s)" == "Darwin" ]; then
		jenv add "${java_version}/Contents/Home"
	else
		jenv add "${java_version}"
	fi
done

# Check everything is in order
jenv doctor
