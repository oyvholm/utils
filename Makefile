#!/usr/bin/make

# $Id$

all:
	@echo Syntax: make test

test:
	cd tests; $(MAKE)
	cd src/gpstools/tests; $(MAKE)
	cd src/fldb/tests; $(MAKE)
	cd src/smsum/tests; $(MAKE)
