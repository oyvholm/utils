#!/bin/bash

#=======================================================================
# File ID: 3623557a-fa66-11dd-83e3-000475e441b9
# Latskap.
#=======================================================================

test "$1" = "-s" && { slow=" -lavdopts fast:skiploopfilter=all"; shift; }
test -e /dg-vbox.mrk && vo_str=" -vo x11 -zoom"
mplayer -fs -osdlevel 3$slow$vo_str "$@"
