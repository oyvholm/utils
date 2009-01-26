#!/bin/bash

# $Id$

createdb gps
psql -d gps -c "CREATE LANGUAGE plpgsql;"
psql -d gps -f init.sql
