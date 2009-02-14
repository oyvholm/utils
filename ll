#!/bin/bash

#=======================================================================
# $Id$
# File ID: 58ea7322-fa61-11dd-bf7b-0001805bf4b1
#=======================================================================

suuid -t c_ll -c "ll $*"
if [ -e /nett2.mrk ]; then
    ls -artl --color=auto "$@"
else
    ls -artl --color=auto --time-style=+%F\ %T "$@"
fi
