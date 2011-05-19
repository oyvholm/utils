
# Makefile for std.c
# File ID: STDuuidDTS

OBJS = std.o
CC = gcc
LD = gcc
CCFLAGS = -Wall -O2 -c -g -ansi
LDFLAGS = -Wall
EXEC = std

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS)

std.o: std.c std.h version.h Makefile
	$(CC) $(CCFLAGS) std.c

clean:
	rm -f $(EXEC) $(OBJS) *~ core core.$(EXEC)
