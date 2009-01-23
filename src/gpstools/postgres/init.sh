#!/bin/bash

# $Id$

# createdb -T template_postgis gps
createdb gps
psql -d gps -c "CREATE LANGUAGE plpgsql;"
psql -d gps -f /usr/share/postgresql-8.3-postgis/lwpostgis.sql
psql -d gps -f /usr/share/postgresql-8.3-postgis/spatial_ref_sys.sql
psql -d gps -f init.sql
