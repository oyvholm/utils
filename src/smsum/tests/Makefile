#!/usr/bin/make

# tests/Makefile
# File ID: af30306a-f943-11dd-b22a-0001805bf4b1

all:
	mkdir -p log
	./smsum.t 2>&1 | remove_perltestnumbers >log/tests.log
	./smsum.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log

clean:
	rm -vf smsum-stderr.tmp
	svn revert log/tests.log log/todo-tests.log
