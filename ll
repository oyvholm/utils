#!/bin/bash

#=======================================================================
# $Id$
#=======================================================================

if [ -e /nett2.mrk ]; then
    ls -artl --color=auto "$@"
else
    ls -artl --color=auto --time-style=+%F\ %T "$@"
fi
