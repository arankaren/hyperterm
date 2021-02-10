#!/bin/bash

alias clean='cat /dev/null > "$HOME/.bash_history" && history -c'
alias df='df -h'                          # human-readable sizes
alias ep='emacs PKGBUILD'
alias free='free -hm'                     # show sizes in humans format
alias grep='grep --color=tty -d skip'
alias la='ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias np='nano PKGBUILD'
alias pastebin='curl -X POST https://bpa.st/curl -F "raw=<-"'
