#!/bin/sh

! test -e /usr/local/bin/aws_completer && exit 0
autoload bashcompinit
bashcompinit
# shellcheck disable=SC1090,SC1091
complete -C '/usr/local/bin/aws_completer' aws
