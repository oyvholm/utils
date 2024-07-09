#!/bin/sh

#==============================================================================
# mc
# File ID: 6dbf2f84-f7c0-11e2-9a3f-001f3b596ec9
#
# Wrapper for Midnight Commander.
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#==============================================================================

progname=mc
VERSION=0.1.2

sess_str="sess -d mc -t c_mc --"
test "$1" = "--version" && unset sess_str
test "$HISTFILE" = "/dev/null" && unset sess_str

if test -x ~/local/bin/mc; then
	$sess_str ~/local/bin/mc -d "$@"
elif test -x /usr/src-other/bin/mc; then
	$sess_str /usr/src-other/bin/mc -d "$@"
elif test -x /usr/local/bin/mc; then
	$sess_str /usr/local/bin/mc -d "$@"
elif test -x /usr/bin/mc; then
	$sess_str /usr/bin/mc -d "$@"
elif test -x /data/data/com.termux/files/usr/bin/mc; then
	$sess_str /data/data/com.termux/files/usr/bin/mc -b -d "$@"
else
	echo mc is not installed here. >&2
	exit 1
fi

# vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 :
