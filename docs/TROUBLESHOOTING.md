# Troubleshooting

## Shell changes not appearing

Run:

```bash
dotfiles configure
```

This rebuilds shell fragments: `shell/source/.aliases.sh`, `.exports.sh`, and `.functions.sh`.

## Command missing after bootstrap

Ensure `~/.local/bin` is on PATH (set in `~/.zshenv`) and open a new shell.

## `dotfiles date` looks wrong

`dotfiles date` reads `git config --global dotfiles.lastupdate`. That value may be stale depending on your update flow.

## Remote changes not pulled during apply

`dotfiles apply` treats `git pull` as best effort. Pull manually if needed and rerun apply.

## Homebrew issues

Use `dotfiles brew` helper commands:

- `dotfiles brew bump`
- `dotfiles brew cleanup`
- `dotfiles brew repair`
- `dotfiles brew bundle-clean`
