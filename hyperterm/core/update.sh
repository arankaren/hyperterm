#!/bin/bash
# shellcheck source=/dev/null
#------------------
# Update functions
#------------------
function _which() {
    command -v "$1" &> /dev/null
}

# Check URL's
# ---------------------
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
        RAW="$URL_1/blob/master"
    elif [[ $(_url_exists "$URL_2") -eq 0 ]]; then
        URL="$URL_2"
        RAW="$URL_2/raw/master"
    fi
}
# ----------------------

function ifexists_custom() {

    _urls "$@"

    if [ ! -e "$HOME/.hyperterm/_custom.sh" ]; then
        case $1 in
            wget) wget "$RAW/hyperterm/_custom.sh" -O "$HOME/.hyperterm/_custom.sh" ;;
            curl) curl "$RAW/hyperterm/_custom.sh" -o "$HOME/.hyperterm/_custom.sh" ;;
            git)  cp -v /tmp/hyperterm/hyperterm/_custom.sh "$HOME/.hyperterm/"     ;;
        esac
    fi
}

function updbashrc() {

    _urls "$@"

    # data integration
    if _which wget; then
        wget -nv "$RAW/hyperterm/hyperterm.sha512" -O "$HOME/.hyperterm/hyperterm.sha512" &> /dev/null
        ifexists_custom wget &> /dev/null
    elif _which curl; then
        curl "$RAW/hyperterm/hyperterm.sha512" -o "$HOME/.hyperterm/hyperterm.sha512" &> /dev/null
        ifexists_custom curl &> /dev/null
    fi

    # checksum of data verification
    (cd "$HOME/.hyperterm/" && sha512sum -c hyperterm.sha512 &> /dev/null)
    _interger=$?

    if _which git; then
        if [[ "$_interger" -eq 0 ]]; then
            # Import colors
            _colors_bash "$@"
            printf '%b' "${BOLD}${CYAN}"
            printf '%s\n' '     __  __                     ______                   '
            printf '%s\n' '    / / / /_  ______  ___  ____/_  __/__  _________ ___  '
            printf '%s\n' '   / /_/ / / / / __ \/ _ \/ ___// / / _ \/ ___/ __ `__ \ '
            printf '%s\n' '  / __  / /_/ / /_/ /  __/ /   / / /  __/ /  / / / / / / '
            printf '%s\n' ' /_/ /_/\__, / .___/\___/_/   /_/  \___/_/  /_/ /_/ /_/  '
            printf '%s\n' '       /____/_/                                          '
            printf '%s\n' '                                                         '
            printf '%b' "${BOLD}${GREY}"
            msg "¡Hurra! HyperTerm se ha actualizado y/o está en la versión actual." \
                "Hooray! HyperTerm has been updated and/or is at the current version."

            msg "Puede reportarnos errores en https://todo.sr.ht/~heckyel/hyperterm" \
                "You can report errors issues in https://todo.sr.ht/~heckyel/hyperterm"

            msg "Consigue tu copia de HyperTerm en: https://git.sr.ht/~heckyel/hyperterm" \
                "Get your HyperTerm copy on: https://git.sr.ht/~heckyel/hyperterm"
            printf '%b\n' "$RESET"
        else
            if [[ $(_url_exists "$URL") -eq 0 ]]; then
                # clone '--depth=1' not support cgit
                (git clone $URL /tmp/hyperterm/ --depth=1 &> /dev/null)
                printf '%s\r' "#####                   (33%)"
                sleep 1
                # core
                for i in autocomplete.sh colors.sh git.sh languages.sh status.sh update.sh; do
                    install -m644 /tmp/hyperterm/hyperterm/core/$i "$HOME/.hyperterm/core/$i"
                done
                # themes
                for i in default.sh joy.sh light_theme.sh minterm.sh pure.sh simple.sh special.sh; do
                    install -m644 /tmp/hyperterm/hyperterm/themes/$i "$HOME/.hyperterm/themes/$i"
                done
                # tools
                (cp -f /tmp/hyperterm/hyperterm/tools/* "$HOME/.hyperterm/tools/" &> /dev/null)

                for i in hyperterm.sh hyperterm.sha512; do
                    install -m644 /tmp/hyperterm/hyperterm/$i "$HOME/.hyperterm/$i"
                done
                (cp -f /tmp/hyperterm/.bash_profile "$HOME/" &> /dev/null)
                printf '%s\r' "#############           (66%)"
                (ifexists_custom git &> /dev/null)
                sleep 1
                (rm -fr /tmp/hyperterm/)
                printf '%s\n' "####################### (100%) done!"
                source "$HOME/.bashrc"
            else
                msg_err "El repo esta deshabilitado o no hay conexión a Internet" \
                        "The repo is disabled or connection failed"
                return 1
            fi
        fi
    else
        msg_err "No hay curl y git. Por favor, instale los programas para actualizar HyperTerm" \
                "I couldn't find not curl and git. Please, install the programs to update HyperTerm"
        return 1
    fi
}

function updbashrc_custom() {

    _urls "$@"

    if [[ $(_url_exists "$URL") -eq 0 ]]; then
        while true
        do
            function _copy_c() {
                if _which wget; then
                    wget "$RAW/hyperterm/_custom.sh" -O "$HOME/.hyperterm/_custom.sh"; source "$HOME/.bashrc"
                elif _which curl; then
                    curl "$RAW/hyperterm/_custom.sh" -o "$HOME/.hyperterm/_custom.sh"; source "$HOME/.bashrc"
                fi
            }

            question=$(msg "¿Estás seguro de sobre-escribir _custom.sh? [s/N]: " \
                           "Are you sure to overwrite _custom.sh? [y/N]: ")
            read -r -p "$question" input
            case $input in
                [sS]|[yY]) _copy_c "$@"; break ;;
                [nN]|"") break ;;
                *) msg "Por favor responde sí o no" \
                       "Please answer yes or no.";;
            esac
        done
    else
        msg_err "El repo esta deshabilitado o no hay conexión a Internet" \
                "The repo is disabled or connection failed"
        return 1
    fi
}
