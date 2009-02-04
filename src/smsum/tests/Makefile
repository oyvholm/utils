#!/usr/bin/make

# $Id$

all:
	./smsum.t 2>&1 | remove_perltestnumbers >log/tests.log
	./smsum.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	svn revert log/tests.log log/todo-tests.log
