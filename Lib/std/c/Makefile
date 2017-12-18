# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

PREFIX = /usr/local

OBJS = STDexecDTS.o selftest.o
CFILES = STDexecDTS.c selftest.c
HFILES = STDexecDTS.h
DEPS = $(HFILES) Makefile
CC = cc
LD = cc
CCFLAGS = -Wall -Wextra -Werror -O0 -c -g -ansi -pedantic
CCFLAGS += $$(test -n "$(NDEBUG)" && echo -n "-DNDEBUG=1")
LDFLAGS = -Wall
LIBS =
EXEC = STDexecDTS

.PHONY: all
all: $(EXEC)

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS) $(LIBS)

version.h: Gen-version $(CFILES) $(DEPS)
	./Gen-version

STDexecDTS.o: version.h STDexecDTS.c $(DEPS)
	$(CC) $(CCFLAGS) STDexecDTS.c

selftest.o: selftest.c $(DEPS)
	$(CC) $(CCFLAGS) selftest.c

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)
	rm -f version.h
	cd t && $(MAKE) clean

.PHONY: edit
edit: tags
	$(EDITOR) $$(git ls-files)

.PHONY: gdb
gdb: $(EXEC)
	gdb -tui -x gdbrc $$(cat gdbopts 2>/dev/null) $(EXEC)

.PHONY: install
install: $(PREFIX)/bin/$(EXEC)

$(PREFIX)/bin/$(EXEC): $(EXEC)
	install $(EXEC) $(PREFIX)/bin/$(EXEC)

tags: $(CFILES) $(HFILES)
	ctags $(CFILES) $(HFILES)

.PHONY: test
test:
	cd t && $(MAKE) test

.PHONY: uninstall
uninstall:
	rm -f $(PREFIX)/bin/$(EXEC)

.PHONY: valgrind
valgrind:
	cd t && $(MAKE) valgrind
