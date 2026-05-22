#!/usr/bin/env bash
#
# Cursor might overwrite the symlink when updating.
# Compare repo-managed Cursor config files with local Cursor config files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

PROGRAM_NAME="$(basename "$0")"
CHECK_EDITOR=true
CHECK_CLI=true
NORMALIZE_JSON=true
DIFF_TOOL="${CONFIG_DIFF_TOOL:-auto}"
EXIT_WITH_DIFFS=false

checked_count=0
diff_count=0
skipped_count=0

show_help() {
    cat <<EOF
Usage: $PROGRAM_NAME [OPTIONS]

Compare repo-managed Cursor config files with local Cursor config files.

Cursor might overwrite the symlink when updating. This script is a helper to get
an idea of what changes might have been made.

Options:
  --editor-only          Check Cursor editor config only
  --cli-only             Check Cursor CLI config only
  --no-editor            Skip Cursor editor config
  --no-cli               Skip Cursor CLI config
  --no-json-normalize    Compare JSON files literally instead of sorting with jq
  --diff-tool TOOL       Diff renderer: auto, delta, diff (default: auto)
  --exit-code            Exit with 1 when diffs are found
  -h, --help             Show this help message

Environment Variables:
  CONFIG_DIFF_TOOL       Default diff renderer when --diff-tool is not set

Examples:
  $PROGRAM_NAME
  $PROGRAM_NAME --cli-only
  $PROGRAM_NAME --diff-tool diff --no-json-normalize
EOF
}

main() {
    parse_arguments "$@"

    if [[ "$CHECK_EDITOR" == true ]]; then
        check_cursor_editor
    fi

    if [[ "$CHECK_CLI" == true ]]; then
        check_cursor_cli
    fi

    if [[ "$diff_count" -gt 0 ]]; then
        warning "Found $diff_count diff(s) across $checked_count checked file(s); skipped $skipped_count missing or symlinked file(s)"
        if [[ "$EXIT_WITH_DIFFS" == true ]]; then
            exit 1
        fi
        exit 0
    fi

    success "No diffs found across $checked_count checked file(s); skipped $skipped_count missing or symlinked file(s)"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --editor-only)
            CHECK_EDITOR=true
            CHECK_CLI=false
            shift
            ;;
        --cli-only)
            CHECK_EDITOR=false
            CHECK_CLI=true
            shift
            ;;
        --no-editor)
            CHECK_EDITOR=false
            shift
            ;;
        --no-cli)
            CHECK_CLI=false
            shift
            ;;
        --no-json-normalize)
            NORMALIZE_JSON=false
            shift
            ;;
        --diff-tool)
            [[ $# -ge 2 ]] || die "Missing argument for $1"
            DIFF_TOOL="$2"
            shift 2
            ;;
        --diff-tool=*)
            DIFF_TOOL="${1#*=}"
            shift
            ;;
        --exit-code)
            EXIT_WITH_DIFFS=true
            shift
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
        esac
    done

    [[ -n "$DIFF_TOOL" ]] || die "Diff tool cannot be empty"

    case "$DIFF_TOOL" in
    auto | delta | diff) ;;
    *) die "Invalid diff tool: $DIFF_TOOL" ;;
    esac

    if [[ "$CHECK_EDITOR" != true && "$CHECK_CLI" != true ]]; then
        die "Nothing to check after applying options"
    fi
}

check_cursor_editor() {
    local cursor_user_dir="$HOME/Library/Application Support/Cursor/User"

    if ! is_darwin; then
        warning "Cursor editor config check is only supported on Darwin, skipping"
        return
    fi

    info "Checking Cursor editor configuration files"
    check_files "$DOTFILES_ROOT/editors/cursor" "$cursor_user_dir" "*.json"
    check_files "$DOTFILES_ROOT/editors/cursor/snippets" "$cursor_user_dir/snippets" "*"
}

check_cursor_cli() {
    local cursor_cli_dir="$HOME/.cursor"

    info "Checking Cursor CLI configuration files"
    check_files "$DOTFILES_ROOT/harnesses/cursor-cli" "$cursor_cli_dir" "*.json"
}

is_darwin() {
    [[ "$(uname -s)" == "Darwin" ]]
}

check_files() {
    local repo_dir="$1"
    local system_dir="$2"
    local pattern="$3"
    local repo_file

    [[ -d "$repo_dir" && -d "$system_dir" ]] || return

    for repo_file in "$repo_dir"/$pattern; do
        [[ -e "$repo_file" ]] || continue
        check_diff "$repo_file" "$system_dir/$(basename "$repo_file")"
    done
}

check_diff() {
    local repo_file="$1"
    local system_file="$2"

    if [[ ! -f "$system_file" ]]; then
        skipped_count=$((skipped_count + 1))
        return
    fi

    if [[ -L "$system_file" ]]; then
        skipped_count=$((skipped_count + 1))
        return
    fi

    checked_count=$((checked_count + 1))

    if files_match "$repo_file" "$system_file"; then
        return
    fi

    diff_count=$((diff_count + 1))
    print_diff_header "$repo_file" "$system_file"
    print_diff "$repo_file" "$system_file"
    printf '\n'
}

files_match() {
    local repo_file="$1"
    local system_file="$2"

    if can_normalize_json "$repo_file" "$system_file"; then
        diff <(jq -S . "$repo_file") <(jq -S . "$system_file") >/dev/null
        return
    fi

    cmp -s "$repo_file" "$system_file"
}

can_normalize_json() {
    local repo_file="$1"
    local system_file="$2"

    [[ "$NORMALIZE_JSON" == true ]] &&
        is_json_like "$repo_file" &&
        command -v jq >/dev/null 2>&1 &&
        jq -e . "$repo_file" >/dev/null 2>&1 &&
        jq -e . "$system_file" >/dev/null 2>&1
}

is_json_like() {
    local file="$1"

    [[ "$file" == *.json || "$file" == *.code-snippets ]]
}

print_diff_header() {
    local repo_file="$1"
    local system_file="$2"

    printf '%s\n' "--------------------------------------------------------------------------------"
    printf 'DIFF DETECTED: %s is not a symlink and differs from repo\n' "$system_file"
    printf 'Repo:   %s\n' "$repo_file"
    printf 'System: %s\n' "$system_file"
    printf '%s\n' "--------------------------------------------------------------------------------"
}

print_diff() {
    local repo_file="$1"
    local system_file="$2"
    local diff_tool

    diff_tool="$(selected_diff_tool)"

    if can_normalize_json "$repo_file" "$system_file"; then
        if [[ "$diff_tool" == "delta" ]]; then
            delta <(jq -S . "$repo_file") <(jq -S . "$system_file") || true
        else
            diff -u <(jq -S . "$repo_file") <(jq -S . "$system_file") || true
        fi
        return
    fi

    if [[ "$diff_tool" == "delta" ]]; then
        delta "$repo_file" "$system_file" || true
    else
        diff -u "$repo_file" "$system_file" || true
    fi
}

selected_diff_tool() {
    if [[ "$DIFF_TOOL" == "auto" ]]; then
        if command -v delta >/dev/null 2>&1; then
            printf 'delta'
        else
            printf 'diff'
        fi
        return
    fi

    printf '%s' "$DIFF_TOOL"
}

die() {
    printf "Error: %s\n\n" "$1" >&2
    show_help >&2
    exit 1
}

main "$@"
