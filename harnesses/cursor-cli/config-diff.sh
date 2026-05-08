#!/usr/bin/env bash

# This script checks the Cursor JSON files in the dotfiles repo against the ones in the system.
# If they are not symlinked (meaning they might have drifted), it uses delta to print a diff.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# Function to check diff between repo file and system file
check_diff() {
    local repo_file="$1"
    local system_file="$2"

    if [ ! -f "$system_file" ]; then
        # System file doesn't exist, nothing to diff
        return
    fi

    if [ -L "$system_file" ]; then
        # It's a symlink, so it's correctly managed by dotbot (or at least linked)
        return
    fi

    # Check if we should use JSON normalization (only for .json or .code-snippets)
    local is_json=false
    if [[ "$repo_file" == *.json ]] || [[ "$repo_file" == *.code-snippets ]]; then
        is_json=true
    fi

    if [ "$is_json" = true ] && command -v jq >/dev/null 2>&1; then
        # Compare normalized versions
        if diff <(jq -S . "$repo_file") <(jq -S . "$system_file") >/dev/null 2>&1; then
            return
        fi
    else
        # Check if files are identical literally
        if cmp -s "$repo_file" "$system_file"; then
            return
        fi
    fi

    echo "--------------------------------------------------------------------------------"
    echo "DIFF DETECTED: $system_file is not a symlink and differs from repo"
    echo "Repo:   $repo_file"
    echo "System: $system_file"
    echo "--------------------------------------------------------------------------------"

    if [ "$is_json" = true ] && command -v jq >/dev/null 2>&1; then
        if command -v delta >/dev/null 2>&1; then
            delta <(jq -S . "$repo_file") <(jq -S . "$system_file")
        else
            diff -u <(jq -S . "$repo_file") <(jq -S . "$system_file") || true
        fi
    else
        if command -v delta >/dev/null 2>&1; then
            delta "$repo_file" "$system_file"
        else
            diff -u "$repo_file" "$system_file" || true
        fi
    fi
    echo ""
}
echo "Checking Cursor configuration files..."

# 1. Cursor User settings (macOS)
if [ "$(uname)" = "Darwin" ]; then
    CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
    if [ -d "$CURSOR_USER_DIR" ]; then
        # Check JSON files in editors/cursor
        for f in "$DOTFILES_DIR/editors/cursor"/*.json; do
            [ -e "$f" ] || continue
            check_diff "$f" "$CURSOR_USER_DIR/$(basename "$f")"
        done

        # Check snippets
        if [ -d "$DOTFILES_DIR/editors/cursor/snippets" ]; then
            for f in "$DOTFILES_DIR/editors/cursor/snippets"/*; do
                [ -e "$f" ] || continue
                check_diff "$f" "$CURSOR_USER_DIR/snippets/$(basename "$f")"
            done
        fi
    fi
fi

# 2. Cursor CLI config
CURSOR_CLI_DIR="$HOME/.cursor"
if [ -d "$CURSOR_CLI_DIR" ]; then
    for f in "$DOTFILES_DIR/harnesses/cursor-cli"/*.json; do
        [ -e "$f" ] || continue
        check_diff "$f" "$CURSOR_CLI_DIR/$(basename "$f")"
    done
fi

echo "Done."
