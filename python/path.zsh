#!/bin/sh

# NOTE: include python 3 library in PATH not necesasary with asdf reshim
# export PATH="$PATH:$HOME/Library/Python/3.8/bin"

######### Autho switch configuration  #########
# NOTE: install default packages for development
export AUTOSWITCH_DEFAULT_REQUIREMENTS="$HOME/.requirements.txt"
# NOTE: Use asdf python version for that directory
export AUTOSWITCH_DEFAULT_PYTHON="${HOME}/.asdf/shims/python"
