
# Makefile for article
# $Id: Makefile,v 1.1 1999/09/16 14:03:11 sunny Exp $
#
# Laget for bruk under RedHat Linux 5.2 og lignende
# (C)opyright 1999 Øyvind A. Holm <sunny@pils.kvarteret.uib.no>

article.ps: article.dvi Makefile
	@# @echo === dvips ==========================================================
	@# dvips -t a4 -o article.ps article.dvi

# LaTeX kjøres tre ganger for å oppdatere alt mulig.
article.dvi: article.tex Makefile
	@echo === latex 1/3 ======================================================
	latex article.tex
	@echo === latex 2/3 ======================================================
	latex article.tex
	@echo === latex 3/3 ======================================================
	latex article.tex

clean:
	rm -f core *~
	rm -f article.ps article.dvi article.aux article.log article.toc

view:
	xdvi -s 12 -paper a4 article.dvi &

# End of file $Id: Makefile,v 1.1 1999/09/16 14:03:11 sunny Exp $
