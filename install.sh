#!/bin/bash
# shellcheck source=/dev/null
# hyperterm installer
# shellcheck disable=SC1117

# Languages
# ---------
function msg() {
    case ${LANG/_*/} in
        es)
            echo -e "$1"
            ;;
        *)
            echo -e "$2"
            ;;
    esac
}

function msg_err() {
    case ${LANG/_*/} in
        es)
            echo -e "$1" >&2
            ;;
        *)
            echo -e "$2" >&2
            ;;
    esac
}

# Check URL's
# -----------
function _which() {
    command -v "$1" &> /dev/null
}

function _url_exists() {
    if  _which wget; then
        if wget --spider "$1" 2>/dev/null; then
            return 0 # URL 'ok'
        else
            return 1 # URL 'fail'
        fi
    elif _which curl; then
        if curl --output /dev/null --silent --head --fail "$1"; then
            return 0 # URL 'ok'
        else
            return 1 # URL 'fail'
        fi
    fi
}

function _urls() {
    URL_1="https://git.sr.ht/~heckyel/hyperterm"
    URL_2="https://notabug.org/heckyel/hyperterm"

    if [[ $(_url_exists "$URL_1") -eq 0 ]]; then
        URL="$URL_1"
    elif [[ $(_url_exists "$URL_2") -eq 0 ]]; then
        URL="$URL_2"
    fi
}
# -----------

# Show how to use this installer
# ------------------------------
function show_usage() {
    msg "\n$0: Instalar HyperTerm" \
        "\n$0: Install HyperTerm"
    msg "Comando:\n$0 [argumentos] \n" \
        "Usage:\n$0 [arguments] \n"
    msg "Argumentos:" \
        "Arguments:"
    msg "--help (-h): Muestra mensaje de ayuda" \
        "--help (-h): Display this help message"
    msg "--silent (-s): Instala la configuración predeterminada sin solicitar entrada" \
        "--silent (-s): Install default settings without prompting for input"
    msg "--no-modify-config (-n): No modifica el archivo de configuración existente" \
        "--no-modify-config (-n): Do not modify existing config file"
    exit 0;
}

