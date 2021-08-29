#!/bin/bash

unset simple

# Import colors
_colors_bash "$@"

__time_out_command() {
    awk '{ print $1 }' /proc/loadavg
}

: "${simple:=\n\
\[${RESET}\]\
\[${BOLD}${GREY}\]\
\$(exitstatus)\[$RESET\] \
\[${BOLD}${GREY}\]\
\$(__time_out_command)\[$RESET\] \
\[${BOLD}${WHITE}\]\W\[$RESET\]\
\$(__prompt_git)\n\
\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
