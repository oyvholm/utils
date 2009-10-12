#!/usr/bin/make

# tests/Makefile
# File ID: 323f7bca-f9f1-11dd-8b2b-000475e441b9

all:
	./fldb.t 2>&1 | remove_perltestnumbers >log/tests.log
	./fldb.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	rm -vf fldb-stderr.tmp
	svn revert log/tests.log log/todo-tests.log
