#!/bin/bash
# Author: Romain Ouabdelkader

if [ $# -eq 1 ]
then
    path="$1"
else
    path="."
fi

while [[ "`readlink -f $path`" != "/" ]]
do
    res=$(find "$path" -maxdepth 1 -mindepth 1 -name ".emacsproject" -type d)
    if [ "$res" != "" ]
    then
	echo "`readlink -f \"$res/..\"`"
	exit
    fi
    path="$path/.."
done
