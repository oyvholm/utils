#!/bin/bash

#=======================================================================
# $Id$
# Latskap. Lister ut loggen for Subversion, SVK eller CVS.
#
# Valg (Må spesifiseres alfabetisk):
#
# -k
#   Bruk svk istedenfor svn.
# -s
#   Bruk --stop-on-copy.
#=======================================================================

if [ "$1" = "-k" ]; then
    CMD_SVN=svk
    shift
else
    CMD_SVN=svn
fi

if [ "$1" = "-s" ]; then
    stoponcopy=' --stop-on-copy'
    shift
fi

if [ -d .svn/. ]; then
    $CMD_SVN log$stoponcopy -v $* | less
elif [ -d CVS/. ]; then
    cvs log$stoponcopy $* | sortcvs | less
else
    $CMD_SVN log$stoponcopy -v $* | less
fi
