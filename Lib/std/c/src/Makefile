# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

CC = cc
EXEC = STDexecDTS
LD = cc
PREFIX = /usr/local

CFILES  =
CFILES += binbuf.c
CFILES += STDexecDTS.c
CFILES += io.c
CFILES += selftest.c
CFILES += strings.c
CFLAGS  =
CFLAGS += $$(test -n "$(GCOV)" && echo -n "-fprofile-arcs -ftest-coverage")
CFLAGS += $$(test -n "$(PROF)" && echo -n "-pg")
CFLAGS += -O0
CFLAGS += -Wall
CFLAGS += -Werror
CFLAGS += -Wextra
CFLAGS += -c
CFLAGS += -g
DEPS = version.h $(HFILES) Makefile
GNCOV_STR = $$(test -n "$(GNCOV)" && echo "-g")
HFILES  =
HFILES += STDexecDTS.h
HFILES += binbuf.h
HTMLFILE = $(EXEC).html
INSTALL_TARGETS  =
INSTALL_TARGETS += $(PREFIX)/bin/$(EXEC)
INSTALL_TARGETS += $(PREFIX)/share/man/man1/$(MANPAGE)
LDFLAGS  =
LDFLAGS += $$(test -n "$(PROF)" && echo -n "-pg")
LIBS  =
LIBS += $$(test -n "$(GCOV)" && echo "-lgcov --coverage")
MANPAGE = $(EXEC).1
MANSRC = $(MANPAGE).man
MAN_DATE = $$(grep EXEC_DATE version.h | cut -d '"' -f 2 | sed 's/-/\\\\-/g;')
OBJS  =
OBJS += STDexecDTS.o
OBJS += binbuf.o
OBJS += io.o
OBJS += selftest.o
OBJS += strings.o
PDFFILE = $(EXEC).pdf
TESTS = all

CMD_VALGRIND  = valgrind
CMD_VALGRIND += -q
CMD_VALGRIND += --leak-check=full
CMD_VALGRIND += --show-leak-kinds=all
CMD_VALGRIND += --
MAN_VERSION = $$(grep EXEC_VERSION version.h | cut -d '"' -f 2 \
                 | sed 's/-/\\\\-/g;')
TESTABLE_LINES = $$(grep -E '^ +\#\#\#\#\#:' *.c.gcov \
                    | grep -vF '/* gncov */' | wc -l)

.PHONY: all
all: $(EXEC) $(MANPAGE)

$(EXEC): $(OBJS)
	$(LD) -o $(EXEC) $(LDFLAGS) $(OBJS) $(LIBS)

$(HTMLFILE): $(MANPAGE)
	man -Thtml ./$(MANPAGE) >$@.tmp
	mv $@.tmp $@

$(MANPAGE): $(MANSRC) version.h
	sed "s/RPL_DATE/$(MAN_DATE)/g; s/RPL_VERSION/$(MAN_VERSION)/g;" \
	<$< >$@.tmp
	mv $@.tmp $@

$(PDFFILE): $(MANPAGE)
	man -Tpdf ./$(MANPAGE) >$@.tmp
	mv $@.tmp $@

version.h: Gen-version $(CFILES) $(HFILES) Makefile
	./Gen-version

binbuf.o: binbuf.c $(DEPS)
	$(CC) $(CFLAGS) binbuf.c

STDexecDTS.o: STDexecDTS.c $(DEPS)
	$(CC) $(CFLAGS) STDexecDTS.c

io.o: io.c $(DEPS)
	$(CC) $(CFLAGS) io.c

selftest.o: selftest.c $(DEPS)
	$(CC) $(CFLAGS) selftest.c

strings.o: strings.c $(DEPS)
	$(CC) $(CFLAGS) strings.c

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)
	rm -f $(HTMLFILE) $(HTMLFILE).tmp
	rm -f $(MANPAGE) $(MANPAGE).tmp
	rm -f $(PDFFILE) $(PDFFILE).tmp
	rm -f *.gcda *.gcno *.gcov
	rm -f gmon.out gmon.sum
	rm -f version.h

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

.PHONY: html
html: $(HTMLFILE)

.PHONY: install
install: $(INSTALL_TARGETS)

.PHONY: pdf
pdf: $(PDFFILE)

$(PREFIX)/bin/$(EXEC): $(EXEC)
	mkdir -p $(PREFIX)/bin
	install $(EXEC) $(PREFIX)/bin/$(EXEC)

$(PREFIX)/share/man/man1/$(MANPAGE): $(MANPAGE)
	mkdir -p $(PREFIX)/share/man/man1
	install $(MANPAGE) $(PREFIX)/share/man/man1/$(MANPAGE)

tags: $(CFILES) $(HFILES)
	ctags $(CFILES) $(HFILES)

.PHONY: test
test: $(EXEC)
	./$(EXEC) --selftest $(TESTS)

.PHONY: testall
testall:
	$(MAKE) testcomb WHAT=test

.PHONY: testcomb
testcomb:
	$(MAKE) clean $(WHAT) NDEBUG=1
	$(MAKE) clean $(WHAT) UNUSED=1
	$(MAKE) clean $(WHAT) NDEBUG=1 UNUSED=1
	$(MAKE) clean $(WHAT)

.PHONY: testsrc
testsrc:
	@echo Check files for long lines >&2
	@for f in $(CFILES) $(HFILES) $(MANSRC) Gen-version Makefile; do \
		[ -f "$$f" ] && expand "$$f" | sed 's/ $$//;' \
		| grep -q -E '.{80}' && echo "$$f"; \
	done | grep . && exit 1 || true

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
	[ -e $(EXEC) ] || echo FAIL; \
	rm .make-tlok.tmp

.PHONY: tlokall
tlokall:
	@echo -n   "tlok TESTS=all       : "
	@$(MAKE) -s tlok TESTS=all
	@echo -n   "tlok TESTS=func      : "
	@$(MAKE) -s tlok TESTS=func
	@echo -n   "tlok TESTS=exec      : "
	@$(MAKE) -s tlok TESTS=exec
	@echo -n   "tlok TESTS=func,exec : "
	@$(MAKE) -s tlok TESTS=func,exec
	@echo -n   "tlok TESTS=none      : "
	@$(MAKE) -s tlok TESTS=none

.PHONY: uninstall
uninstall:
	rm -f $(INSTALL_TARGETS)

.PHONY: valgrind
valgrind: $(EXEC)
	./$(EXEC) --valgrind $(TESTS)
	$(CMD_VALGRIND) ./$(EXEC) --selftest $(TESTS) | grep -v ^ok

.PHONY: valgrindall
valgrindall:
	$(MAKE) testcomb WHAT=valgrind
