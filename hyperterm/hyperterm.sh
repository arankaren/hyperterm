#!/bin/bash
#
# Custom Prompt Shell
#
# $HOME/.bashrc
#
# License: GNU GPLv3 or later
# See archive AUTHORS
#
# shellcheck disable=SC1090

xhost +local:root > /dev/null 2>&1

#---------------
# Check bash
#---------------
if [[ ! -f /bin/bash ]]; then
    if [[ $(command -v bash) != /bin/bash ]]; then
        printf '%s\n' "/bin/bash not found.  Please run 'sudo ln -s $(command -v bash) /bin/bash'"
    fi
fi

#---------------
# Emacs support
#---------------
[ "$TERM" = "dumb" ] && export PAGER=/bin/cat

#----------------
# bash_aliases
#----------------
if [[ -f $HOME/.hyperterm/tools/aliases.sh ]]; then source "$HOME/.hyperterm/tools/aliases.sh"; else true; fi

#----------------
# bash_functions
#----------------
# [ core ]
if [[ -f $HOME/.hyperterm/core/autocomplete.sh ]]; then source "$HOME/.hyperterm/core/autocomplete.sh"; else true; fi
if [[ -f $HOME/.hyperterm/core/colors.sh ]]; then source "$HOME/.hyperterm/core/colors.sh"; else true; fi
if [[ -f $HOME/.hyperterm/core/git.sh ]]; then source "$HOME/.hyperterm/core/git.sh"; else true; fi
if [[ -f $HOME/.hyperterm/core/languages.sh ]]; then source "$HOME/.hyperterm/core/languages.sh"; else true; fi
if [[ -f $HOME/.hyperterm/core/status.sh ]]; then source "$HOME/.hyperterm/core/status.sh"; else true; fi
if [[ -f $HOME/.hyperterm/core/update.sh ]]; then source "$HOME/.hyperterm/core/update.sh"; else true; fi

#-------------
# Theme
#-------------
if [[ -f $HOME/.hyperterm/themes/default.sh ]]; then source "$HOME/.hyperterm/themes/default.sh"; else true; fi

#--------------
# bashrc_custom
#--------------
if [[ -f $HOME/.hyperterm/_custom.sh ]]; then source "$HOME/.hyperterm/_custom.sh"; else true; fi

#---------------
# Shell prompt
#---------------
if [[ -d $HOME/.hyperterm && -f $HOME/.hyperterm/_custom.sh && -s $HOME/.hyperterm/_custom.sh ]]; then
    PS1="${prompt:=$prompt}"
elif [[ -d $HOME/.hyperterm ]]; then
    PS1="${prompt:=$default}"
else
    PS1='[\u@\h \W]\$ '
fi
#Interactive Prompt
PS2="${_psi:=$_psi}"

# No double entries in the shell history.
export HISTCONTROL=ignoreboth:erasedups

# global unsets
unset SYMBOL prompt _psi

# clean up themes
unset default light_theme minterm pure special

# clean up colors
unset BLUE CYAN GREEN GREY LEMON ORANGE PURPLE \
      RED WHITE YELLOW BOLD RESET
