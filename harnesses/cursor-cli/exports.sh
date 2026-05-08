#!/usr/bin/env sh

# NOTE: This is the default for the cursor cli. Setting it like this makes sure
# it is not overwritten by the XDG_CONFIG_HOME. It allows for consistency with
# the cursor editor config dir which cannot be modified (i.e. https://cursor.com/docs/hooks#quickstart).
export CURSOR_CONFIG_DIR="${HOME}/.cursor"
