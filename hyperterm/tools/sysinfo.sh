#!/bin/bash

# System information
function ii() {
    __network "$1" > /dev/null 2>&1  # import network
    case ${LANG/_*/} in
        es)
            printf '%s\e[1;36m%s\e[m\n' "Has iniciado sesión en " "$(hostname -f)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Información adicional:" "$(uname -a)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Usuarios Conectados:" "$(who -u)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Fecha actual:" "$(date)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Estadísticas de la máquina:" "$(uptime)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Estadísticas de la memoria:" "$(free)"
            printf '\n\e[1;32m%s\e[m\n' "Dirección IP Local:"
            printf '%s\n' "${MY_IP:-"No conectado"}"
            printf '\n\e[1;32m%s\e[m\n' "Dirección ISP:"
            printf '%s\n' "${MY_ISP:-"No conectado"}"
            ;;
        *)
            printf '%s\e[1;36m%s\e[m\n' "You are logged on " "$(hostname -f)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Additionnal information:" "$(uname -a)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Users logged:" "$(who -u)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Current date:" "$(date)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Machine stats:" "$(uptime)"
            printf '\n\e[1;32m%s\e[m\n%s\n' "Memory stats:" "$(free)"
            printf '\n\e[1;32m%s\e[m\n' "Local IP Address:"
            printf '%s\n' "${MY_IP:-"Not connected"}"
            printf '\n\e[1;32m%s\e[m\n' "ISP Address:"
            printf '%s\n' "${MY_ISP:-"Not connected"}"
            ;;
    esac
}
