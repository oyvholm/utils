
# Makefile for generering av *.3, *.dvi, *.ps og *.html
# $Header: /home/sunny/tmp/cvs/perllib/Makefile,v 1.2 1999/07/05 14:06:14 sunny Exp $

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
