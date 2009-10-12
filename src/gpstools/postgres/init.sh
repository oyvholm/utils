#!/bin/bash

#=======================================================================
# postgres/init.sh
# File ID: 372e8e36-fafb-11dd-8930-000475e441b9
# License: GNU General Public License version 3 or later.
#=======================================================================

DBASE=gps
[ -z "$1" ] || { DBASE=$1; }
createdb $DBASE
psql -d $DBASE -c "CREATE LANGUAGE plpgsql;"
psql -d $DBASE -f init.sql
