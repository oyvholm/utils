#!/bin/sh

# $Id: cl,v 1.2 2003/08/03 00:21:15 sunny Exp $
# Latskap.

if [ "$HAS_UTF8" = "1" ]; then
	cvs log $* | sortcvs
else
	cvs log $* | sortcvs | u2h -l
fi
