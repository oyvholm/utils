
# Makefile for personnr.c
# $Id: Makefile,v 1.2.2.3 2003/08/29 00:58:08 sunny Exp $

CC = gcc
CFLAGS = -O2 -g -ansi -pedantic -Wall
EXEC = personnr

$(EXEC): personnr.c Makefile
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

frac:
	$(CC) $(CFLAGS) -o $(EXEC) -DUSE_FRAC=1 personnr.c

nofrac:
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

clean:
	rm -fv *~ $(EXEC) core core.$(EXEC)
