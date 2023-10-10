#!/usr/bin/env sh

# Fix permissions error
chmod +x "$(brew --prefix asdf)/asdf.sh"

# Add used plugins
asdf plugin add python
asdf plugin add poetry
asdf plugin-add golang
asdf plugin add java
asdf plugin-add scala
asdf plugin-add sbt
asdf plugin-add maven
asdf plugin-add gradle
asdf plugin-add nodejs
asdf plugin-add yarn
asdf plugin-add awscli
asdf plugin-add sops
# Dasel tool https://github.com/TomWright/dasel
asdf plugin add dasel

# Install all packages in ./etc/tools-versions
asdf install

# Add legacy scala versions
asdf install scala 2.13.10

# Add legacy python versions
asdf install python 3.7.9
asdf install python 3.8.10
