# Pablo's dotfiles ![GitHub last commit](https://img.shields.io/github/last-commit/pablosjv/dotfiles?style=flat-square)

Configurations for shell, editors, languages, tools, and OS preferences. Installation is orchestrated with Dotbot.

## Quick Start

### Prerequisites

- `git`
- `curl`
- `tar`
- `zsh`

### Fresh install

Clone the repository with submodules in the home directory:

```bash
git clone --recurse-submodules https://github.com/pablosjv/dotfiles.git ~/.dotfiles
```

Change to the dotfiles directory:

```bash
cd ~/.dotfiles
```

Run the bootstrap script:

```bash
./scripts/bootstrap
```

## Usage

After bootstrap, commands in `bin/` are linked into `~/.local/bin`. The main CLI is:

```console
❯ dotfiles help
dotfiles [COMMAND]

Manages different dotfiles stuff

Commands:
    help       show this help text
    apply      install the latest version for the configuration and packages
    update     reflect the configuration changes in the repository
    edit       open dotfiles in editor
    date       get latest update date
    install    run just the installers
    configure  run just the configurators
    brew       interact with homebrew with extended commands
```

### CLI Autocompletion

Zsh completion for `dotfiles` is provided by [`shell/zsh/completions/_dotfiles`](/Users/pablosanjose/.dotfiles/shell/zsh/completions/_dotfiles). The completion path is loaded through Zim module setup in `.zimrc`.

## Development

### Makefile

A Makefile is provided for convenience on some of the development commands to format and test.

- `make fmt`: Format shell + Python.
- `make lint`: Lint Python.
- `make test`: Run pytest.
- `make check`: Run `fmt + lint + test`.

### Python

Some scripts are written in Python. Although they use Python standard libraries, a pyproject.toml is used to manage dev dependencies for testing and formatting.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Topic Authoring](docs/TOPIC-AUTHORING.md)
- [Customization](docs/CUSTOMIZATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [License](LICENSE.md)
