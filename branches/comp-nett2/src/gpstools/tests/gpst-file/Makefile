#!/usr/bin/make

# $Id$
# File ID: ceae878a-009f-11de-a87e-000475e441b9

all:
	./gpst-file.t 2>&1 | remove_perltestnumbers >log/tests.log
	./gpst-file.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	rm -vf STDprognameDTS-stderr.tmp
	svn revert log/tests.log log/todo-tests.log
