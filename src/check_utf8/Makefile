#!/usr/bin/make

# $Id$

CC = gcc
EXEC = check_utf8

check_utf8: check_utf8.c
	$(CC) -Wall -o $(EXEC) -O2 check_utf8.c

clean:
	rm -fv core $(EXEC)
