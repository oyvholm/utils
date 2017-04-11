#!/bin/sh

#==============================================================================
# cts
# File ID: de561b1e-1d18-11e7-9fd8-db5caa6d21d3
#
# Create and start a new task in Taskwarrior.
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#==============================================================================

progname=cts
VERSION=0.1.0

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

Create and start a new task in Taskwarrior.

Usage: $progname [options] DESCRIPTION

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

if test -z "$1"; then
	echo $progname: No description provided >&2
	exit 1
fi

tmpfile="/tmp/cts.$(date +%s.$$).tmp"

t add "$*" | tee "$tmpfile"
eid=$(
	grep ^Created "$tmpfile" | \
	perl -pe 's/^Created task (\d+).*$/$1/;'
)
if test -z "$eid"; then
	echo $progname: Could not get entry ID value >&2
	echo $progname: Leaving tmpfile as $tmpfile >&2
	exit 1
fi
t start $eid
t active
rm "$tmpfile"

# vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 :
