#!/usr/bin/make

# $Id$

all:
	./fldb.t 2>&1 | remove_perltestnumbers >log/tests.log
	./fldb.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	rm -vf fldb-stderr.tmp
	svn revert log/tests.log log/todo-tests.log
