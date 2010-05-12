
# Lib/perllib/Makefile
# File ID: 143f5222-5d7c-11df-8a0c-90e6ba3022ac
# Makefile for generering av *.3, *.dvi, *.ps og *.html

all: tricgi.dvi tricgi.ps tricgi.html

tricgi.ps: tricgi.dvi tricgi.pm
	dvips -t a4 -o tricgi.ps tricgi.dvi

tricgi.dvi: tricgi.3
	groff -man -Tdvi <tricgi.3 >tricgi.dvi

tricgi.3: tricgi.pm
	pod2man tricgi.pm >tricgi.3

tricgi.html: tricgi.pm
	pod2html <tricgi.pm >tricgi.html
	rm -f pod2html-*cache

clean:
	rm -f tricgi.3 tricgi.html tricgi.dvi tricgi.man tricgi.ps core *~
