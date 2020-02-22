#!/bin/sh

[ "$(uname -s)" != "Linux" ] && exit 0
git clone https://github.com/gcuisinier/jenv.git ~/.jenv
