# PHILOSOPHY

> Philosophical stuff about this dotfiles structure, decisions, etc..

## Why?

Configuring a new system is tedious. Keeping sync of the configuration between systems is also a pain in the ass. I came accros the [dotfiles](https://dotfiles.github.io) website when trying to find solutions to this problem.

Navigating between different dotfiles repos I found the [caarlos0](https://github.com/caarlos0/dotfiles). I fell in love with the organization and automation of this repo, so I decided to make a fork on my own. I did not make a github fork because I want to evolve this project completely separate from the original one, but you will see the original project reference across the documentation. Here you can find a very [good post on the subject](http://carlosbecker.com/posts/dotfiles-are-meant-to-be-forked).

That was my first iteration. Nowadays the repo has evolved a lot and uses [dotbot](https://github.com/anishathalye/dotbot) to do a lot of the heavy lifting. Still, a lot of ideas are the same from the original project.

## Decisions

### Mangae configuration and installation

The original project separate the configuration form the installation in different repos. I decided to merge the two and install all the required software from this repository. There are two steps separated in two different scripts by topic:

* `install`: install the required software for that topic
* `configure`: perform the configuration needed

The installation of all the topics will come first and then the configuration. This way you can have a topic configuration dependent of the installation of other ones and everything will run smoothly. This makes sense because the most part of the software is installed with a package manager, that will have it's separated topic (hombrew, apt..)

### Default `EDITOR`, `VEDITOR` and `PROJECTS`

`VEDITOR` stands for "visual editor", and is set to `code` be default. `EDITOR` is set to `vim`.

`PROJECTS` is default to `~/projects`. The shortcut to that folder in the shell is `c`.

You can change that by adding your custom overrides in `~/.localrc`.

### Naming conventions

There are a few special files in the hierarchy:

* **bin/**: Anything in `bin/` will get added to your `$PATH` and be made available everywhere.
* **topic/exports.sh**: the file will be sourced to load environment variables or modifying the `$PATH`.
* **topic/install.sh**: Any file with this name and with exec permission, will ran at `bootstrap` and `dotfiles-update` phase, and are expected to install plugins, and stuff like that.
* **topic/configure.sh**: Any file with this name and with exec permission, will ran at `bootstrap` and `dotfiles-update` phase, and are expected to configure plugins, and packages and other stuff.
* **topic/update.sh**: Any file with this name and with exec permission, will ran using `.dotfiles/scripts/update`. This is to update the dotfile configuration with the local changes. An alias `dot-refresh` is added to run this commands whenever you find appropiate.

### ZSH plugins

The project uses [zimfw](https://github.com/zimfw/zimfw) for plugin managements. The prompt is from [Powerlevel10k](https://github.com/romkatv/powerlevel10k) with a lean theme, transient prompt and some other stuff. You can check all the [zsh plugins here](../shell/zsh/.zim/.zimrc).

The combination of Antibody and the Powerlevel10k instant prompt feature, makes this configuration the fastest shell startup you've ever had.

### Compatibility

The setup should be compatible between Linux and OSX, but I mainly use MacOS so is not battle tested in Linux. Also there is no packages instalation for linux, only with hombrew.
