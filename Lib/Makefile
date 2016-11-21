# Lib/Makefile
# File ID: bfd8fbc6-4b03-11e6-811f-02010e0a6634
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: default
default:
	cd perllib && $(MAKE)
	cd std && $(MAKE)

.PHONY: clean
clean:
	cd perllib && $(MAKE) clean
	cd std && $(MAKE) clean

.PHONY: test
test:
	cd perllib && $(MAKE) test
	cd std && $(MAKE) test

.PHONY: testport
testport:
	cd std && $(MAKE) testport
