#!/bin/bash

# $Id$
# File ID: 372e8e36-fafb-11dd-8930-000475e441b9

createdb gps
psql -d gps -c "CREATE LANGUAGE plpgsql;"
psql -d gps -f init.sql
