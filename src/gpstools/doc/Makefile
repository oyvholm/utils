#!/usr/bin/make

#=======================================================================
# $Id$
# File ID: e1f98eac-fafa-11dd-97ce-000475e441b9
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
