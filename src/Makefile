# sunny256/utils.git/src/Makefile
# File ID: 89595d4a-4aed-11e6-8641-02010e0a6634
# Author: Øyvind A. Holm <sunny@sunbase.org>

# FIXME: fldb is ignored due to @INC problems as usual, it expects libs to be 
# under `~/bin/src/fldb/`.
#
# FIXME: personnr is disabled because it won't compile on Gitlab CI, see the 
# log message for ff30bb9c214c for the warnings. One example is 
# "personnr.c:256:18: error: '%s' directive writing up to 19 bytes into a 
# region of size 12 [-Werror=format-overflow=]". Jawohl. It also doesn't really 
# belong here, there's some old CVS repo I've to dig up with all the old 
# history and then splice it somehow.

.PHONY: default
default:
	cd check_utf8 && $(MAKE)
	cd dbf2tab && $(MAKE)
	# cd fldb && $(MAKE)
	# cd personnr && $(MAKE)
	cd smsum && $(MAKE)

.PHONY: clean
clean:

.PHONY: fullclean
fullclean: clean
	cd check_utf8 && $(MAKE) clean
	cd dbf2tab && $(MAKE) clean
	# cd fldb && $(MAKE) clean
	# cd personnr && $(MAKE) clean
	cd smsum && $(MAKE) clean

.PHONY: test
test:
	cd check_utf8 && $(MAKE) test
	cd dbf2tab && $(MAKE) test
	# cd fldb && $(MAKE) test
	# cd personnr && $(MAKE) test
	cd smsum && $(MAKE) test

.PHONY: testport
testport:
	cd smsum && $(MAKE) testport
