#!/bin/sh

cd "$(dirname "$0")/.." || exit
DOTFILES_ROOT=$(pwd -P)
# shellcheck source=tools
. "$DOTFILES_ROOT/scripts/tools"

# Fix permissions error
chmod +x /usr/local/opt/asdf/asdf.sh

# Add used plugins
asdf plugin add python
asdf plugin add java
asdf plugin add dasel https://github.com/asdf-community/asdf-dasel.git

# Add java versions
asdf install java openjdk-11
asdf install java adoptopenjdk-8.0.272+10
asdf install java adoptopenjdk-11.0.9+11

# Add python versions
asdf install python 3.7.9
asdf install python 3.9.0

# Dasel tool https://github.com/TomWright/dasel
asdf install dasel 1.12.2
asdf global dasel 1.12.2

# Symlink java to a global path
mkdir -p /usr/local/lib/jvm
link_file /Users/pablosanjose/.asdf/installs/java /usr/local/lib/jvm/java
