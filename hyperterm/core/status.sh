#!/bin/bash

# System Status
function exitstatus(){
    local retval=$?
    unset status

    # Import colors
    _colors_bash "$@"

    case $retval in
    0)
        status="[${retval}]"
        printf '%b%s' "${BOLD}${CYAN}" "${status}"
    ;;
    1)
        status="[${retval}]"
        printf '%b%s' "${BOLD}${PURPLE}" "${status}"
    ;;
    *)
        status="[${retval}]"
        printf '%b%s' "${BOLD}${RED}" "${status}"
    ;;
    esac
}
