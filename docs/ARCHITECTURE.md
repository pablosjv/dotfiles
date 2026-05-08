# Architecture

## Mental Model

The repository is topic-oriented and domain-split.

- `etc/*`: Home-dotfile style configs linked at `~/.*`.
- `os/*`: OS-specific setup.
- `shell/*`: Interactive shell runtime, prompt, completions.
- `tools/*`: Tool-specific setup and runtime behavior.
- `langs/*`: Language runtimes and language tooling.
- `editors/*`: Editor/IDE preferences.

This split is mainly arbitrary but helps keeping the concerns isolated by domain topic.

Each topic contains **Topic Hooks** or just **Hooks**: `install.sh`, `configure.sh`, `update.sh`, and shell fragments (`exports.sh`, `aliases.sh`, `functions.sh`). The root scripts orchestrate the execution of these hooks. See [TOPIC-AUTHORING.md](TOPIC-AUTHORING.md) for more details.

## Execution Flows

### Bootstrap - First Run

Refer to [BOOTSTRAP.md](BOOTSTRAP.md) for more details.

```bash
./scripts/bootstrap
```

1. Runs `./scripts/apply`.
2. Fails fast if apply fails.

> This flow is intended to be used in a fresh environment. After dotfiles are configured, you can use `dotfiles apply` to set up the environment.

### Apply

"Apply" the dotfiles to the system.

```bash
dotfiles apply
```

> Runs `./scripts/apply` behind the scenes.

1. Best-effort `git pull --quiet`.
2. Dotbot submodule sync/update.
3. Dotbot run with `install.conf.yaml`.
4. Dotbot performs `clean -> create -> link -> shell`.
5. Dotbot shell steps run `./scripts/install` then `./scripts/configure`.

### Update

"Update" the dotfiles with the latest system changes.

```bash
dotfiles update
```

> Runs `./scripts/update` behind the scenes.

1. Submodule remote merge update.
2. Recursive execution of every `**/update.sh`.

## Behind The Scenes

### Script Discovery

Discoverability of the topic hooks is done by looking into `"${DOTFILES_ROOT}"/**`. There is no restriction on where the files are located or the nesting level. This makes the setup very flexible if new domains are added or specific tools need more than 1 nesting level.

### Shell Consolidation

The `shell/configure.sh` carries out the discovery and consolidation of shell fragments into. All discovered fragments are appended in discovery orderto the corresponding generated files. This strips shebang lines from fragments and adds per-source header comments for traceability.

The final consolidated files look like this:

```tree
shell/source/
├── .exports.sh
├── .aliases.sh
└── .functions.sh
```

The `shell/init.sh` script is the one responsible to source these generated shell fragments to bootstrap the shell environment.

Primary motivation is shell startup performance: runtime shell only sources 3 generated files instead of many scattered files. Secondary benefits are debuggability and consistent load shape.

## ZSH, Zim, And Runtime Chain

1. `~/.zshenv` sets baseline env (`DOTFILES`, XDG, editors).
2. `~/.zshrc`
   - Initializes prompt and Zim.
   - Sources `"$DOTFILES/shell/init.sh"`.
3. `shell/init.sh`
   - Sources generated files in `shell/source/*`.
   - Sources `~/.localrc` for private overrides. Check the [CUSTOMIZATION.md](./CUSTOMIZATION.md) for details

We manage ZSH modules using [Zim](https://zimfw.sh/). Modules are declared in [`shell/zsh/.zim/.zimrc`](/Users/pablosanjose/.dotfiles/shell/zsh/.zim/.zimrc). Prompt config is linked from `shell/zsh/themes/p10k.zsh` and optionally extended by linked p10k snippets.

## Gotchas

- `dotfiles date` depends on `git config --global dotfiles.lastupdate` and can be stale.
- `scripts/apply` ignores `git pull` failures (`|| true`).
- If shell behavior drifts, rerun `dotfiles configure` to regenerate `shell/source/*`.
