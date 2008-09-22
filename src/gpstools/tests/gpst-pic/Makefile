#!/usr/bin/make

# $Id$
# gpstools/tests/gpst-pic/Makefile

all:
	./gpst-pic.t 2>&1 | remove_perltestnumbers >log/tests.log
	./gpst-pic.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log
