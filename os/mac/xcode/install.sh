#!/usr/bin/env bash

set -e

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

info running instalation of command line tools
xcode-select --install || user "Error running the install: probably because it is already installed"

sudo xcodebuild -license accept || true

# === Install Xcode version with credentials ===
XCODE_VERSION="26.3"
info "> Checking Xcode version $XCODE_VERSION..."

if ! xcodes installed | grep -q "$XCODE_VERSION"; then
    if [[ -z "$XCODES_USERNAME" || -z "$XCODES_PASSWORD" ]]; then
        fail "⚠️ Environment variables XCODES_USERNAME and/or XCODES_PASSWORD are not set. Skipping Xcode installation."
    else
        info "Installing Xcode $XCODE_VERSION..."
        xcodes install $XCODE_VERSION
    fi
else
    success "Xcode $XCODE_VERSION already installed ✓"
fi

info "Selecting Xcode $XCODE_VERSION..."
xcodes select $XCODE_VERSION
success "Xcode $XCODE_VERSION already selected ✓"

# === Install Simulator ===
info "> Checking iOS Simulator 18.2..."
if ! xcodes runtimes | grep -q "iOS 18.2"; then
    info "Installing iOS Simulator 18.2..."
    xcodes runtimes install "iOS 18.2" || fail "⚠️ Could not install iOS 18.2 simulator. You may need to do this manually."
else
    success "iOS Simulator 18.2 already installed ✓"
fi
