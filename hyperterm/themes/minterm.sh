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
\$( _prompt_is_on_git &> /dev/null && \
  echo -n \" \[${BOLD}${WHITE}\]on\[$RESET\] \" && \
  echo -n \"\$(_prompt_get_git_info)\" && \
  echo -n \"\[${BOLD}${RED}\]\$(_get_git_progress)\" && \
  echo -n \"\[$RESET\]\")\n\
\[${BOLD}${CYAN}\]╰─➤\[$RESET\] \
\$( echo -n \"\[${BOLD}${GREY}\]\$(date +%H:%M)\" )\[$RESET\] \
\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
