# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

PREFIX = /usr/local

EXEC = STDexecDTS

CC = cc
LD = cc

CCFLAGS  =
CCFLAGS += $$(test -n "$(GCOV)" && echo -n "-fprofile-arcs -ftest-coverage")
CCFLAGS += -Wall -Wextra -Werror -O0 -c -g

LDFLAGS  =
LDFLAGS += -Wall -Wextra -Werror

LIBS  =
LIBS += $$(test -n "$(GCOV)" && echo "-lgcov --coverage")

OBJS  =
OBJS += STDexecDTS.o
OBJS += selftest.o

CFILES  =
CFILES += STDexecDTS.c
CFILES += selftest.c

HFILES  =
HFILES += STDexecDTS.h

DEPS = version.h $(HFILES) Makefile
GNCOV_STR = $$(test -n "$(GNCOV)" && echo "-g")
TESTABLE_LINES = $$(grep -E '^ +\#\#\#\#\#:' *.c.gcov \
                    | grep -vF '/* gncov */' | wc -l)

.PHONY: all
all: $(EXEC)

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS) $(LIBS)

version.h: Gen-version $(CFILES) $(HFILES) Makefile
	./Gen-version

STDexecDTS.o: STDexecDTS.c $(DEPS)
	$(CC) $(CCFLAGS) STDexecDTS.c

selftest.o: selftest.c $(DEPS)
	$(CC) $(CCFLAGS) selftest.c

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)
	rm -f *.gcda *.gcno *.gcov
	rm -f version.h
	cd t && $(MAKE) clean

.PHONY: edit
edit: tags
	$(EDITOR) $$(git ls-files)
	rm tags

.PHONY: gcov
gcov:
	$(MAKE) clean test GCOV=1
	gcov $(CFILES)
	@echo $$(grep -E '^ +#####:' *.c.gcov | wc -l) untested lines >&2
	@echo $$(grep -E '^ +#####:' *.c.gcov | grep -F '/* gncov */' \
	         | wc -l) gncov lines >&2
	@echo $(TESTABLE_LINES) testable lines >&2

.PHONY: gcov-cmt
gcov-cmt: gcov
	gcov-cmt $(GNCOV_STR) $(CFILES)

.PHONY: gcov-cmt-clean
gcov-cmt-clean:
	gcov-cmt -d $(CFILES)

.PHONY: gdb
gdb: $(EXEC)
	gdb -x gdbrc $$(cat gdbopts 2>/dev/null) $(EXEC)

.PHONY: install
install: $(PREFIX)/bin/$(EXEC)

$(PREFIX)/bin/$(EXEC): $(EXEC)
	mkdir -p $(PREFIX)/bin
	install $(EXEC) $(PREFIX)/bin/$(EXEC)

tags: $(CFILES) $(HFILES)
	ctags $(CFILES) $(HFILES)

.PHONY: test
test: $(EXEC)
	cd t && $(MAKE) test

.PHONY: testall
testall:
	$(MAKE) testcomb WHAT=test

.PHONY: testcomb
testcomb:
	$(MAKE) clean $(WHAT) NDEBUG=1
	$(MAKE) clean $(WHAT) GCOV=1
	$(MAKE) clean $(WHAT) GCOV=1 NDEBUG=1
	$(MAKE) clean $(WHAT)

.PHONY: tlok
tlok:
	@$(MAKE) -s gcov 2>.make-tlok.tmp >&2; res=$$?; \
	if test $$res -eq 0; then \
		printf '%u:%u\n' \
		       "$(TESTABLE_LINES)" \
		       "$$(grep ^1\\.\\. .make-tlok.tmp \
		           | perl -pe 's/^1\.\.(\d+).*/$$1/;')"; \
	else \
		grep "Looks like you failed" <.make-tlok.tmp \
		| perl -p \
		  -e  's/.*failed (\d+) tests? of (\d+).*/$$1\/$$2 FAIL/;'; \
	fi; \
	rm .make-tlok.tmp

.PHONY: uninstall
uninstall:
	rm -f $(PREFIX)/bin/$(EXEC)

.PHONY: valgrind
valgrind:
	cd t && $(MAKE) valgrind

.PHONY: valgrindall
valgrindall:
	$(MAKE) testcomb WHAT=valgrind
