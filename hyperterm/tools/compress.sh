#!/bin/bash
# ex - archive extractor
# usage: ex <file>
function ex() {
    if [ -f "$1" ] ; then
        # shellcheck disable=SC2221,SC2222
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.tar.xz)    tar xf "$1"     ;;
            *.tar.lz)    tar xvf "$1"    ;;
            *.lz)        lzip -d "$1"    ;;
            *.7z)        7z x "$1"       ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.rar)       unar "$1"       ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.xz)        unxz  "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.zip)       unzip "$1"      ;;
            *)           msg_err "No se puede extraer '$1' vía ex()" \
                                 "'$1' cannot be extracted via ex()"
                         return 1 ;;
        esac
    else
        msg_err "'$1' no es un archivo válido ¯\_(ツ)_/¯" \
                "'$1' is not a valid file ¯\_(ツ)_/¯"
        return 1
    fi
}

# Compress files or directories
function cex() {

    function option_compress_f() {
        printf '%s\n' "1) 7z"
        printf '%s\n' "2) bz2"
        printf '%s\n' "3) gz"
        printf '%s\n' "4) tar.bz2"
        printf '%s\n' "5) tar.gz"
        printf '%s\n' "6) tar.xz"
        printf '%s\n' "7) tar.lz"
        printf '%s\n' "8) tar"
        printf '%s\n' "9) tbz2"
        printf '%s\n' "10) tgz"
        printf '%s\n' "11) Z"
        printf '%s\n' "12) zip"
    }

    function option_compress_d() {
        printf '%s\n' "1) 7z"
        printf '%s\n' "2) tar.bz2"
        printf '%s\n' "3) tar.gz"
        printf '%s\n' "4) tar.xz"
        printf '%s\n' "5) tar.lz"
        printf '%s\n' "6) tar"
        printf '%s\n' "7) tbz2"
        printf '%s\n' "8) tgz"
        printf '%s\n' "9) zip"
    }

    function log_compress() {
        msg "Que tenga un buen día \o/" \
            "You have a nice day \o/"
    }

    function invalid_option() {
        msg "Archivo inválido u Opción no listada ¯\_(ツ)_/¯" \
            "Invalid file or Option not listed ¯\_(ツ)_/¯"
        return 1
    }

    function compress_f() {
        read -r A
        case $A in
            1) 7z a "${1}.7z" "$1"                  ;;
            2) bzip2 -k "$1"                        ;;
            3) gzip --best --keep "$1"              ;;
            4) tar -c "$1" | bzip2 > "${1}.tar.bz2" ;;
            5) tar -czvf "${1}.tar.gz" "$1"         ;;
            6) tar cJvf "${1}.tar.xz" "$1"          ;;
            7) tar -cvf "${1}.tar.lz" --lzip "$1"   ;;
            8) tar -cvf "${1}.tar" "$1"             ;;
            9) tar -c "$1" | bzip2 > "${1}.tbz2"    ;;
            10) tar -czvf "${1}.tgz" "$1"           ;;
            11) tar -czvf "${1}.z" "$1"             ;;
            12) zip -r "${1}.zip" "$1"              ;;
            0) log_compress "$@"                    ;;
            *) invalid_option "$@"                  ;;
        esac
    }

    function compress_d() {
        read -r A
        case $A in
            1) 7z a "${1%/}.7z" "$1"                  ;;
            2) tar -c "$1" | bzip2 > "${1%/}.tar.bz2" ;;
            3) tar -czvf "${1%/}.tar.gz" "$1"         ;;
            4) tar cJvf "${1%/}.tar.xz" "$1"          ;;
            5) tar -cvf "${1%/}.tar.lz" --lzip "${1}" ;;
            6) tar -cvf "${1%/}.tar" "$1"             ;;
            7) tar -c "$1" | bzip2 > "${1%/}.tbz2"    ;;
            8) tar -czvf "${1%/}.tgz" "$1"            ;;
            9) zip -r "${1%/}.zip" "$1"               ;;
            0) log_compress "$@"                      ;;
            *) invalid_option "$@"                    ;;
        esac
    }

    # Run
    if [[ -f "$1" ]] ; then
        case ${LANG/_*/} in
            es)
                # Print viewport user
                printf '%s\n' "Elige una acción"
                option_compress_f "$@"
                printf '%s\n' "0) salir"
                printf "Inserta la opción aquí:"
                compress_f "$@"
                ;;

            *)
                # Print viewport user
                printf '%s\n' "Choose option"
                option_compress_f "$@"
                printf '%s\n' "0) exit"
                printf "Insert the option here:"
                compress_f "$@"
                ;;
        esac
    elif [[ -d "$1" ]] ; then
        case ${LANG/_*/} in
            es)
                # Print viewport user
                printf '%s\n' "Elige una acción"
                option_compress_d "$@"
                printf '%s\n' "0) salir"
                printf "Inserta la opción aquí:"
                compress_d "$@"
                ;;

            *)
                # Print viewport user
                printf '%s\n' "Choose option"
                option_compress_d "$@"
                printf '%s\n' "0) exit"
                printf "Insert the option here:"
                compress_d "$@"
                ;;
        esac
    else
        msg_err "'$1' no es un archivo o directorio válido ¯\_(ツ)_/¯" \
                "'$1' is not a valid file or directory ¯\_(ツ)_/¯"
        return 1
    fi
}

unset -f compress_f
unset -f compress_d
unset -f log_compress
unset -f option_compress_f
unset -f option_compress_d
unset -f invalid_option
