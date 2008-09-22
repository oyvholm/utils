#!/usr/bin/make

# $Id$

all:
	for f in `ls *.t | perl -pe 's/\.t\$$//'`; do \
		echo === $$f.t; \
		./$$f.t --all 2>&1 | remove_perltestnumbers >log/$$f.log; \
	done
