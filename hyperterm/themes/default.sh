#!/bin/bash
# shellcheck disable=SC1117

unset default

# Import colors
_colors_bash "$@"

default=("\n\
\[$RESET\]\
\[${BOLD}${YELLOW}\][ \u \
\[${BOLD}${BLUE}\]| \D{%Y-%m-%d} |\
\[${BOLD}${RED}\] \D{%I:%M%p} ]\n\
\[$RESET\]\
\[${BOLD}${WHITE}\][\$PWD]\[$RESET\] \
\$(exitstatus)\[$RESET\]\
\$(__prompt_git)\
\n\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]")

export default

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