# Clone
#------
function clone_new() {
    _urls "$@"

    # clone
    msg "\e[1;32m==>\e[0m\033[1m Clonando hyperterm... \e[m" \
        "\e[1;32m==>\e[0m\033[1m Cloning hyperterm... \e[m"
    git clone "$URL" "/tmp/hyperterm/" --depth=1

    # copy
    msg "\e[1;32m==>\e[0m\033[1m Copiando hyperterm... \e[m" \
        "\e[1;32m==>\e[0m\033[1m Copying hyperterm... \e[m"
    if [[ $silent ]]; then
        install -d -m755 "$HOME/.hyperterm/"
        cp -r /tmp/hyperterm/hyperterm/* "$HOME/.hyperterm/"
        install -m644 /tmp/hyperterm/.bash_profile "$HOME/"
        install -d -m755 "$HOME/.hyperterm/template/"
        install -m644 /tmp/hyperterm/template/bash_profile.template.bash "$HOME/.hyperterm/template/"
    else
        install -d -m755 -v "$HOME/.hyperterm/"
        cp -rv /tmp/hyperterm/hyperterm/* "$HOME/.hyperterm/"
        install -m644 -v /tmp/hyperterm/.bash_profile "$HOME/"
        install -d -m755 -v "$HOME/.hyperterm/template/"
        install -m644 -v /tmp/hyperterm/template/bash_profile.template.bash "$HOME/.hyperterm/template/"
    fi
}

function clean_temp() {
    # clean up temp files
    msg "\e[1;32m==>\e[0m\033[1m Limpiando archivos temporales... \e[m" \
        "\e[1;32m==>\e[0m\033[1m Clean up temp files... \e[m"
    if [[ $silent ]]; then
        rm -rf /tmp/hyperterm/
        if [[ -f "$HOME/.hyperterm/template/bash_profile.template.bash" ]]; then
            rm -fr "$HOME/.hyperterm/template/"
        fi
    else
        rm -rfv /tmp/hyperterm/
        if [[ -f "$HOME/.hyperterm/template/bash_profile.template.bash" ]]; then
            rm -frv "$HOME/.hyperterm/template/"
        fi
    fi
}

# Back up existing profile and create new one for hyperterm
# ---------------------------------------------------------
function backup_new() {
    clone_new "$@"
    test -w "$HOME/$CONFIG_FILE" &&
        cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak" &&
        msg "\033[0;36mTu archivo original $CONFIG_FILE ha sido respaldado a $CONFIG_FILE.bak \033[0m" \
            "\033[0;36mYour original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak \033[0m"

    sed "s|{{HYPER_BASH}}|$HYPER_BASH|" "$HYPER_BASH/.hyperterm/template/bash_profile.template.bash" > "$HOME/$CONFIG_FILE"
    msg "\033[0;36mPlantilla copiada de $CONFIG_FILE dentro de ~/$CONFIG_FILE \033[0m" \
        "\033[0;36mCopied the template $CONFIG_FILE into ~/$CONFIG_FILE \033[0m"
    clean_temp "$@"
}

for param in "$@"; do
    shift
    case "$param" in
        "--help")               set -- "$@" "-h" ;;
        "--silent")             set -- "$@" "-s" ;;
        "--no-modify-config")   set -- "$@" "-n" ;;
        *)                      set -- "$@" "$param"
    esac
done

OPTIND=1
while getopts "hsn" opt
do
    case "$opt" in
        "h") show_usage; exit 0 ;;
        "s") silent=true ;;
        "n") no_modify_config=true ;;
        "?") show_usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

HYPER_BASH="$(cd "$(dirname "$0")" && pwd)"

case $OSTYPE in
    darwin*)
        CONFIG_FILE=.bash_profile
        ;;
    *)
        CONFIG_FILE=.bashrc
        ;;
esac

BACKUP_FILE=$CONFIG_FILE.bak
msg "Instalando HyperTerm" \
    "Installing HyperTerm"
if ! [[ $silent ]] && ! [[ $no_modify_config ]]; then
    if [ -e "$HOME/$BACKUP_FILE" ]; then
        msg_err "\033[0;36mEl archivo de respaldo ya existe. Asegúrese de hacer una copia de seguridad de su .bashrc antes de ejecutar esta instalación. \033[0m" \
                "\033[0;36mBackup file already exists. Make sure to backup your .bashrc before running this installation. \033[0m"
        while ! [ $silent ];  do
            question=$(msg "¿Desea sobrescribir la copia de seguridad existente? Esto eliminará su archivo de copia de seguridad existente ($HOME/$BACKUP_FILE) [s/N] " \
                           "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$BACKUP_FILE) [y/N] ")

            read -e -n 1 -r -p "$question" RESP
            case $RESP in
                [yY]|[sS])
                    break
                    ;;
                [nN]|"")
                    msg "\033[91mInstalación interrumpida. Por favor vuelve pronto!\033[m" \
                        "\033[91mInstallation aborted. Please come back soon!\033[m"
                    exit 1
                    ;;
                *)
                    msg "\033[91mPor favor elija sí o no.\033[m" \
                        "\033[91mPlease choose y or n.\033[m"
                    ;;
            esac
        done
    fi

    while ! [ $silent ]; do
        question=$(msg "¿Le gustaría conservar su configuración de $CONFIG_FILE y agregar plantillas de HyperTerm al final? [s/N] " \
                       "Would you like to keep your config $CONFIG_FILE and append HyperTerm templates at the end? [y/N] ")
        read -e -n 1 -r -p "$question" choice
        case $choice in
            [yY]|[sS])
                clone_new "$@"
                test -w "$HOME/$CONFIG_FILE" &&
                    cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak" &&
                    msg "\033[0;36mTu archivo original $CONFIG_FILE ha sido respaldado a $CONFIG_FILE.bak \033[0m" \
                        "\033[0;36mYour original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak \033[0m"

                (sed "s|{{HYPER_BASH}}|$HYPER_BASH|" "$HYPER_BASH/.hyperterm/template/bash_profile.template.bash" | tail -n +2) >> "$HOME/$CONFIG_FILE"
                msg "\033[0;36mla plantilla HyperTerm ha sido agregada a $CONFIG_FILE\033[0m" \
                    "\033[0;36mHyperTerm template has been added to your $CONFIG_FILE\033[0m"
                clean_temp "$@"
                break
                ;;
            [nN]|"")
                backup_new "$@"
                break
                ;;
            *)
                msg "\033[91mPor favor elija sí o no.\033[m" \
                        "\033[91mPlease choose y or n.\033[m"
                ;;
        esac
    done
elif [[ $silent ]] && ! [[ $no_modify_config ]]; then
    # backup/new by default
    backup_new "$@"
fi

echo ""
msg "\e[1;32m==>\e[0m\033[1m Instalación finalizada con éxito! Disfrute HyperTerm! \e[m" \
    "\e[1;32m==>\e[0m\033[1m Installation finished successfully! Enjoy HyperTerm! \e[m"

msg "\033[0;36mPara comenzar a usarlo, abra una nueva pestaña o haga 'source $HOME/$CONFIG_FILE'.\033[0m" \
    "\033[0;36mTo start using it, open a new tab or 'source $HOME/$CONFIG_FILE'.\033[0m"

echo ""
msg "¡Muchas gracias! por instalar" \
    "Thank you! for install"
echo -e '\033[0;36m     __  __                     ______                   '
echo -e '\033[0;36m    / / / /_  ______  ___  ____/_  __/__  _________ ___  '
echo -e '\033[0;36m   / /_/ / / / / __ \/ _ \/ ___// / / _ \/ ___/ __ `__ \ '
echo -e '\033[0;36m  / __  / /_/ / /_/ /  __/ /   / / /  __/ /  / / / / / / '
echo -e '\033[0;36m /_/ /_/\__, / .___/\___/_/   /_/  \___/_/  /_/ /_/ /_/  '
echo -e '\033[0;36m       /____/_/                                          '
echo -e '\033[m'
msg "Para evitar problemas y mantener su shell, habilite solo las funciones que realmente desea utilizar desde $HOME/.hyperterm/_custom.sh" \
    "To avoid issues and to keep your shell lean, please enable only features you really want to use from $HOME/.hyperterm/_custom.sh"
msg "Puede reportarnos errores en \033[0;36mhttps://todo.sr.ht/~heckyel/hyperterm \033[0m" \
    "You can report errors issues in \033[0;36mhttps://todo.sr.ht/~heckyel/hyperterm \033[0m"
