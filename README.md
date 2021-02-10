# HyperTerm

Custom Prompt Shell Settings for Bash

## Requirements

- wget
- curl
- git

## Features
- Show Git information (branch, tag, or where you did `git checkout`)
- It allows knowing the status (*exit status*) of the Prompt Shell after executing one/some command(s).
- Makes source to `/usr/share/doc/pkgfile/command-not-found.bash` automatically (requires `pkgfile`).
- Source `/usr/share/bash-completion/bash_completion` automatically (requires `bash-completion`).
- Includes a `hyperterm/_custom.sh` for customizations in HyperTerm, separately.

    >Your changes must be in `$HOME/.hyperterm/_custom.sh`, so that are not deleted when it is updated.

- Special functions like:

    * `activate` to activate virtualenv in python
    * `cex` compress files and/or directories
    * `ex` extract files
    * `ii` general system information
    * `proxy_on` enables proxy in terminal or tty
    * `sagent_start` and `sangent_stop` to enable or disable the SSH agent (password is remembered for 432000 seconds)
    * `rar2zip` convert RAR files to ZIP, use `unar` and `7z`

- Aliases like:

    * `clean` clears the bash history
    * `df` shows information about the partitions of the S.O.
    * `pastebin` allows you to quickly generate a paste for example: `cat/etc/*release | pastebin` or `sensors | pastebin`
    * `ep` open a PKGBUILD with emacs
    * `free` shows RAM and SWAP information
    * `grep` skips its colors by default
    * `la` short of `ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F`
    * `ll` short of `ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F`
    * `ls` short of `ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F`
    * `np` open a PKGBUILD with nano

- Look at [tools](hyperterm/tools) directory for more functions.
- Run `screenfetch` if installed (included in the `hyperterm/_custom.sh` template).

## Installation

### Semi-automatic

1. Download file `install.sh`:

        wget https://git.sr.ht/~heckyel/hyperterm/blob/master/install.sh -O "$HOME/install.sh"

2. Run file `install.sh`

        bash "$HOME/install.sh"

    or in silent mode:

        bash "$HOME/install.sh" -s

    use -h to show help:

        bash "$HOME/install.sh" -h

3. Delete file `install.sh`:

        rm -v "$HOME/install.sh"

### Manual

1. As a suggestion, make a backup of your Prompt Shell.

        for f in .bashrc .bash_aliases .bash_profile; do cp -v "$HOME/$f" "$HOME/$f.bak"; done

2. Clone the HyperTerm repository:

    - Mirror 1: `git clone https://git.sr.ht/~heckyel/hyperterm.git "$HOME/bash"`
    - Mirror 2: `git clone https://notabug.org/heckyel/hyperterm.git "$HOME/bash"`

3. Copy the HyperTerm files to your Local Directory

        install -d -m755 "$HOME/.hyperterm"

        cp -rv $HOME/bash/hyperterm/* "$HOME/.hyperterm"

        cp -v $HOME/bash/.bash* "$HOME"

        cp -v $HOME/bash/hyperterm/_custom.sh "$HOME/.hyperterm"

        install -m644 $HOME/bash/template/bash_profile.template.bash "$HOME/.bashrc"

4. Open your terminal again or execute the next instruction

        . $HOME/.bashrc*

5. Delete the repository if you are not interested in having it stored

        rm -rfv bash

6. Done!

## Post-installation

* Optionally you can install trash-cli, pkgfile, bind-tools, bash-completion

        pacman -S trash-cli

        pacman -S pkgfile

        pacman -S bind-tools

        pacman -S bash-completion

> [trash-cli](https://github.com/andreafrancia/trash-cli): is a utility to prevent accidental deletion when using the rm -rf command

> [pkgfile](https://github.com/falconindy/pkgfile): allows you to search for the command executed in the repository database

> [bind-tools](https://www.isc.org/downloads/bind/): allows to get ISP, running 'ii' in terminal

> [bash-completion](https://github.com/scop/bash-completion): allows bash autocomplete

## Upgrade

- To update just open the terminal and run:

    `updbashrc` to update HyperTerm

    `updbashrc_custom` just to update file `hyperterm/_custom.sh`

## Screenshots

### Git

![Alt git preview](images/git-preview.png?raw=true "git-preview")

### Themes

#### default

![Alt Bash por defecto](images/default.png?raw=true "default")

#### joy

![Alt Special](images/joy.png?raw=true "special")

#### light_theme

![Alt Light theme](images/light_theme.png?raw=true "light_theme")

#### minterm

![Alt Min term](images/minterm.png?raw=true "minterm")

#### pure

![Alt Pure](images/pure.png?raw=true "pure")

#### special

![Alt Special](images/special.png?raw=true "special")

> The theme is configurable from file `$HOME/.hyperterm/_custom.sh`

## Uninstall

### Semi-automatic

1. Download file `uninstall.sh`:

        wget https://git.sr.ht/~heckyel/hyperterm/blob/master/uninstall.sh -O "$HOME/uninstall.sh"

    o

        wget https://notabug.org/heckyel/hyperterm/raw/master/uninstall.sh -O "$HOME/uninstall.sh"

2. Run file `uninstall.sh`:

        bash "$HOME/uninstall.sh"

3. Delete file `uninstall.sh`:

        rm -v "$HOME/uninstall.sh"

### Manual

If you want to leave your computer as it was, delete the files copied from step 3 with:

    rm -vrf "$HOME/{.hyperterm/,.bashrc}"

and restore the ***.bak** files from step 1 by running:

    for f in .bashrc .bash_aliases .bash_profile; do cp -v "$HOME/$f.bak" "$HOME/$f"; done

## Hacking

See [HACKING.md](HACKING.md)

## Contributors

   **HyperTerm** contributors can be found in the [AUTHORS](AUTHORS) file

## License

This work is licensed under the [GNU GPLv3+](LICENSE)
