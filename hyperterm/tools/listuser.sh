#!/bin/bash

# List user
function listuser() {
    case ${LANG/_*/} in
        es)
            printf '%s\n' "Usuario       UID   Shell   "
            printf '%s\n' "-----------  -----  --------"
            awk -F':' '$3>=1000 && $3<=60000 { printf "%-12s %4d %11s\n", $1, $3, $7 | "sort -r"}' /etc/passwd
            ;;
        *)
            printf '%s\n' "Users         UID   Shell   "
            printf '%s\n' "-----------  -----  --------"
            awk -F':' '$3>=1000 && $3<=60000 { printf "%-12s %4d %11s\n", $1, $3, $7 | "sort -r"}' /etc/passwd
            ;;
    esac
}
