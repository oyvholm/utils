# Lib/std/Makefile
# File ID: 6454cafe-4b04-11e6-8c85-02010e0a6634
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: all
all:

.PHONY: clean
clean:
	cd book-cmark && $(MAKE) clean
	cd c && $(MAKE) -f Makefile.std-test clean
	cd ly && $(MAKE) clean && rm -f STDprojnameDTS.ly STDprojnameDTS.midi

.PHONY: test
test: test-c test-ly test-sh
	cd book-cmark && $(MAKE) test

.PHONY: test-ly
test-ly:
	cd ly && ./test-ly-files

.PHONY: test-c
test-c:
	cd c && $(MAKE) -f Makefile.std-test test

.PHONY: test-sh
test-sh:
	cd t && ./sh.t

.PHONY: testport
testport: test-c test-sh
