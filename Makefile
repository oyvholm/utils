#!/usr/bin/make

# $Id$

all:
	@echo Syntax: make test

test:
	cd tests; $(MAKE)
	cd src/gpstools/tests; $(MAKE)
	cd src/fldb/tests; $(MAKE)
	cd src/smsum/tests; $(MAKE)

testclean:
	cd tests; $(MAKE) clean
	cd src/gpstools/tests; $(MAKE) clean
	cd src/fldb/tests; $(MAKE) clean
	cd src/smsum/tests; $(MAKE) clean
