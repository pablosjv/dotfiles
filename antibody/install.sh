#!/bin/sh
if command -v brew >/dev/null 2>&1; then
	brew tap | grep -q 'getantibody/tap' || brew tap getantibody/tap
	brew install antibody
else
	if command -v sudo >/dev/null; then
		alias sh="sudo sh"
	fi
	curl -sL https://git.io/antibody | sh -s -- -b /usr/local/bin
fi
antibody bundle <"$DOTFILES/antibody/bundles.sh" >~/.zsh_plugins.sh
antibody update
