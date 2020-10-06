#!/bin/sh

# Fix permissions error
chmod +x /usr/local/opt/asdf/asdf.sh

# Add used plugins
asdf plugin add python
asdf plugin add java

# Add java versions
asdf install java openjdk-11
