# sunny256/utils.git/src/Makefile
# File ID: 89595d4a-4aed-11e6-8641-02010e0a6634
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: default
default:
	cd check_utf8 && $(MAKE)
	cd dbf2tab && $(MAKE)
	cd fldb && $(MAKE)
	cd personnr && $(MAKE)
	cd smsum && $(MAKE)


.PHONY: clean
clean:
	cd check_utf8 && $(MAKE) clean
	cd dbf2tab && $(MAKE) clean
	cd fldb && $(MAKE) clean
	cd personnr && $(MAKE) clean
	cd smsum && $(MAKE) clean

.PHONY: test
test:
	cd check_utf8 && $(MAKE) test
	cd dbf2tab && $(MAKE) test
	cd fldb && $(MAKE) test
	cd personnr && $(MAKE) test
	cd smsum && $(MAKE) test
