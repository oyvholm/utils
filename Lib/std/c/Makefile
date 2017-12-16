# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

PREFIX = /usr/local

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

STDUexecUDTS-VERSION: Gen-version $(CFILES) $(DEPS)
	./Gen-version

STDexecDTS.o: STDUexecUDTS-VERSION STDexecDTS.c $(DEPS)
	$(CC) $(CCFLAGS) STDexecDTS.c \
	    -D$$(grep STDUexecUDTS_VERSION STDUexecUDTS-VERSION) \
	    -D$$(grep STDUexecUDTS_DATE STDUexecUDTS-VERSION)

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)
	rm -f STDUexecUDTS-VERSION

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
