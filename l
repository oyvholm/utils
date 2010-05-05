#!/bin/bash

#=======================================================================
# $Id$
# File ID: 4e69dc94-fa61-11dd-b10c-0001805bf4b1
#=======================================================================

if [ -e /nett2.mrk ]; then
    ls -la --color=auto "$@"
elif [ -e $HOME/.n900.mrk ]; then
    ls -la "$@"
else
    ls -la --color=auto --time-style=+%F\ %T "$@"
fi
