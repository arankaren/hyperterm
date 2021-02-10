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
\$( _prompt_is_on_git &> /dev/null && \
  echo -n \" \[${BOLD}${WHITE}\]on\[$RESET\] \" && \
  echo -n \"\$(_prompt_get_git_info)\" && \
  echo -n \"\[${BOLD}${RED}\]\$(_get_git_progress)\" && \
  echo -n \"\[$RESET\]\")\
\n\[${BOLD}${GREEN}\]$SYMBOL \[$RESET\]")

export default

unset _psi
: "${_psi:=\[${BOLD}${CYAN}\]=>\[$RESET\] }"
