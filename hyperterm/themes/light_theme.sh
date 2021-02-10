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
\$( _prompt_is_on_git &> /dev/null && \
  echo -n \" \[${BOLD}${WHITE}\]on\[$RESET\] \" && \
  echo -n \"\$(_prompt_get_git_info)\" && \
  echo -n \"\[${BOLD}${RED}\]\$(_get_git_progress)\" && \
  echo -n \"\[$RESET\]\")\
\n\[${BOLD}${CYAN}\]╰─➤\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
