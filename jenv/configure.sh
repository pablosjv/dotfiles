#!/bin/bash

# FIXME: Make it work in linux
[ "$(uname -s)" != "Darwin" ] && exit 0

# Hook Jenv to the shell of the script
source $DOTFILES/jenv/path.zsh

# Enable jenv plugins
jenv enable-plugin export
jenv enable-plugin springboot
jenv enable-plugin gradle
jenv enable-plugin sbt
jenv enable-plugin scala

for dir in /Library/Java/JavaVirtualMachines/*/; do
	java_version=${dir%*/} # remove the trailing "/"
	jenv add ${java_version}/Contents/Home
done

# Check everything is in order
jenv doctor
