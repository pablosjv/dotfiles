# Customization

## Private shell overrides

Use `~/.localrc` for machine-local or secret settings.

It is sourced by `shell/init.sh` after consolidated aliases/exports/functions, so local values can override repo defaults.

## Git customization

The setup uses layered git config with conditional includes:

- Global file: `~/.gitconfig`
- Dotfiles-managed shared config: `~/.gitconfig.local` (linked from `git/.gitconfig.local`)
- Per-project-group config files (included by path rules), for example:
  - `~/projects/github.com/.gitconfig`
  - `~/projects/gitlab.com/.gitconfig`
  - `~/projects/<company>.gitlab.com/.gitconfig`

The `~/.gitconfig` should includes patterns like:

- `[includeIf "gitdir:/Users/pablosjv/projects/github.com/"]`
- `[includeIf "gitdir:/Users/pablosjv/projects/gitlab.com/"]`

This follows the repository-organization rule: mirror remote hosting domains and URL paths under `~/projects` (for example `~/projects/github.com/org/repo`), which makes repository location predictable and allows identity/config switching by directory.

### Per-Project-Group Configs (Automatic)

The [`git/configure.sh`](/Users/pablosanjose/.dotfiles/git/configure.sh) script manages per-project-group configs automatically:

- It scans `~/projects/*/` for existing group directories.
- It creates `<group>/.gitconfig` when missing.
- It adds `includeIf.gitdir:<abs_group_path>/.path=<abs_group_path>/.gitconfig` to global git config when missing.

In practice, this means you only need to:

1. Create the project-group directory (for example `~/projects/github.com`).
2. Run `dotfiles configure` (or `dotfiles apply`).
3. Edit that group `.gitconfig` with the identity/settings you want.

Verify effective config in a repository:

```console
git config --show-origin --get user.name
git config --show-origin --get user.email
```

If multiple `includeIf` rules match, later includes can override earlier values.

### Custom completions

- `shell/zsh/completions/`: Handcrafted completions, tracked in git.
- `shell/zsh/completions/generated/`: Tool-generated completions, not tracked as completion payloads (directory is kept with `.gitkeep`).

Use tracked completions for maintained wrappers (for example `_dotfiles`, `_brew`) and generated completions for ephemeral/refreshable outputs from tooling.
