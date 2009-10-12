#!/usr/bin/make

# tests/gpst-pic/Makefile
# File ID: 75946178-fafb-11dd-99e8-000475e441b9

all:
	./gpst-pic.t 2>&1 | remove_perltestnumbers >log/tests.log
	./gpst-pic.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	rm -vf gpst-pic-stderr.tmp
	svn revert log/tests.log log/todo-tests.log
