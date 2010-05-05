#!/bin/bash

#=======================================================================
# $Id$
# File ID: 58ea7322-fa61-11dd-bf7b-0001805bf4b1
#=======================================================================

if [ -e /nett2.mrk ]; then
    ls -artl --color=auto "$@"
elif [ -e $HOME/.n900.mrk ]; then
    ls -artl "$@"
else
    ls -artl --color=auto --time-style=+%F\ %T "$@"
fi
