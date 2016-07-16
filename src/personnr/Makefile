# Makefile for personnr.c
# $Id: Makefile,v 1.3 2003/09/12 03:24:52 sunny Exp $
# Author: Øyvind A. Holm <sunny@sunbase.org>

CC = gcc
CFLAGS = -O2 -g -ansi -pedantic -Wall -Werror
EXEC = personnr

$(EXEC): personnr.c Makefile
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

.PHONY: clean
clean:
	rm -fv *~ $(EXEC) core core.$(EXEC)

.PHONY: test
test:
