# Lib/std/Makefile
# File ID: 6454cafe-4b04-11e6-8c85-02010e0a6634
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: default
default:

.PHONY: clean
clean:
	cd book-cmark && $(MAKE) clean
	cd c && $(MAKE) clean
	cd c && rm -fv STDexecDTS.c STDexecDTS.h
	cd c && rm -frv t compile.tmp
	cd ly && $(MAKE) clean && rm -fv STDprojnameDTS.ly STDprojnameDTS.midi

.PHONY: test
test:
	cd book-cmark && $(MAKE) test
	cd c && ./compile
	cd ly && ./test-ly-files
