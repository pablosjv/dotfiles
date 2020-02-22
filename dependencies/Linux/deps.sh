#!/bin/sh

if command -v sudo >/dev/null; then
	alias apt-get="sudo apt-get"
fi

apt-get update >/dev/null
apt-get install -y zsh git make curl tar >/dev/null
