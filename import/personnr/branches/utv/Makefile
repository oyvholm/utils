
# Makefile for personnr.c
# $Id: Makefile,v 1.2.2.4 2003/09/12 03:20:00 sunny Exp $

CC = gcc
CFLAGS = -O2 -g -ansi -pedantic -Wall
EXEC = personnr

$(EXEC): personnr.c Makefile
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

clean:
	rm -fv *~ $(EXEC) core core.$(EXEC)
