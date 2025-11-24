#!/usr/bin/env sh

. ${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh
# export GOROOT=/usr/local/opt/go/libexec
# export GOPATH="$PROJECTS/go"

export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
