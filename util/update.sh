#!/bin/bash

git fetch

if [ `git rev-list HEAD...origin/master --count` != 0 ]
then
    git pull && ./install && echo 'Please restart emacs to apply changes'
else
    echo 'Already up to date'
fi
