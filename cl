#!/bin/sh

# $Id: cl,v 1.3 2003/08/11 16:15:55 sunny Exp $
# Latskap.

cvs log $* | sortcvs | gvim -
