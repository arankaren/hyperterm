#!/bin/bash
# hyperterm uninstaller
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

# Show how to use this uninstaller
# --------------------------------
function show_usage() {
    msg "\n$0: Desinstalar HyperTerm" \
        "\n$0: Uninstall HyperTerm"
    msg "Comando:\n$0 [argumentos] \n" \
        "Usage:\n$0 [arguments] \n"
    msg "Argumentos:" \
        "Arguments:"
    msg "--help (-h): Muestra mensaje de ayuda" \
        "--help (-h): Display this help message"
    msg "--silent (-s): Desinstala sin solicitar entrada" \
        "--silent (-s): Uninstall without prompting for input"
    exit 0;
}

for param in "$@"; do
    shift
    case "$param" in
        "--help")               set -- "$@" "-h" ;;
        "--silent")             set -- "$@" "-s" ;;
        *)                      set -- "$@" "$param"
    esac
done

OPTIND=1
while getopts "hs" opt
do
    case "$opt" in
        "h") show_usage; exit 0 ;;
        "s") silent=true ;;
        "?") show_usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Uninstall
# ---------
function _uninstall() {
    if [ -z "$HYPER_BASH" ];
    then
        HYPER_BASH="$HOME/.hyperterm"
    fi

    case $OSTYPE in
        darwin*)
            CONFIG_FILE=.bash_profile
            ;;
        *)
            CONFIG_FILE=.bashrc
            ;;
    esac

    BACKUP_FILE=$CONFIG_FILE.bak

    if [ ! -e "$HOME/$BACKUP_FILE" ]; then
        msg_err "\033[0;33mEl archivo de respaldo $HOME/$BACKUP_FILE no fue encontrado.\033[0m" \
                "\033[0;33mBackup file $HOME/$BACKUP_FILE not found.\033[0m"

        test -w "$HOME/$CONFIG_FILE" &&
            mv "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.uninstall" &&
            msg "\033[0;32mEl archivo $HOME/$CONFIG_FILE ha sido movido a $HOME/$CONFIG_FILE.uninstall.\033[0m" \
                "\033[0;32mMoved your $HOME/$CONFIG_FILE to $HOME/$CONFIG_FILE.uninstall.\033[0m"
    else
        test -w "$HOME/$BACKUP_FILE" &&
            cp -a "$HOME/$BACKUP_FILE" "$HOME/$CONFIG_FILE" &&
            rm "$HOME/$BACKUP_FILE" &&
            msg "\033[0;32mTu archivo original $CONFIG_FILE ha sido restaurado.\033[0m" \
                "\033[0;32mYour original $CONFIG_FILE has been restored.\033[0m"
    fi

    if [[ -d $HOME/.hyperterm ]]; then
        rm -fr "$HOME/.hyperterm"
    fi

    msg "\033[1;32m==>\e[0m\033[1m Desintalación realizada con éxito! \e[m" \
        "\033[1;32m==>\e[0m\033[1m Uninstallation finished successfully! \e[m"

    msg "\033[0;32mDisculpe las molestias!! \e[m" \
        "\033[0;32mSorry to see you go!! \e[m"

    msg "\033[1;32m==>\e[0m\033[1m Finalmente realice este paso: \e[m" \
        "\033[1;32m==>\e[0m\033[1m Final steps to complete the uninstallation: \e[m"

    msg "\033[1;36m  ->\e[0m\033[1m Abra una nueva shell/tab/terminal \e[m" \
        "\033[1;36m  ->\e[0m\033[1m Open a new shell/tab/terminal \e[m"
}
# -------

if ! [[ $silent ]]; then
    while ! [ $silent ]
    do
        question=$(msg "¿Estás seguro de desinstalar HyperTerm? [s/N]: " \
                       "Are you sure to uninstall HyperTerm? [y/N]: ")

        read -r -p "$question" input
        case $input in
            [yY]|[sS]) _uninstall "$@"; break ;;
            [nN]|"") break ;;
            *) msg "Por favor responde sí o no" \
                   "Please answer yes or no.";;
        esac
    done
else
    _uninstall "$@"
fi
