#!/bin/bash

unset pure

# Import colors
_colors_bash "$@"

: "${pure:=\
\[${BOLD}${GREEN}\]\u\[$RESET\] \
\[${BOLD}${YELLOW}\][\
\[${BOLD}${RED}\]\w\
\[${BOLD}${YELLOW}\]]\[$RESET\] \
\$(exitstatus)\[$RESET\] \
\[${BOLD}${BLUE}\](\$(date +%H:%M:%S))\
\$(__prompt_git)\
\n\[${BOLD}${CYAN}\]$SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
