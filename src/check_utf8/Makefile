#!/usr/bin/make

# $Id: Makefile,v 1.1 2003/08/02 19:36:58 sunny Exp $

CC = gcc
EXEC = check_utf8

check_utf8: check_utf8.c
	$(CC) -Wall -o $(EXEC) -O2 check_utf8.c

clean:
	rm -fv core $(EXEC)
