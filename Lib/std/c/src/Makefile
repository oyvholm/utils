# Makefile for STDexecDTS.c
# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

CC = cc
EXEC = STDexecDTS
LD = cc
PREFIX = /usr/local

CFILES  =
CFILES += STDexecDTS.c
CFILES += binbuf.c
CFILES += io.c
CFILES += selftest.c
CFILES += strings.c
CFLAGS  =
CFLAGS += $$($(IS_DEV) && echo -O0 || echo -O2)
CFLAGS += $$(test -n "$(GCOV)" && echo -n "-fprofile-arcs -ftest-coverage")
CFLAGS += $$(test -n "$(PROF)" && echo -n "-pg")
CFLAGS += $(DEVFLAGS_STR)
CFLAGS += -Wall
CFLAGS += -c
DEPS = version.h $(HFILES) Makefile
DEVEL =
DEVFLAGS  =
DEVFLAGS += $$(test "$$(uname -o)" = "Android" || echo -fcf-protection=full)
DEVFLAGS += -Wbad-function-cast
DEVFLAGS += -Wcast-align
DEVFLAGS += -Wcast-qual
DEVFLAGS += -Wchar-subscripts
DEVFLAGS += -Wconversion
DEVFLAGS += -Wdangling-else
DEVFLAGS += -Wdate-time
DEVFLAGS += -Wdouble-promotion
DEVFLAGS += -Werror
DEVFLAGS += -Werror=implicit-function-declaration
DEVFLAGS += -Wextra
DEVFLAGS += -Wfloat-conversion
DEVFLAGS += -Wformat
DEVFLAGS += -Wformat-overflow
DEVFLAGS += -Wformat-security
DEVFLAGS += -Wformat-signedness
DEVFLAGS += -Wformat-truncation
DEVFLAGS += -Wformat-y2k
DEVFLAGS += -Winit-self
DEVFLAGS += -Wint-in-bool-context
DEVFLAGS += -Wlogical-not-parentheses
DEVFLAGS += -Wmisleading-indentation
DEVFLAGS += -Wmissing-braces
DEVFLAGS += -Wold-style-definition
DEVFLAGS += -Woverlength-strings
DEVFLAGS += -Wpedantic
DEVFLAGS += -Wredundant-decls
DEVFLAGS += -Wshadow
DEVFLAGS += -Wstrict-aliasing
DEVFLAGS += -Wstrict-overflow=5
DEVFLAGS += -Wstrict-prototypes
DEVFLAGS += -Wuninitialized
DEVFLAGS += -Wunused-const-variable
DEVFLAGS += -Wunused-function
DEVFLAGS += -fno-common
DEVFLAGS += -fstack-protector-strong
DEVFLAGS += -fwrapv
DEVFLAGS += -g3
DEVFLAGS += -pedantic
DEVFLAGS_STR = $$($(IS_DEV) && echo $(DEVFLAGS))
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
LONGLINES_FILES  =
LONGLINES_FILES += $$(echo $(CFILES) | fmt -1 | grep -vF selftest.c)
LONGLINES_FILES += $(HFILES)
LONGLINES_FILES += $(MANSRC)
LONGLINES_FILES += Gen-version
LONGLINES_FILES += Makefile
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

#  Not in Clang
# DEVFLAGS += -Wc99-c11-compat
# DEVFLAGS += -Wduplicated-branches
# DEVFLAGS += -Wformat-overflow=2
# DEVFLAGS += -Wjump-misses-init
# DEVFLAGS += -Wlogical-op
# DEVFLAGS += -Wmaybe-uninitialized

#  Don't use yet
# DEVFLAGS += -Waggregate-return
# DEVFLAGS += -Wformat=2
# DEVFLAGS += -Wmissing-declarations
# DEVFLAGS += -Wpadded

