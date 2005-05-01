#!/bin/bash

#=======================================================================
# $Id$
# Latskap. Lister ut loggen for Subversion eller CVS. Hvis "-s" 
# spesifiseres som første parameter, er det det samme som 
# --stop-on-copy.
#=======================================================================

if [ "$1" = "-s" ]; then
    stoponcopy=' --stop-on-copy'
    shift
fi

if [ -d .svn/. ]; then
    svn log$stoponcopy -v $* | less
elif [ -d CVS/. ]; then
    cvs log$stoponcopy $* | sortcvs | less
else
    svn log$stoponcopy -v $* | less
fi
