
# Makefile for std.c
# $Id: Makefile,v 1.2 1999/04/25 23:30:17 sunny Exp $

OBJS = std.o getopt.o
CC = gcc
LD = gcc
CCFLAGS = -Wall -no-unused -O2 -c -g -ansi -pedantic
LDFLAGS = -Wall
EXEC = std

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS)

std.o: std.c std.h getopt.h Makefile
	$(CC) $(CCFLAGS) std.c

getopt.o: getopt.h Makefile
	$(CC) $(CCFLAGS) getopt.c

clean:
	rm -f $(EXEC) $(OBJS) core core.$(EXEC) *~
