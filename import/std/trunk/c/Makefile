
# Makefile for std.c
# $Id: Makefile,v 1.4 1999/04/26 09:28:50 sunny Exp $

OBJS = std.o getopt.o
CC = gcc
LD = gcc
CCFLAGS = -Wall -Wno-unused -O2 -c -g -ansi -pedantic
LDFLAGS = -Wall
EXEC = std

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS)

std.o: std.c std.h getopt.h Makefile
	$(CC) $(CCFLAGS) std.c

getopt.o: getopt.h Makefile tailor.h
	$(CC) $(CCFLAGS) getopt.c

clean:
	rm -f $(EXEC) $(OBJS) *~ core core.$(EXEC)
