#!/usr/bin/env bash

set -e

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=tools
. "$DOTFILES_ROOT/scripts/tools"

info running instalation of command line tools
xcode-select --install || user "Error running the install: probably because it is already installed"

sudo xcodebuild -license accept || true

# === Install Xcode 16.2 with credentials ===
info "> Checking Xcode 16.2..."

if ! xcodes installed | grep -q "16.2"; then
  if [[ -z "$XCODES_USERNAME" || -z "$XCODES_PASSWORD" ]]; then
    fail "⚠️ Environment variables XCODES_USERNAME and/or XCODES_PASSWORD are not set. Skipping Xcode installation."
  else
    info "Installing Xcode 16.2..."
    xcodes install 16.2
  fi
else
  success "Xcode 16.2 already installed ✓"
fi

info "Selecting Xcode 16.2..."
xcodes select 16.2
success "Xcode 16.2 already selected ✓"

# === Install Simulator ===
info "> Checking iOS Simulator 18.2..."
if ! xcodes runtimes | grep -q "iOS 18.2"; then
  info "Installing iOS Simulator 18.2..."
  xcodes runtimes install "iOS 18.2" || fail "⚠️ Could not install iOS 18.2 simulator. You may need to do this manually."
else
  success "iOS Simulator 18.2 already installed ✓"
fi
