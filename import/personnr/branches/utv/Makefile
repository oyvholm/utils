
# Makefile for personnr.c
# $Id: Makefile,v 1.2.2.1 2003/05/24 04:27:28 sunny Exp $

CC = gcc
CFLAGS = -O2 -g -ansi -pedantic -DNO_FRAC=1
EXEC = personnr

$(EXEC): personnr.c Makefile
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

clean:
	rm -f *~ $(EXEC) core core.$(EXEC)
