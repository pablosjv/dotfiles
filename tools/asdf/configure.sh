#!/usr/bin/env sh

# Fix permissions error
chmod +x "$(brew --prefix asdf)/asdf.sh"

# Add used plugins
asdf plugin add python
asdf plugin add java
asdf plugin add dasel https://github.com/asdf-community/asdf-dasel.git

# Add java versions
asdf install java openjdk-11

# Add python versions
asdf install python 3.7.9
asdf install python 3.8.10
asdf install python 3.10.1

# Dasel tool https://github.com/TomWright/dasel
asdf install dasel 1.12.2
asdf global dasel 1.12.2