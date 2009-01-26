#!/usr/bin/make

# $Id$

all:
	./addpoints.t 2>&1 | remove_perltestnumbers >log/tests.log
	./addpoints.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	svn revert log/tests.log log/todo-tests.log
