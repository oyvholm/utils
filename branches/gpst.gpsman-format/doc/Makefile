#!/usr/bin/make

#=======================================================================
# $Id$
#=======================================================================

dbfile=gpst.xml
htmlfile=gpst.html
manpage=gpst.1

all:
	$(MAKE) $(manpage)
	$(MAKE) $(htmlfile)

$(manpage): $(dbfile)
	xsltproc --output $(manpage) ~/xsl/manpages/docbook.xsl $(dbfile)

$(htmlfile): $(dbfile)
	xsltproc --output $(htmlfile) ~/xsl/xhtml/docbook.xsl $(dbfile)

valid:
	xmllint --valid --noout $(dbfile)
