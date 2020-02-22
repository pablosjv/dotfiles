#!/bin/sh

if [ "$(uname -s)" != "Darwin" ]; then
    sudo curl -sL https://git.io/antibody | sh -s -- -b /usr/local/bin
fi
