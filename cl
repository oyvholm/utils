#!/bin/sh

# $Id$
# Latskap.

if [ -d .svn/. ]; then
	svn log $* | less
else
	cvs log $* | sortcvs | less
fi
