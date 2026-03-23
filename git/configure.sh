#!/usr/bin/env sh

set -e

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

info 'Setup gitconfig'
if [ -z "$(git config --global --get user.email)" ]; then
    # if there is no user.email, we'll assume it's a new machine/setup and ask it
    user ' - What is your github author name?'
    read -r user_name
    user ' - What is your github author email?'
    read -r user_email

    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
elif [ "$(git config --global --get dotfiles.managed)" != "true" ]; then
    # if user.email exists, let's check for dotfiles.managed config. If it is
    # not true, we'll backup the gitconfig file and set previous user.email and
    # user.name in the new one
    user_name="$(git config --global --get user.name)"
    user_email="$(git config --global --get user.email)"
    mv ~/.gitconfig ~/.gitconfig.backup
    success "moved ~/.gitconfig to ~/.gitconfig.backup"
    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
else
    # otherwise this gitconfig was already made by the dotfiles
    info "Already managed by dotfiles"
fi
# include the gitconfig.local file
git config --global include.path ~/.gitconfig.local
# finally make git knows this is a managed config already, preventing later
# overrides by this script
git config --global dotfiles.managed true
success 'gitconfig'

info 'Set conditional gitconfigs for projects'

PROJECTS_DIR=~/projects
for dir in "$PROJECTS_DIR"/*/; do
    [ -d "$dir" ] || continue
    touch "$dir/.gitconfig"
    # Expand tilde and strip trailing slash for gitdir pattern
    abs_dir=$(realpath "$dir")
    # Check if entry already exists in ~/.gitconfig
    if ! git config --global --get-all includeIf.gitdir:"$abs_dir/"'.path' | grep -qx "$abs_dir/.gitconfig"; then
        info "Adding conditional include for $abs_dir/"
        git config --global --add includeIf.gitdir:"$abs_dir/"'.path' "$abs_dir/.gitconfig"
        success "Added config for $dir"
    else
        success "Include for $abs_dir already exists, skipping"
    fi
done

# Don't ask ssh password all the time
if [ "$(uname -s)" = "Darwin" ]; then
    git config --global credential.helper osxkeychain
else
    git config --global credential.helper cache
fi

# Install git-town completions with a patch so `git town <TAB>` also works
if command -v git-town >/dev/null 2>&1; then
    info "Installing git-town completions"
    COMP_FILE="$ZSH_GENERATED_COMPLETIONS/_git-town"
    git town completions zsh >"$COMP_FILE"
    success "git-town completions installed"
else
    info "git-town command not found. Skipping completion installation."
fi
