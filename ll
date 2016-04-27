#!/bin/bash

#=======================================================================
# ll
# File ID: 58ea7322-fa61-11dd-bf7b-0001805bf4b1
#
# Frontend to ls(1), ordered by date.
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#=======================================================================

progname=ll
VERSION=0.1.0

ARGS="$(getopt -o "\
h\
q\
v\
" -l "\
help,\
quiet,\
verbose,\
version,\
" -n "$progname" -- "$@")"
test "$?" = "0" || exit 1
eval set -- "$ARGS"

opt_help=0
opt_quiet=0
opt_verbose=0
while :; do
    case "$1" in
        (-h|--help) opt_help=1; shift ;;
        (-q|--quiet) opt_quiet=$(($opt_quiet + 1)); shift ;;
        (-v|--verbose) opt_verbose=$(($opt_verbose + 1)); shift ;;
        (--version) echo $progname $VERSION; exit 0 ;;
        (--) shift; break ;;
        (*) echo $progname: Internal error >&2; exit 1 ;;
    esac
done
opt_verbose=$(($opt_verbose - $opt_quiet))

if test "$opt_help" = "1"; then
    test $opt_verbose -gt 0 && { echo; echo $progname $VERSION; }
    cat <<END

Frontend to ls(1), ordered by date.

Usage: $progname [options]

Options:

  -h, --help
    Show this help.
  -q, --quiet
    Be more quiet. Can be repeated to increase silence.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.

END
    exit 0
fi

ls -artl --color=auto --full-time "$@"
