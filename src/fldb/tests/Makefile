#!/usr/bin/make

# $Id$

all:
	./fldb.t 2>&1 | remove_perltestnumbers >log/tests.log
	./fldb.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log
