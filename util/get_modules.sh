#!/bin/bash

function get_module() {
    directory=$1
    additional_path=$2
    if [ -e "$directory/init.el" ]
    then
	echo "$directory/$additional_path"
	return
    fi

    directories=$(find "$directory" -maxdepth 1 -mindepth 1 -type d)
    for dir in $directories
    do
	get_module "$dir" "$additional_path"
    done
}

additional_path=$1
module_base=$(find src -maxdepth 1 -mindepth 1 -type d)
for dir in $module_base
do
    get_module "$dir" "$additional_path"
done
