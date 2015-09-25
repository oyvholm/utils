#!/bin/bash

#=======================================================================
# p
# File ID: 3623557a-fa66-11dd-83e3-000475e441b9
#
# Play a media file in mplayer
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#=======================================================================

progname=p
VERSION=0.1.0

if test "$1" = "--version"; then
    echo $progname $VERSION
    exit 0
fi

if test "$1" = "-h" -o "$1" = "--help"; then
    cat <<END

Play a media file in mplayer.

Usage: $progname [options] file [files [...]]

Options:

  -h, --help
    Show this help.
  -s
    Use less resources when playing movie files.
  --version
    Print version information.

END
    exit 0
fi

sess_str="sess -d p -t c_p --"
test "$HISTFILE" = "/dev/null" && unset sess_str
ao_str=
pgrep jackd && ao_str=" -ao jack"
test "$1" = "-s" && { use_slow=1; shift; }
test "$use_slow" = "1" && slow=" -lavdopts fast:skiploopfilter=all"
test -e /dg-vbox.mrk && vo_str=" -vo x11 -zoom"
$sess_str mplayer -fs -osdlevel 3$slow$vo_str$ao_str "$@"
