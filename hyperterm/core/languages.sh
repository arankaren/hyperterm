#!/bin/bash

###################
# Message functions
###################

# firts arguments is spanish
# second arguments is english

function msg() {
    case ${LANG/_*/} in
        es)
            printf '%s\n' "$1"
        ;;
        *)
            printf '%s\n' "$2"
        ;;
    esac
}

function msg_err() {
    case ${LANG/_*/} in
        es)
            printf '%s\n' "$1" >&2
        ;;
        *)
            printf '%s\n' "$2" >&2
        ;;
    esac
}
