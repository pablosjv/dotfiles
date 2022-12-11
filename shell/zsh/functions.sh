#!/usr/bin/env bash

myip() {
    WIFI=$(ipconfig getifaddr en0)
    ETHERNET=$(ipconfig getifaddr en1)
    THUNDERBOLT=$(ipconfig getifaddr en2)
    echo "Public ip      = $(curl -s https://checkip.amazonaws.com/)"
    echo "Wifi ip        = ${WIFI:-No Connected}"
    echo "Ethernet ip    = ${ETHERNET:-No Connected}"
    echo "Thunderbolt ip = ${THUNDERBOLT:-No Connected}"
}

fix-completions() {
    autoload -Uz compinit
    compinit
    compinit -C
}
