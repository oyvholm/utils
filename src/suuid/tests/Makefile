#!/usr/bin/make

# tests/Makefile
# File ID: 4906ed12-fb76-11dd-b5ce-000475e441b9

all:
	mkdir -p log
	./suuid.t 2>&1 | remove_perltestnumbers >log/tests.log
	./suuid.t --todo 2>&1 | remove_perltestnumbers >log/todo-tests.log
	./sess.t 2>&1 | remove_perltestnumbers >log/sess.log
	./sess.t --todo 2>&1 | remove_perltestnumbers >log/sess.todo.log

clean:
	rm -rf log
