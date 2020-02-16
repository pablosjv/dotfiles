#!/bin/sh

# FIXME: Make it work in linux
[ "$(uname -s)" != "Darwin" ] && exit 0
# Enable jenv plugins
jenv enable-plugin export
jenv enable-plugin springboot
jenv enable-plugin gradle
jenv enable-plugin sbt
jenv enable-plugin scala

for dir in /Library/Java/JavaVirtualMachines/*/; do
    java_version=${dir%*/} # remove the trailing "/"
    jenv add ${java_version}/Contents/Home
done
