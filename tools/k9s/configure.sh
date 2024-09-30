#!/usr/bin/env sh

OUT="${K9S_CONFIG_DIR}/skins"
mkdir -p "$OUT"
curl -s -L https://github.com/catppuccin/k9s/archive/main.tar.gz | tar xz -C "$OUT" --strip-components=2 k9s-main/dist
