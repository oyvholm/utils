#!/bin/bash

#=======================================================================
# $Id$
# File ID: 372e8e36-fafb-11dd-8930-000475e441b9
#=======================================================================

DBASE=gps
[ -z "$1" ] || { DBASE=$1; }
createdb $DBASE
psql -d $DBASE -c "CREATE LANGUAGE plpgsql;"
psql -d $DBASE -f init.sql
