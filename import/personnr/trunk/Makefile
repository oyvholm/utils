
# Makefile for personnr.c
# $Id: Makefile,v 1.2 1999/04/25 03:30:53 sunny Exp $

CC = gcc
CFLAGS = -O2 -g -ansi -pedantic
EXEC = personnr

$(EXEC): personnr.c Makefile
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

clean:
	rm -f *~ $(EXEC) core core.$(EXEC)
