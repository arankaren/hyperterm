#!/bin/bash

unset simple

# Import colors
_colors_bash "$@"

__time_out_command() {
    cut -d\  -f1 /proc/loadavg
}

: "${simple:=\n\
\[${RESET}\]\
\[${BOLD}${GREY}\]\
\$(__time_out_command) \
\$(exitstatus)\
\$(__prompt_git)\
\[${BOLD}${GREEN}\] $SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
