#!/usr/bin/env sh

# Add used plugins
asdf plugin add python
asdf plugin add poetry
asdf plugin add uv
asdf plugin-add golang
asdf plugin add java
asdf plugin-add nodejs
asdf plugin-add yarn
asdf plugin-add awscli
# Sops plugin for the asdf version manager
asdf plugin-add sops
# Pluging for faster env resolution https://github.com/asdf-community/asdf-direnv
asdf plugin-add direnv
# Dasel tool https://github.com/TomWright/dasel
asdf plugin add dasel

# Install all packages in ./etc/tools-versions
asdf install
