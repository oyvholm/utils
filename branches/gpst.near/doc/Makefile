#!/usr/bin/make

#=======================================================================
# $Id$
#=======================================================================

dbfile=gpst.xml
htmlfile=gpst.html

$(htmlfile): $(dbfile)
	xsltproc --output $(htmlfile) ~/xsl/xhtml/docbook.xsl $(dbfile)
