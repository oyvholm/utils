#!/usr/bin/make

# $Id$
# File ID: 75946178-fafb-11dd-99e8-000475e441b9
# gpstools/tests/gpst-pic/Makefile

all:
	./gpst-pic.t 2>&1 | remove_perltestnumbers >log/tests.log
	./gpst-pic.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	svn revert log/tests.log log/todo-tests.log
