#!/bin/bash

if [ -x /usr/bin/ruby ]; then
    # Variable de Entorno para Sass
    # Sass
    _ruby="$(ruby -r rubygems -e "puts Gem.user_dir")/bin"
    if [ -s "$_ruby" ]; then
        export PATH+=:$_ruby
    fi
fi
