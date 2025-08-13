# File ID: STDuuidDTS
# Author: Øyvind A. Holm <sunny@sunbase.org>

IGNFILES  =
IGNFILES += -e ^COPYING
LONGLINES_FILES  =
LONGLINES_FILES += Makefile
LONGLINES_FILES += README.md

.PHONY: all
all:
	cd src && $(MAKE) $@

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
	wkhtmltopdf $*.html $@.tmp
	mv $@.tmp $@

tags: src/*.[ch]
	ctags src/*.[ch]

.PHONY: cflags
cflags:
	@cd src && $(MAKE) -s $@

.PHONY: clean
clean:
	rm -f README.html README.html.tmp
	rm -f README.pdf README.pdf.tmp
	cd src && $(MAKE) $@

.PHONY: edit
edit: tags
	$(EDITOR) $$(git ls-files | grep -v $(IGNFILES))
	rm tags

.PHONY: FORCE
FORCE:

.PHONY: html
html:
	$(MAKE) README.html
	cd src && $(MAKE) $@

.PHONY: install
install:
	cd src && $(MAKE) $@

.PHONY: longlines
longlines:
	@for f in $(LONGLINES_FILES); do \
		if [ -f "$$f" ]; then \
			d="$$(expand "$$f" | sed 's/ $$//;' \
			      | perl -C3 -ne \
			        'chomp; \
			        print("$$.:$$_\n") if length > 79;')"; \
			echo "$$d" | grep -q . \
			&& (echo "$$f"; printf "%s\\n" "$$d"; echo " "); \
		fi; \
	done | grep . && exit 1 || true
	cd src && $(MAKE) -s $@

.PHONY: pdf
pdf:
	$(MAKE) README.pdf
	cd src && $(MAKE) $@

.PHONY: test
test:
	cd src && $(MAKE) $@

.PHONY: testall
testall:
	$(MAKE) -s testsrc
	cd src && $(MAKE) -s $@

.PHONY: testsrc
testsrc:
	@echo Check files for long lines
	@$(MAKE) -s longlines
	cd src && $(MAKE) -s $@

.PHONY: tlok
tlok:
	@cd src && $(MAKE) -s $@

.PHONY: tlokall
tlokall:
	@cd src && $(MAKE) -s $@

.PHONY: uninstall
uninstall:
	cd src && $(MAKE) $@

.PHONY: valgrind
valgrind:
	cd src && $(MAKE) $@

.PHONY: valgrindall
valgrindall:
	cd src && $(MAKE) $@
