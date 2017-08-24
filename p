#!/usr/bin/env bash

#=======================================================================
# p
# File ID: 3623557a-fa66-11dd-83e3-000475e441b9
#
# Play a media file in mpv
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#=======================================================================

progname=p
VERSION=0.4.1

ARGS="$(getopt -o "\
a:\
h\
q\
s\
t:\
v\
" -l "\
amplify:,\
help,\
quiet,\
slow,\
tempo:,\
verbose,\
version,\
" -n "$progname" -- "$@")"
test "$?" = "0" || exit 1
eval set -- "$ARGS"

opt_amplify=''
opt_help=0
opt_quiet=0
opt_slow=0
opt_tempo=''
opt_verbose=0
while :; do
    case "$1" in
        -a|--amplify) opt_amplify=$2; shift 2 ;;
        -h|--help) opt_help=1; shift ;;
        -q|--quiet) opt_quiet=$(($opt_quiet + 1)); shift ;;
        -s|--slow) opt_slow=1; shift ;;
        -t|--tempo) opt_tempo=$2; shift 2 ;;
        -v|--verbose) opt_verbose=$(($opt_verbose + 1)); shift ;;
        --version) echo $progname $VERSION; exit 0 ;;
        --) shift; break ;;
        *) echo $progname: Internal error >&2; exit 1 ;;
    esac
done
opt_verbose=$(($opt_verbose - $opt_quiet))

if test "$opt_help" = "1"; then
    test $opt_verbose -gt 0 && { echo; echo $progname $VERSION; }
    cat <<END

Play a media file in mpv.

Usage: $progname [options] file [files [...]]

Options:

  -a X, --amplify X
    Amplify sound with X dB. 10 is a nice value to start with.
  -h, --help
    Show this help.
  -q, --quiet
    Be more quiet. Can be repeated to increase silence.
  -s, --slow
    Use less resources when playing movie files.
  -t TEMPO, --tempo TEMPO
    Play audio with tempo TEMPO without changing the pitch.
    FIXME: Make it work with video too.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.

END
    exit 0
fi

sess_str="sess -d p -t c_p --"
test "$HISTFILE" = "/dev/null" && unset sess_str
ao_str=
amplify_str=
pgrep jackd && ao_str=" -ao jack"
if test -n "$opt_amplify"; then
    echo "$opt_amplify" | grep -q -E '^[0-9]+$' || {
        # Well, mplayer also understands floats, but it's easier to 
        # just check for [0-9].
        echo $progname: -a needs an integer argument >&2
        exit 1
    }
    amplify_str=" --af=volume=$opt_amplify:0"
fi
test "$opt_slow" = "1" && slow=" -lavdopts fast:skiploopfilter=all"
if test -n "$opt_tempo"; then
    tempo_str=" --af=scaletempo=scale=$opt_tempo"
else
    tempo_str=
fi
test -e /dg-vbox.mrk && vo_str=" -vo x11 -zoom"
$sess_str mpv -fs --no-audio-display \
  $tempo_str$slow$vo_str$ao_str$amplify_str "$@"
