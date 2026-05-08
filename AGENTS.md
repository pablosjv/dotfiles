# AGENTS

Use the `docs/` directory as the source of truth for this repository.

- `docs/ARCHITECTURE.md`: Mental model, execution flows, shell consolidation internals.
- `docs/TOPIC-AUTHORING.md`: Topic hooks contract, Dotbot interaction, logging helpers.
- `docs/CUSTOMIZATION.md`: Local customization (shell, git, completions).
- `docs/TROUBLESHOOTING.md`: Common issues and recovery steps.

## Safety

- This is a dotfiles repository that can modify real system/user configuration in `$HOME`.
- Default to read/inspect mode first. Do not run `./scripts/bootstrap`, `scripts/apply`, `scripts/install`, or `scripts/configure` unless explicitly requested.
- Prefer targeted validation (single script or file) over full apply flows.
- Limit writes to repository files unless the user explicitly asks for system-level changes.
- Do not delete or overwrite existing user config files outside the repo unless explicitly requested.
- Call out OS-specific impact (`Darwin` vs Linux) before changing platform-specific paths.
- Do not expose secrets from local config files (for example `~/.localrc`, credential files, tokens).
