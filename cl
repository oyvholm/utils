#!/bin/sh

# $Id$
# Latskap.

if [ -d .svn/. ]; then
	svn log -v $* | less
else
	cvs log $* | sortcvs | less
fi
