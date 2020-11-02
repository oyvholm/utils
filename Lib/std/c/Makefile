# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

IGNFILES  =
IGNFILES += -e ^COPYING

.PHONY: all
all:
	cd src && $(MAKE)

%.html: FORCE
	test -e "$*.md"
	echo '<html>' >$@.tmp
	echo '<head>' >>$@.tmp
	echo '<meta charset="UTF-8" />' >>$@.tmp
	echo '<title>$* - STDexecDTS</title>' >>$@.tmp
	echo '</head>' >>$@.tmp
	echo '<body>' >>$@.tmp
	cmark $*.md >>$@.tmp
	if test -n "$$(git log -1 --format=%h $*.md 2>/dev/null)"; then \
		(echo 'Generated from `$*.md`'; \
		git log -1 --format='revision `%h` (%ci)' \
		    $*.md) | cmark >>$@.tmp; \
	fi
	echo '</body>' >>$@.tmp
	echo '</html>' >>$@.tmp
	mv $@.tmp $@

%.pdf: FORCE
	$(MAKE) $*.html
	wkhtmltopdf $*.html $@

tags: src/*.[ch]
	ctags src/*.[ch]

.PHONY: clean
clean:
	rm -f README.html
	rm -f README.pdf
	cd src && $(MAKE) clean

.PHONY: edit
edit: tags
	$(EDITOR) $$(git ls-files | grep -v $(IGNFILES))
	rm tags

.PHONY: FORCE
FORCE:

.PHONY: test
test:
	cd src && $(MAKE) test

.PHONY: testall
testall:
	cd src && $(MAKE) testall

.PHONY: valgrind
valgrind:
	cd src && $(MAKE) valgrind

.PHONY: valgrindall
valgrindall:
	cd src && $(MAKE) valgrindall
