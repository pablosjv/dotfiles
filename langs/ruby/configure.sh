#!/usr/bin/env sh

ruby_version=$(asdf current ruby --no-header | awk '{print $2}')
GEM_PATH="$HOME/.gem/ruby/$ruby_version"
mkdir -p $GEM_PATH
