#!/usr/bin/env sh

if asdf; then
    # Install virtualenv in default asdf python
    "$(asdf where python)/bin/python" -m pip install --user --upgrade pip virtualenv
    asdf reshim python
fi
