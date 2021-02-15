#!/bin/sh

if [ "$(uname -s)" != "Darwin" ]; then
    curl -sL https://git.io/antibody | sudo sh -s -- -b /usr/local/bin
fi
