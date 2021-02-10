#!/bin/bash
## [Alias]
# shellcheck disable=SC1090,SC1091,SC2034,SC2154

#---------------
# Fullyclean
#---------------
alias ac='clean && clear'

#---------------
# Theme's prompt
#---------------
if [[ -f $HOME/.hyperterm/themes/joy.sh ]]; then source "$HOME/.hyperterm/themes/joy.sh"; else true; fi
if [[ -f $HOME/.hyperterm/themes/light_theme.sh ]]; then source "$HOME/.hyperterm/themes/light_theme.sh"; else true; fi
if [[ -f $HOME/.hyperterm/themes/minterm.sh ]]; then source "$HOME/.hyperterm/themes/minterm.sh"; else true; fi
if [[ -f $HOME/.hyperterm/themes/pure.sh ]]; then source "$HOME/.hyperterm/themes/pure.sh"; else true; fi
if [[ -f $HOME/.hyperterm/themes/special.sh ]]; then source "$HOME/.hyperterm/themes/special.sh"; else true; fi

#---------------
# Set Theme
#---------------
unset prompt
prompt="${default}"
#prompt="${joy}"
#prompt="${light_theme}"
#prompt="${minterm}"
#prompt="${pure}"
#prompt="${special}"

#---------------
# Tools
#---------------
if [[ -f $HOME/.hyperterm/tools/compress.sh ]]; then source "$HOME/.hyperterm/tools/compress.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/export.sh ]]; then source "$HOME/.hyperterm/tools/export.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/listuser.sh ]]; then source "$HOME/.hyperterm/tools/listuser.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/network.sh ]]; then source "$HOME/.hyperterm/tools/network.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/proxy.sh ]]; then source "$HOME/.hyperterm/tools/proxy.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/rar2zip.sh ]]; then source "$HOME/.hyperterm/tools/rar2zip.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/ruby.sh ]]; then source "$HOME/.hyperterm/tools/ruby.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/ssh-agent.sh ]]; then source "$HOME/.hyperterm/tools/ssh-agent.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/sysinfo.sh ]]; then source "$HOME/.hyperterm/tools/sysinfo.sh"; else true; fi
if [[ -f $HOME/.hyperterm/tools/virtualenv.sh ]]; then source "$HOME/.hyperterm/tools/virtualenv.sh"; else true; fi
# if [[ -f $HOME/.hyperterm/tools/vconverter.sh ]]; then source "$HOME/.hyperterm/tools/vconverter.sh"; else true; fi

#---------------
# Screenfetch
#---------------
if command -v screenfetch &> /dev/null; then screenfetch; else true; fi

#---------------
# PKGFILE
#---------------
if [[ -f /usr/share/doc/pkgfile/command-not-found.bash ]]; then source /usr/share/doc/pkgfile/command-not-found.bash; else true; fi

#---------------
# Trash-cli
#---------------
if command -v trash &> /dev/null; then alias rm='echo "This is not the command you are looking for."; false'; else true; fi
# Then, if you really want to use rm, simply prepend a slash to bypass the alias:
# \rm file-without-hope
