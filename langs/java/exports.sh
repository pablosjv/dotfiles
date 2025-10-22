#!/usr/bin/env sh

# Maven
export MAVEN_OPTS="-Xmx1024m"

# Android
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"

. $HOME/.asdf/plugins/java/set-java-home.zsh
