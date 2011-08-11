#!/bin/bash

#=======================================================================
# File ID: 3623557a-fa66-11dd-83e3-000475e441b9
# Latskap.
#=======================================================================

if [ "$1" = "-s" ]; then
    slow=" -lavdopts fast:skiploopfilter=all"
    shift
else
    unset slow
fi

mplayer -fs -osdlevel 3$slow "$@"
