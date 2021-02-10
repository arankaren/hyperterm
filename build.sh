#!/bin/bash

if [[ -n "$(ls -a ./hyperterm/)" && -f ./.bash_profile ]];
then
    cd ./hyperterm/ || exit

    var1=$(find ../ -name ".bash*" -type f -exec sha512sum {} \;)
    var2=$(find . -type f -name "*.sh" ! -iname "_custom.sh" -exec sha512sum {} \;)

    alist="echo $var1 $var2"
    $alist > tmp.txt

    output="fmt -w 160 tmp.txt"

    $output > hyperterm.sha512

    rm -rf tmp.txt

    sha512sum -c hyperterm.sha512

    printf '\e[1;36m%s\e[m\n' "success hyperterm.sha512"
else
    printf '\e[1;31m%s\e[m\n' "Error! files not found for verification"
fi
