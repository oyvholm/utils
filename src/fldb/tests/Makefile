# tests/Makefile
# File ID: 323f7bca-f9f1-11dd-8b2b-000475e441b9
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: test
test:
	Genlog *.t

.PHONY: clean
clean:
	rm -rf *.tmp
	if test ! -e log/.git; then rm -rfv log; fi
