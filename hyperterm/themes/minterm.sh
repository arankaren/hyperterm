#!/bin/bash

unset minterm

# Import colors
_colors_bash "$@"

: "${minterm:=\n\
\[${BOLD}${CYAN}\]┌─\
\[${BOLD}${YELLOW}\]\u\
\[${BOLD}${CYAN}\]@\
\[${BOLD}${GREY}\]\h\[$RESET\] \
\$(exitstatus)\[$RESET\] \
\[${BOLD}${WHITE}\][\$PWD]\
\$(__prompt_git)\n\
\[${BOLD}${CYAN}\]╰─➤\[$RESET\] \
\$( echo -n \"\[${BOLD}${GREY}\]\$(date +%H:%M)\" )\[$RESET\] \
\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
