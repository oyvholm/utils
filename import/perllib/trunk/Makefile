
# Makefile for generering av *.dvi, *.ps og *.html
# $Header: /home/sunny/tmp/cvs/perllib/Makefile,v 1.1 1999/07/05 13:30:14 sunny Exp $

all: tricgi.dvi tricgi.ps tricgi.html

tricgi.ps: tricgi.dvi tricgi.pm
	dvips -t a4 -o tricgi.ps tricgi.dvi

tricgi.dvi: tricgi.3
	groff -man -Tdvi <tricgi.3 >tricgi.dvi

tricgi.3: tricgi.pm
	pod2man tricgi.pm >tricgi.3

tricgi.html: tricgi.pm
	pod2html <tricgi.pm >tricgi.html

clean:
	rm -f tricgi.3 tricgi.html tricgi.dvi tricgi.man tricgi.ps core *~ \
	pod2html-*cache
