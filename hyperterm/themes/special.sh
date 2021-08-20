#!/bin/bash
# shellcheck disable=SC1117

unset special

# Import colors
_colors_bash "$@"

_prompt_local_name() {
    case ${LANG/_*/} in
        es)
            printf "Ubicación Actual:"
            ;;
        *)
            printf "Current Location:"
            ;;
    esac
}

special=("\n\
\[$RESET\]\
\[${BOLD}${YELLOW}\][$(_prompt_local_name)\
\[$RESET\] \[${BOLD}${GREY}\]\w\
\[${BOLD}${YELLOW}\]]\[$RESET\] \
\[${BOLD}${CYAN}\]hist:\!\[$RESET\]\n\
\[${BOLD}${GREY}\]\
\D{%Y-%m-%d}@\D{%I:%M%p}\[$RESET\] \
\$(exitstatus)\[$RESET\]\
\$(__prompt_git)\n\
\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]")

export special

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
