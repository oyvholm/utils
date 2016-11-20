#!/bin/sh

#==============================================================================
# l
# File ID: 4e69dc94-fa61-11dd-b10c-0001805bf4b1
#
# Front-end to ls(1).
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#==============================================================================

progname=l
VERSION=0.5.0

opt_help=0
opt_quiet=0
opt_verbose=0
while test -n "$1"; do
	case "$1" in
	-h|--help) opt_help=1; shift ;;
	-q|--quiet) opt_quiet=$(($opt_quiet + 1)); shift ;;
	-v|--verbose) opt_verbose=$(($opt_verbose + 1)); shift ;;
	--version) echo $progname $VERSION; exit 0 ;;
	--) shift; break ;;
	*)
		if printf '%s\n' "$1" | grep -q ^-; then
			echo "$progname: $1: Unknown option" >&2
			exit 1
		else
			break
		fi
	break ;;
	esac
done
opt_verbose=$(($opt_verbose - $opt_quiet))

if test "$opt_help" = "1"; then
	test $opt_verbose -gt 0 && { echo; echo $progname $VERSION; }
	cat <<END

Front-end to ls(1).

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

osname="$(uname)"

if test "$osname" = "Linux"; then
	ls -la --color=always --full-time "$@" | $PAGER
else
	ls -la "$@" | $PAGER
fi

# vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 :
