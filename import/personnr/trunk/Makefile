
# Makefile for personnr.c
# $Id: Makefile,v 1.3 2003/09/12 03:24:52 sunny Exp $

CC = gcc
CFLAGS = -O2 -g -ansi -pedantic -Wall
EXEC = personnr

$(EXEC): personnr.c Makefile
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

clean:
	rm -fv *~ $(EXEC) core core.$(EXEC)
