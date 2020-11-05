#!/bin/sh

if ! command -v poetry >/dev/null 2>&1; then
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
fi
