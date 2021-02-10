# HyperTerm

Configuración personalizada del Prompt Shell para Bash

## Dependencias

- wget
- curl
- git

## Características
- Muestra información de Git (rama, tag, o donde hiciste `git checkout`)
- Permite saber el estado (*exit status*) del Prompt Shell después de ejecutar un/unos comando(s).
- Hace source a `/usr/share/doc/pkgfile/command-not-found.bash` automaticamente (requiere de `pkgfile`).
- Hace source a `/usr/share/bash-completion/bash_completion` automaticamente (requiere de `bash-completion`).
- Incluye un `hyperterm/_custom.sh` para personalizaciones en el HyperTerm, de forma separada.

    >Tus cambios deben estar en `$HOME/.hyperterm/_custom.sh`, para que no se eliminen al momento de actualizarlo.

- Funciones especiales como:

    * `activate` para activar virtualenv en python
    * `cex` comprimir archivos y/o directorios
    * `ex` extraer archivos
    * `ii` información general del sistema
    * `proxy_on` activa proxy en el terminal o tty
    * `sagent_start` y `sangent_stop` para activar o desactivar el agente SSH (la contraseña es recordada por 432000 segundos)
    * `rar2zip` convierte archivos RAR a ZIP, utiliza `unar` y `7z`

- Aliases como:

    * `clean` limpia el historial de bash
    * `df` muestra información de las particiones del S.O.
    * `pastebin` permite generar rápidamente un paste por ejemplo: `cat /etc/*release | pastebin` o `sensors | pastebin`
    * `ep` abre un PKGBUILD con emacs
    * `free` muestra información de la RAM y SWAP
    * `grep` salta los colores del mismo por defecto
    * `la` abreviación de `ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F`
    * `ll` abreviación de `ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F`
    * `ls` abreviación de `ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F`
    * `np` abre un PKGBUILD con nano

- Mirar el directorio [tools](hyperterm/tools) para conocer más funciones.
- Ejecuta `screenfetch` si está instalado (incluido en la plantilla `hyperterm/_custom.sh`).

## Instalación

### Instalación semi-automática

1. Descargar el archivo `install.sh`:

        wget https://git.sr.ht/~heckyel/hyperterm/blob/master/install.sh -O "$HOME/install.sh"

2. Ejecutar el archivo `install.sh`

        bash "$HOME/install.sh"

    o en modo silencioso:

        bash "$HOME/install.sh" -s

    utilice -h para mostrar ayuda:

        bash "$HOME/install.sh" -h

3. Eliminar el archivo `install.sh`:

        rm -v "$HOME/install.sh"

### Instalación Manual

1. Como sugerencia haz un respaldo de tu Prompt Shell.

        for f in .bashrc .bash_aliases .bash_profile; do cp -v "$HOME/$f" "$HOME/$f.bak"; done

2. Clona el repositorio HyperTerm:

    - Mirror 1: `git clone https://git.sr.ht/~heckyel/hyperterm.git "$HOME/bash"`
    - Mirror 2: `git clone https://notabug.org/heckyel/hyperterm.git "$HOME/bash"`

3. Copia los archivos de HyperTerm en tu Directorio Local

        install -d -m755 "$HOME/.hyperterm"

        cp -rv $HOME/bash/hyperterm/* "$HOME/.hyperterm"

        cp -v $HOME/bash/.bash* "$HOME"

        cp -v $HOME/bash/hyperterm/_custom.sh "$HOME/.hyperterm"

        install -m644 $HOME/bash/template/bash_profile.template.bash "$HOME/.bashrc"

4. Vuelve abrir tu terminal ó ejecuta la siguiente instrucción

        . $HOME/.bashrc*

5. Borra el repositorio si no te interesa tenerlo almacenado

        rm -rfv bash

6. Listo!

## Post-instalación

* Opcionalmente puede instalar trash-cli, pkgfile, bind-tools, bash-completion

        pacman -S trash-cli

        pacman -S pkgfile

        pacman -S bind-tools

        pacman -S bash-completion

> [trash-cli](https://github.com/andreafrancia/trash-cli): es una utilidad para prevenir el borrado accidental al usar el comando rm -rf

> [pkgfile](https://github.com/falconindy/pkgfile): permite buscar el comando ejecutado en la base de datos del repositorio.

> [bind-tools](https://www.isc.org/downloads/bind/): permite obtener la ISP al ejecutar 'ii' en la terminal.

> [bash-completion](https://github.com/scop/bash-completion): permite el autocompletado de bash

## Actualización

- Para actualizar solo abre la terminal y ejecuta:

    `updbashrc` para actualizar HyperTerm

    `updbashrc_custom` solo para actualizar el archivo `hyperterm/_custom.sh`

## Capturas de pantalla

### Git

![Alt git preview](images/git-preview.png?raw=true "git-preview")

### Temas

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

> El tema es configurable desde el archivo `$HOME/.hyperterm/_custom.sh`

## Restaurar

### Semi-Automático

1. Descargar el archivo `uninstall.sh`:

        wget https://git.sr.ht/~heckyel/hyperterm/tree/master/item/uninstall.sh -O "$HOME/uninstall.sh"

    o

        wget https://notabug.org/heckyel/hyperterm/raw/master/uninstall.sh -O "$HOME/uninstall.sh"

2. Ejecutar el archivo `uninstall.sh`:

        bash "$HOME/uninstall.sh"

3. Eliminar el archivo `uninstall.sh`:

        rm -v "$HOME/uninstall.sh"

### Manualmente

Si quieres dejar tu ordenador como estaba, borra los archivos copiados del paso 3 con:

    rm -vrf "$HOME/{.hyperterm/,.bashrc}"

y restaura los archivos ***.bak** del paso 1 ejecutando:

    for f in .bashrc .bash_aliases .bash_profile; do cp -v "$HOME/$f.bak" "$HOME/$f"; done

## Hacking

Ver [HACKING.md](HACKING.md)

## Contribuidores

   Los colaboradores de **HyperTerm** se encuentran en el archivo [AUTHORS](AUTHORS)

## Licencia

Esta obra esta bajo la Licencia [GNU GPLv3+](LICENSE)
