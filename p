#!/bin/bash

#=======================================================================
# File ID: 3623557a-fa66-11dd-83e3-000475e441b9
# Latskap.
#=======================================================================

test "$1" = "-s" && { slow=" -lavdopts fast:skiploopfilter=all"; shift; }
mplayer -fs -osdlevel 3$slow "$@"
