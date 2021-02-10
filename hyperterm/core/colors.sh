#!/bin/bash

function _colors_bash () {
    if tput setaf 1 &> /dev/null; then
        # If you would like to customize your colors, use
        # # example 1
        # for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; printf '%s\n' "=$c"; done
        # # example 2
        # for i in $(seq 0 $(tput colors)); do
        #   printf '%s\n' " $(tput setaf $i)Text$(tput sgr0) $(tput bold)$(tput setaf $i)Text$(tput sgr0) $(tput sgr 0 1)$(tput setaf $i)Text$(tput sgr0)  \$(tput setaf $i)"
        # done

        # Reset the shell from our `if` check
        tput sgr0 &> /dev/null
        # If the terminal supports at least 256 colors, write out our 256 color based set
        if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
            BLUE=$(tput setaf 27)
            CYAN=$(tput setaf 39)
            GREEN=$(tput setaf 76)
            GREY=$(tput setaf 250)
            LEMON=$(tput setaf 154)
            ORANGE=$(tput setaf 172)
            PURPLE=$(tput setaf 200)
            RED=$(tput setaf 9)
            YELLOW=$(tput setaf 226)
        else
            # Otherwise, use colors from our set of 8
            BLUE=$(tput setaf 4)
            CYAN=$(tput setaf 6)
            GREEN=$(tput setaf 2)
            GREY=$(tput setaf 7)
            LEMON=$(tput setaf 3)
            ORANGE=$(tput setaf 4)
            PURPLE=$(tput setaf 5)
            RED=$(tput setaf 1)
            YELLOW=$(tput setaf 3)
        fi
        BOLD=$(tput bold)
        RESET=$(tput sgr0)
    else
        # Otherwise, use ANSI escape sequences for coloring
        # If you would like to customize your colors, use
        # DEV: 30-39 lines up 0-9 from `tput`
        # for i in $(seq 0 109); do
        #   echo -n -e "\033[1;${i}mText$(tput sgr0) "
        #   echo "\033[1;${i}m"
        # done
        BLUE='\033[1;34m'
        CYAN='\033[1;36m'
        GREEN='\033[1;32m'
        GREY='\033[0;37m'
        LEMON='\033[1;33m'
        ORANGE='\033[1;33m'
        PURPLE='\033[1;35m'
        RED='\033[1;31m'
        WHITE='\033[1m'
        YELLOW='\033[1;33m'

        BOLD=''
        RESET='\033[m'
    fi

    # Define the default prompt terminator character '$'
    if [[ "$UID" == 0 ]]; then
        SYMBOL="#"
    else
        SYMBOL="\$"
    fi

    # export
    export BLUE
    export CYAN
    export GREEN
    export GREY
    export LEMON
    export ORANGE
    export PURPLE
    export RED
    export WHITE
    export YELLOW

    export BOLD
    export RESET
    export SYMBOL
}

# Xterm-colors
_xterm_fackground="xterm*background: black"
_xterm_foreground="xterm*foreground: lightgray"

if [[ ! -e "$HOME/.Xresources" && $EUID -ne 0 ]]; then
    printf '%s\n%s' "$_xterm_fackground" "$_xterm_foreground" | tee -a "$HOME/.Xresources" &> /dev/null
    xrdb "$HOME/.Xresources" &> /dev/null
else
    xrdb "$HOME/.Xresources" &> /dev/null
fi
