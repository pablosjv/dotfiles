#!/bin/bash

# Hook Jenv to the shell of the script
# shellcheck disable=SC1090
source "${DOTFILES}/jenv/path.zsh"

# Enable jenv plugins
# jenv enable-plugin export
jenv enable-plugin springboot
jenv enable-plugin gradle
jenv enable-plugin sbt
jenv enable-plugin scala

if [ "$(uname -s)" == "Darwin" ]; then
	java_path="/Library/Java/JavaVirtualMachines/*/Contents/Home"
else
	java_path="/usr/lib/jvm/*"
fi

for java_version in $java_path; do
	jenv add "${java_version}"
done

# Check everything is in order
jenv doctor
