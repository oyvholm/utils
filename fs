#!/bin/bash

#==============================================================================
# fs
# File ID: 23287f94-a5c7-11e6-a6d5-d3c84ac7b384
#
# [Description]
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#==============================================================================

progname=fs
VERSION=0.1.0

if test "$1" = "--version"; then
	echo $progname $VERSION
	exit 0
fi

if test "$1" = "-h"; then
	cat <<END

Usage: $progname [options]

Options:

  -h
    Show this help.
  --version
    Print version information.

END
	exit 0
fi

fossil "$@"

# vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 :
