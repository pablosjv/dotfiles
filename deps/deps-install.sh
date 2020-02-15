#!/bin/sh

OS = "$(uname -s)"
sh ${DOTFILES}/deps/${OS}/deps-install.sh
