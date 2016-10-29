# tests/Makefile
# File ID: af30306a-f943-11dd-b22a-0001805bf4b1
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: test
test:
	Genlog *.t

.PHONY: clean
clean:
	rm -rf *.tmp
	if test ! -e log/.git; then rm -rfv log; fi
