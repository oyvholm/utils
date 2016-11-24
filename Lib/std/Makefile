# Lib/std/Makefile
# File ID: 6454cafe-4b04-11e6-8c85-02010e0a6634
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: default
default:

.PHONY: clean
clean:
	cd book-cmark && $(MAKE) clean
	cd c && $(MAKE) clean
	cd c && rm -f STDexecDTS.c STDexecDTS.h
	cd c && rm -fr t compile.tmp
	cd ly && $(MAKE) clean && rm -f STDprojnameDTS.ly STDprojnameDTS.midi

.PHONY: test
test: test-c test-sh
	cd book-cmark && $(MAKE) test
	cd ly && ./test-ly-files

.PHONY: test-c
test-c:
	ln -sf std.h c/STDexecDTS.h
	ln -sf std.c c/STDexecDTS.c
	cd c && $(MAKE) clean
	cd c && $(MAKE)
	cd c && ./STDexecDTS
	mkdir -p c/t
	rm -f c/t/STDexecDTS.t
	cd c/t && \
	    std --dbname none perl-tests STDexecDTS.t -t progname=STDexecDTS
	cd c/t && ./STDexecDTS.t
	rm -rf c/compile.tmp
	mkdir -p c/compile.tmp/uuids
	cd c/compile.tmp && \
	    SUUID_LOGDIR=uuids std -d ./synced.sqlite \
	      -t exec=jada c/std.c jada.c
	cd c/compile.tmp && \
	    SUUID_LOGDIR=uuids std -d ./synced.sqlite \
	      -t exec=jada c/std.h jada.h
	cd c/compile.tmp && \
	    SUUID_LOGDIR=uuids std -d ./synced.sqlite \
	      -t exec=jada c/Makefile Makefile
	cd c/compile.tmp && $(MAKE) clean
	cd c/compile.tmp && $(MAKE)
	mkdir -p c/compile.tmp/t
	cd c/compile.tmp/t && std --dbname none perl-tests jada.t \
	    -t progname=jada
	cd c/compile.tmp/t && ./jada.t

.PHONY: test-sh
test-sh:
	cd t && ./sh.t

.PHONY: testport
testport: test-c test-sh
