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
\$( _prompt_is_on_git &> /dev/null && \
  echo -n \" \[${BOLD}${WHITE}\]on\[$RESET\] \" && \
  echo -n \"\$(_prompt_get_git_info)\" && \
  echo -n \"\[${BOLD}${RED}\]\$(_get_git_progress)\" && \
  echo -n \"\[$RESET\]\")\
\n\[${BOLD}${CYAN}\]$SYMBOL \[$RESET\]}"

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
