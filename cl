#!/bin/sh

# $Id$
# Latskap.

if [ -d .svn/. ]; then
	svn log -v $* | less
elif [ -d CVS/. ]; then
	cvs log $* | sortcvs | less
else
	svn log -v $* | less
fi
