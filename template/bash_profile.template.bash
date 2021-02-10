#!/bin/bash
# shellcheck source=/dev/null

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load Hyperterm
source "$HOME"/.hyperterm/hyperterm.sh
