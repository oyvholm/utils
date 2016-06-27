# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

OBJS = STDexecDTS.o
CFILES = STDexecDTS.c
HFILES = STDexecDTS.h version.h
DEPS = $(HFILES) Makefile
CC = gcc
LD = gcc
CCFLAGS = -Wall -Wextra -O2 -c -g -ansi -pedantic
LDFLAGS = -Wall
EXEC = STDexecDTS

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS)

STDexecDTS.o: STDexecDTS.c $(DEPS)
	$(CC) $(CCFLAGS) STDexecDTS.c

.PHONY: clean
clean:
	rm -fv $(EXEC) $(OBJS) *~ core core.$(EXEC) tags

.PHONY: edit
edit: tags
	$(EDITOR) *.c *.h Makefile

tags: $(CFILES) $(HFILES)
	ctags $(CFILES) $(HFILES)
