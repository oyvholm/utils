
# Makefile for STDexecDTS.c
# File ID: STDuuidDTS

OBJS = STDexecDTS.o
CC = gcc
LD = gcc
CCFLAGS = -Wall -O2 -c -g -ansi
LDFLAGS = -Wall
EXEC = STDexecDTS

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS)

STDexecDTS.o: STDexecDTS.c STDexecDTS.h version.h Makefile
	$(CC) $(CCFLAGS) STDexecDTS.c

clean:
	rm -f $(EXEC) $(OBJS) *~ core core.$(EXEC)
