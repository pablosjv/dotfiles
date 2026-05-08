# Powerlevel10k prompt segment for git-town pending commands
#
# https://github.com/romkatv/powerlevel10k
# https://www.git-town.com/how-to/shell-prompt.html
#
# Usage in ~/.zshrc:
#
#   [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
#   [[ -f ~/.config/shell/p10k.git-town.zsh ]] && source ~/.config/shell/p10k.git-town.zsh
#

() {
    function prompt_git_town() {
        local pending
        local git_town_icon
        pending=$(git town status --pending 2>/dev/null)
        if [[ -n "$pending" ]]; then
            git_town_icon="${POWERLEVEL9K_GIT_TOWN_ICON:-⎇}"
            p10k segment -s PENDING -i " $git_town_icon" -t "$pending"
        fi
    }

    typeset -g POWERLEVEL9K_GIT_TOWN_PENDING_FOREGROUND=0
    typeset -g POWERLEVEL9K_GIT_TOWN_PENDING_BACKGROUND=5
    typeset -g POWERLEVEL9K_GIT_TOWN_ICON='⎇'

    # Insert git_town right after vcs in the left prompt.
    # Avoid string replacement with spaces because it can collapse elements and
    # interfere with p10k's prompt element parsing.
    if ((${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(Ie)git_town]} == 0)); then
        local -a p10k_left_prompt_elements
        local element
        for element in "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]}"; do
            p10k_left_prompt_elements+=("$element")
            [[ "$element" == "vcs" ]] && p10k_left_prompt_elements+=("git_town")
        done
        typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=("${p10k_left_prompt_elements[@]}")
    fi
}
