# Pablo's dotfiles ![GitHub last commit](https://img.shields.io/github/last-commit/pablosjv/dodfiles?style=flat-square)

> Config files for ZSH, Python, Editors, Terminals, and more. Powered by dotbot.

## Installation

### Dependencies

First, make sure you have all those things installed:

- `git`: to clone the repo
- `curl`: to download some stuff
- `tar`: to extract downloaded stuff
- `zsh`: to actually run the dotfiles
- `sudo`: some configs may need that

### Install

Then, run these steps:

```console
git clone --recurse-submodules https://github.com/pablosjv/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/apply
```

From that moment the `dot` command will be available in your path, which simplify the dotfiles operation

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

The `dotfiles apply` is a wrapper for dotbot, so you can provide command line arguments to the tool, for example:

```console
dotfiles apply --only link
```

### macOS defaults

You use it by running:

```console
$DOTFILES/os/mac/set-defaults.sh
```

And logging out and in again/restart.

## Further help

- [Personalize your configs](/docs/PERSONALIZATION.md)
- [Understand how it works](/docs/PHILOSOPHY.md)
- [License](/LICENSE.md)
