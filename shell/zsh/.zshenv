export PATH="${HOME}/.local/bin:$PATH"

# shortcut to this dotfiles path is $DOTFILES
export DOTFILES="$HOME/.dotfiles"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Cursor CLI and shared agent config (hooks, permissions, cli-config when linked)
export CURSOR_CONFIG_DIR="${XDG_CONFIG_HOME}/cursor"

# Extra completions folder (tracked custom scripts live here)
export ZSH_CUSTOM_COMPLETIONS="$DOTFILES/shell/zsh/completions"
# Tool generated completions
export ZSH_GENERATED_COMPLETIONS="$DOTFILES/shell/zsh/completions/generated"

# editors
export EDITOR='vim'
export VEDITOR='cursor'