CMD_VALGRIND  = valgrind
CMD_VALGRIND += -q
CMD_VALGRIND += --error-exitcode=1
CMD_VALGRIND += --leak-check=full
CMD_VALGRIND += --show-leak-kinds=all
CMD_VALGRIND += --
IS_DEV = [ -z "$(NODEVEL)" \
           -a \( -e .devel -o -e ../.git/.devel -o -n "$(DEVEL)" \) ]
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
	<$(MANSRC) >$@.tmp
	mv $@.tmp $@

$(PDFFILE): $(MANPAGE)
	man -Tpdf ./$(MANPAGE) >$@.tmp
	mv $@.tmp $@

$(PREFIX)/bin/$(EXEC): $(EXEC)
	mkdir -p $(PREFIX)/bin
	install $(EXEC) $(PREFIX)/bin/$(EXEC)

$(PREFIX)/share/man/man1/$(MANPAGE): $(MANPAGE)
	mkdir -p $(PREFIX)/share/man/man1
	install $(MANPAGE) $(PREFIX)/share/man/man1/$(MANPAGE)

version.h: Gen-version $(CFILES) $(HFILES) Makefile
	./Gen-version

STDexecDTS.o: STDexecDTS.c $(DEPS)
	$(CC) $(CFLAGS) STDexecDTS.c

binbuf.o: binbuf.c $(DEPS)
	$(CC) $(CFLAGS) binbuf.c

io.o: io.c $(DEPS)
	$(CC) $(CFLAGS) io.c

selftest.o: selftest.c $(DEPS)
	$(CC) $(CFLAGS) selftest.c

strings.o: strings.c $(DEPS)
	$(CC) $(CFLAGS) strings.c

tags: $(CFILES) $(HFILES)
	ctags $(CFILES) $(HFILES)

.PHONY: asm
asm: $(DEPS)
	$(CC) $(CFLAGS) -fverbose-asm -S $(CFILES)

.PHONY: cflags
cflags:
	@echo $(CFLAGS)

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)
	rm -f $(HTMLFILE) $(HTMLFILE).tmp
	rm -f $(MANPAGE) $(MANPAGE).tmp
	rm -f $(PDFFILE) $(PDFFILE).tmp
	rm -f *.gcda *.gcno *.gcov
	rm -f *.s
	rm -f gmon.out gmon.sum
	rm -f version.h

.PHONY: dupdesc
dupdesc:
	@$(MAKE) -s clean all \
	&& ./$(EXEC) --selftest 2>/dev/null | cut -f 4- -d ' ' | sort \
	   | uniq -c | sed 's/^[[:space:]]*//g;' | grep -v '^1 ' \
	   | grep . && exit 1 || true

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

.PHONY: longlines
longlines:
	@for f in $(LONGLINES_FILES); do \
		if [ -f "$$f" ]; then \
			d="$$(expand "$$f" | sed 's/ $$//;' \
			  | grep -E -n '.{80}')"; \
			echo "$$d" | grep -q . \
			&& (echo "$$f"; echo "$$d"; echo " "); \
		fi; \
	done | grep . && exit 1 || true

.PHONY: pdf
pdf: $(PDFFILE)

.PHONY: test
test: $(EXEC)
	./$(EXEC) --selftest $(TESTS)

.PHONY: testall
testall:
	$(MAKE) -s testcomb WHAT=test
	$(MAKE) -s testsrc

.PHONY: testcomb
testcomb:
	$(MAKE) clean $(WHAT) NDEBUG=1
	$(MAKE) clean $(WHAT)

.PHONY: testsrc
testsrc:
	@echo Check files for long lines
	@$(MAKE) -s longlines
	@echo Check for duplicated test descriptions
	@$(MAKE) -s dupdesc

.PHONY: tlok
tlok:
	@$(MAKE) -s gcov DEVEL=1 2>.make-tlok.tmp >&2; res=$$?; \
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
	$(CMD_VALGRIND) ./$(EXEC) --selftest $(TESTS)

.PHONY: valgrindall
valgrindall:
	$(MAKE) testcomb WHAT=valgrind
