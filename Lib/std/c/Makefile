# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

OBJS = STDexecDTS.o
CFILES = STDexecDTS.c
HFILES = STDexecDTS.h
DEPS = $(HFILES) Makefile
CC = cc
LD = cc
CCFLAGS = -Wall -Wextra -Werror -O0 -c -g -ansi -pedantic
LDFLAGS = -Wall
LIBS =
EXEC = STDexecDTS

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS) $(LIBS)

STDexecDTS.o: STDexecDTS.c $(DEPS)
	$(CC) $(CCFLAGS) STDexecDTS.c

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)

.PHONY: edit
edit: tags
	$(EDITOR) $$(git ls-files)

tags: $(CFILES) $(HFILES)
	ctags $(CFILES) $(HFILES)

.PHONY: test
test:
