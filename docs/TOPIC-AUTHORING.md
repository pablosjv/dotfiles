# Topic Authoring

## Purpose

Topics keep behavior modular while integrating with centralized execution. We call these **topic hooks**. All the hooks are optional:

```tree
tools/mytool/
├── install.sh      # Install dependencies/tools
├── configure.sh    # Configure runtime or generate artifacts
├── update.sh       # Refresh repo state from local state
├── exports.sh      # Environment variables and PATH
├── aliases.sh      # Aliases
└── functions.sh    # Shell functions
```

## Topic Hooks - Contract and Execution order

Note that the hooks are executed in the following order. This is useful because you might need to do some setup in the install before you can really configure the tool.

### `install.sh`

Goal: run the initial setup of the topic. If the topic has installation requirements not supported by the package manager, it will be done here.

> [!NOTE]
> The package manager itself has its own install script (check [brew](/Users/pablosanjose/.dotfiles/os/mac/brew/install.sh)). This doesn't install the topic itself, but all the dependencies managed by the package manager.

### `configure.sh`

Goal: configure the installed tools. Generate files/state needed for runtime. As it runs after `install.sh`, it can assume the installation and dependencies are completed.

> [!TIP]
> Configures are very useful when the tool is installed in the package manager, but we need to run the tool itself to generate completions.

### `update.sh`

Goal: Sync local state back into repo-managed files when needed. Executed by `dotfiles update`.

### `exports.sh` / `aliases.sh` / `functions.sh`

Goal: Define runtime shell behavior.

## Interaction With Dotbot (`install.conf.yaml`)

Use Dotbot for filesystem and link orchestration, not per-topic runtime logic.

- Add directory requirements under `create`.
- Add symlinks under `link`.
- Add conditional links with `if` when OS-specific.
- Keep executable orchestration in scripts (`install.sh`/`configure.sh`).

### Dotbot vs Topic: Where to Place Config Files

- Put `~/.*`-style home dotfiles in `etc/` when they conceptually belong to home root.
- Put tool/editor specific files in their topic directory (for example `tools/*`, `editors/*`, `langs/*`) and link them to their target path from `install.conf.yaml`.

## Logging Helpers

For script output consistency, source [`scripts/tools`](/Users/pablosanjose/.dotfiles/scripts/tools) and use:

- `info "..."`
- `success "..."`
- `warning "..."`
- `fail "..."`
- `user "..."`

These helpers preserve indentation (`LOG_DEPTH`) across nested execution.

### How To Source And Use In A Hook

Use this pattern at the top of topic scripts:

```sh
#!/usr/bin/env sh

DOTFILES_ROOT=$(pwd -P)
# shellcheck source=../../scripts/tools
. "$DOTFILES_ROOT/scripts/tools"

info "Starting topic configuration"

if command -v mytool >/dev/null 2>&1; then
    success "mytool found"
else
    warning "mytool not found, skipping"
fi
```

Notes:

- `DOTFILES_ROOT=$(pwd -P)` works because hook scripts are executed from repo root by `scripts/install` and `scripts/configure`.
- If a script cannot continue, call `fail "message"` to stop the flow with a clear error.
- For nested operations, pass `LOG_DEPTH=$((${LOG_DEPTH:-0} + 1))` to child commands to keep indentation consistent.

## Testing Changes

Use both targeted and end-to-end validation.

1. Targeted script test: Run the changed script directly (for example `./tools/mytool/configure.sh`).
2. Stage-level test: Run `dotfiles install` or `dotfiles configure`.
3. Full flow test: Run `dotfiles apply` (or `./scripts/bootstrap` on a fresh machine).
4. Quality checks: Run `make check`.
