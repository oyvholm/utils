
# Makefile for personnr.c
# $Id: Makefile,v 1.2.2.2 2003/08/23 22:10:17 sunny Exp $

CC = gcc
CFLAGS = -O2 -g -ansi -pedantic -Wall
EXEC = personnr

$(EXEC): personnr.c Makefile
	$(CC) $(CFLAGS) -o $(EXEC) personnr.c

clean:
	rm -fv *~ $(EXEC) core core.$(EXEC)
