
OBJS = std.o getopt.o
CC = gcc
LD = gcc
CCFLAGS = -Wall -O2 -c -g -ansi -pedantic
LDFLAGS = -Wall
EXEC = std

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS)

std.o: std.c std.h getopt.h Makefile
	$(CC) $(CCFLAGS) std.c

getopt.o: getopt.h Makefile
	$(CC) $(CCFLAGS) getopt.c

clean:
	rm -f $(EXEC) $(OBJS) core *~
