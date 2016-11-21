# Lib/perllib/Makefile
# File ID: 143f5222-5d7c-11df-8a0c-90e6ba3022ac
# Makefile for generating *.3, *.dvi, *.ps and *.html

.PHONY: default
default: tricgi.dvi tricgi.ps tricgi.html

tricgi.ps: tricgi.dvi
	dvips -t a4 -o tricgi.ps tricgi.dvi

tricgi.dvi: tricgi.3
	groff -man -Tdvi <tricgi.3 >tricgi.dvi

tricgi.3: tricgi.pm
	pod2man tricgi.pm >tricgi.3

tricgi.html: tricgi.pm
	pod2html <tricgi.pm >tricgi.html
	rm -f pod2html-*cache

.PHONY: clean
clean:
	rm -f tricgi.3 tricgi.html tricgi.dvi tricgi.man tricgi.ps core *~
	rm -f pod2htmd.tmp

.PHONY: test
test:
