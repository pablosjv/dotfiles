# Pablo's dotfiles

[![Build Status][tb]][tp]
[![Powered by Antibody][ab]][ap]

> Config files for ZSH, Java, Scala, Go, Editors, Terminals and more. Heavely inspired by [caarlos0](https://github.com/caarlos0/dotfiles)

![screenshot 1][scrn1]

![screenshot 2][scrn2]

[ap]: https://github.com/getantibody/antibody
[ab]: https://img.shields.io/badge/powered%20by-antibody-blue.svg?style=flat-square
[tb]: https://img.shields.io/travis/pablosjv/dotfiles/master.svg?style=flat-square
[tp]: https://travis-ci.org/pablosjv/dotfiles
[scrn1]: /docs/screenshot1.png
[scrn2]: /docs/screenshot2.png

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
$ git clone https://github.com/pablosjv/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
$ ./scripts/dependencies
$ ./scripts/bootstrap
$ zsh # or just close and open your terminal again.
```

> All changed files will be backed up with a `.backup` suffix.

### macOS defaults

You use it by running:

```console
$DOTFILES/macos/set-defaults.sh
```

And logging out and in again/restart.

### Themes and fonts being used

Theme is **[Norde Wave](https://github.com/DimitrisNL/nord-wave)**

## Further help:

- [Personalize your configs](/docs/PERSONALIZATION.md)
- [Understand how it works](/docs/PHILOSOPHY.md)
- [License](/LICENSE.md)

## Contributing

Feel free to contribute. Pull requests will be automatically
checked/linted with [Shellcheck](https://github.com/koalaman/shellcheck)
and [shfmt](https://github.com/mvdan/sh).
