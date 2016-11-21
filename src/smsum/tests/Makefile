# tests/Makefile
# File ID: af30306a-f943-11dd-b22a-0001805bf4b1
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: test
test:
	./smsum.t

.PHONY: clean
clean:
	rm -rf *.tmp
	if test ! -e log/.git; then rm -rfv log; fi
	rm -f files/57b68db8-*
	rm -rf files/dir1

.PHONY: testport
testport: test
