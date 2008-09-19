#!/usr/bin/make

# $Id$
# gpstools/tests/Makefile

all:
	./run-tests.pl 2>&1 | ./unify.pl >log/tests.log
	./run-tests.pl --todo 2>&1 | ./unify.pl >log/todo-tests.log
	cd gpst-pic && make
