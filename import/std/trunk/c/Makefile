
# Makefile for std.c
# $Id: Makefile,v 1.5 1999/05/04 11:50:15 sunny Exp $

OBJS = std.o getopt.o
CC = gcc
LD = gcc
CCFLAGS = -Wall -O2 -c -g -ansi -pedantic -Wno-unused
LDFLAGS = -Wall
EXEC = std

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS)

std.o: std.c std.h getopt.h Makefile
	$(CC) $(CCFLAGS) std.c

getopt.o: getopt.c getopt.h tailor.h Makefile
	$(CC) $(CCFLAGS) getopt.c

clean:
	rm -f $(EXEC) $(OBJS) *~ core core.$(EXEC)
