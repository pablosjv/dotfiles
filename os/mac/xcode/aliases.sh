#!/usr/bin/env sh

alias xlist-devices="xcrun xctrace list devices"
alias xlist-iphone="xcrun xcdevice list | jq '.[] | select(.platform==\"com.apple.platform.iphoneos\") | {name, identifier, operatingSystemVersion}'"
alias xlist-sim="xcrun simctl list devices -j -v | jq '.devices | to_entries[].value[] | select(.isAvailable and (.deviceTypeIdentifier | contains(\"iPhone\"))) | {name, udid}'"
alias xlist-sim-booted="xcrun simctl list devices -j -v | jq '.devices | to_entries[].value[] | select(.isAvailable and .state==\"Booted\" and (.deviceTypeIdentifier | contains(\"iPhone\"))) | {name, udid}'"
