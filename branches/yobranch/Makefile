#!/usr/bin/make

# $Id$
# File ID: 455af534-fd45-11dd-a4b7-000475e441b9

all:
	@echo Syntax: make test

test:
	cd tests; $(MAKE)
	cd src/gpstools/tests; $(MAKE)
	cd src/fldb/tests; $(MAKE)
	cd src/smsum/tests; $(MAKE)
	cd src/suuid/tests; $(MAKE)

testclean:
	cd tests; $(MAKE) clean
	cd src/gpstools/tests; $(MAKE) clean
	cd src/fldb/tests; $(MAKE) clean
	cd src/smsum/tests; $(MAKE) clean
	cd src/suuid/tests; $(MAKE) clean
