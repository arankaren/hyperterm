#!/bin/bash

unset joy

# Import colors
_colors_bash "$@"

: "${joy:=\n\
\[${BOLD}${CYAN}\]\342\224\214\342\224\200[\
\[${BOLD}${YELLOW}\]\u\
\[${BOLD}${CYAN}\]@\
\[${BOLD}${GREY}\]\h\
\[${BOLD}${CYAN}\]]\
\342\224\200[\
\[${RESET}\]\w\
\[${BOLD}${CYAN}\]]\
\342\224\200\
\$(exitstatus)\
\[${BOLD}${CYAN}\]\
\342\224\200\
\$(__prompt_git)\
\[${BOLD}${CYAN}\]\342\224\200[\
\[${RESET}\]\t\
\[${BOLD}${CYAN}\]]\n\
\[${BOLD}${CYAN}\]\342\224\224\342\224\200\342\224\200\342\225\274\
\[${BOLD}${GREEN}\] $SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
