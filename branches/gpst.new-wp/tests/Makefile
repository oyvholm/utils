#!/usr/bin/make

# $Id$
# gpstools/tests/Makefile

all:
	./run-tests.pl 2>&1 | remove_perltestnumbers >log/tests.log
	./run-tests.pl --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log
	cd gpst-pic && make
	cd addpoints && make
