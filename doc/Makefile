#!/usr/bin/make

#=======================================================================
# $Id$
#=======================================================================

BOOKFILES = index.xml
HTMLFILE = index.html

$(HTMLFILE): $(BOOKFILES)
	xsltproc --output $(HTMLFILE) ~/xsl/xhtml/docbook.xsl $(BOOKFILES)
	xmllint --format --encode UTF-8 $(HTMLFILE) >$(HTMLFILE).tmp
	mv -v $(HTMLFILE).tmp $(HTMLFILE)

htmlbook:
	$(MAKE) clean && $(MAKE) all-html

clean:
	rm -f $(HTMLFILE)

ready:
	$(MAKE) clean
	$(MAKE)
	svn st

# $Id$
# vim: set ts=4 sw=4 sts=4 noet :
