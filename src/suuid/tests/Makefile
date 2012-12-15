#!/usr/bin/make

# tests/Makefile
# File ID: 4906ed12-fb76-11dd-b5ce-000475e441b9

all:
	./suuid.t | grep -v '^ok '
	./sess.t | grep -v '^ok '

clean:
	rm -rf log
