#!/usr/bin/make

# $Id$
# File ID: 676b0476-fafb-11dd-925c-000475e441b9

all:
	./run-tests.pl 2>&1 | remove_perltestnumbers >log/tests.log
	./run-tests.pl --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log
	cd gpst-pic && make
	cd addpoints && make

clean:
	rm -vf gpst-stderr.tmp
	svn revert log/tests.log log/todo-tests.log
	cd addpoints && make clean
	cd gpst-pic && make clean
