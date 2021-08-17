#!/bin/bash

unset light_theme

# Import colors
_colors_bash "$@"

: "${light_theme:=\n\
\[$RESET\]\
\[${BOLD}${CYAN}\]┌─\[$RESET\]\
\[${BOLD}${YELLOW}\]\u\[$RESET\]\
\[${BOLD}${CYAN}\]@\[$RESET\]\
\[${BOLD}${GREY}\]\h\[$RESET\] \
\$(exitstatus)\[$RESET\] \
\[${BOLD}${WHITE}\][\$PWD]\
\$(__prompt_git)\
\n\[${BOLD}${CYAN}\]╰─➤\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
