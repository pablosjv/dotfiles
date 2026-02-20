#!/usr/bin/env sh
#
# Create symlinks in $HOME for each Google Drive account's "My Drive" folder.
#

set -e

[ "$(uname -s)" != "Darwin" ] && exit 0

DOTFILES_ROOT=$(pwd -P)
# shellcheck disable=SC1091
. "$DOTFILES_ROOT/scripts/tools"

CLOUD_STORAGE="${HOME}/Library/CloudStorage"
MY_DRIVE_SUBDIR="My Drive"

if [ ! -d "$CLOUD_STORAGE" ]; then
    info "Google Drive CloudStorage not found at $CLOUD_STORAGE, skipping"
    exit 0
fi

if [ ! -r "$CLOUD_STORAGE" ]; then
    fail "No read permission for $CLOUD_STORAGE"
fi

for account_dir in "$CLOUD_STORAGE"/GoogleDrive-*/; do
    [ -d "$account_dir" ] || continue

    account_name=$(basename "$account_dir" | sed 's/^GoogleDrive-//')
    # Trim trailing slash for basename of parent
    account_name=${account_name%/}

    if [ -z "$account_name" ]; then
        warning "Skipping malformed account dir: $account_dir"
        continue
    fi

    my_drive_path="${account_dir}${MY_DRIVE_SUBDIR}"
    link_path="${HOME}/${account_name}"

    if [ ! -d "$my_drive_path" ]; then
        warning "\"My Drive\" not found at $my_drive_path, skipping account $account_name"
        continue
    fi

    if [ ! -r "$my_drive_path" ]; then
        warning "No read permission for $my_drive_path, skipping account $account_name"
        continue
    fi

    if [ -L "$link_path" ]; then
        current_target=$(readlink "$link_path")
        # Resolve to canonical path for comparison (symlink may be relative)
        resolved_current=$(cd -P "$link_path" 2>/dev/null && pwd -P) || true
        resolved_expected=$(cd -P "$my_drive_path" 2>/dev/null && pwd -P) || true
        if [ -n "$resolved_current" ] && [ -n "$resolved_expected" ] && [ "$resolved_current" = "$resolved_expected" ]; then
            success "Symlink already correct: $link_path -> $my_drive_path"
        elif [ "$current_target" = "$my_drive_path" ]; then
            success "Symlink already correct: $link_path -> $my_drive_path"
        else
            warning "Symlink exists with different target: $link_path (current: $current_target, expected: $my_drive_path)"
        fi
        continue
    fi

    if [ -e "$link_path" ]; then
        fail "Refusing to overwrite existing non-symlink: $link_path"
    fi

    if ln -s "$my_drive_path" "$link_path"; then
        success "Created $link_path -> $my_drive_path"
    else
        fail "Failed to create symlink: $link_path -> $my_drive_path (check permissions)"
    fi
done
