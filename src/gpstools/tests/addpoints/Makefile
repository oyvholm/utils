#!/usr/bin/make

# $Id$
# File ID: 72381b28-fafb-11dd-9a7e-000475e441b9

all:
	./addpoints.t 2>&1 | remove_perltestnumbers >log/tests.log
	./addpoints.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	svn revert log/tests.log log/todo-tests.log
