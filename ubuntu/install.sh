#!/bin/sh

[ "$(uname -s)" = "Darwin" ] && exit 0
# shellcheck disable=SC2046
apt-get install \
    direnv \
    openjdk-8-jdk
