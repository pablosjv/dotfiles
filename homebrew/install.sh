#!/bin/sh

[ "$(uname -s)" != "Darwin" ] && exit 0
if ! brew >/dev/null; then
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew bundle dump --force --describe
