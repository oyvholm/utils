#!/bin/bash

#=======================================================================
# File ID: 3623557a-fa66-11dd-83e3-000475e441b9
# Latskap.
#=======================================================================

ao_str=
pgrep jackd && ao_str=" -ao jack"
test "$1" = "-s" && { use_slow=1; shift; }
test "$use_slow" = "1" && slow=" -lavdopts fast:skiploopfilter=all"
test -e /dg-vbox.mrk && vo_str=" -vo x11 -zoom"
mplayer -fs -osdlevel 3$slow$vo_str$ao_str "$@"
