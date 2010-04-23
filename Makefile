#!/usr/bin/make

# $Id$
# File ID: 455af534-fd45-11dd-a4b7-000475e441b9

all:
	@echo Syntax: make test

update:
	cd Git && ./update
	cd Externals && ./update

test:
	cd tests; $(MAKE)
	cd src/gpstools/tests; $(MAKE)
	cd src/fldb/tests; $(MAKE)
	cd src/smsum/tests; $(MAKE)
	cd src/suuid/tests; $(MAKE)

testclean:
	cd tests; $(MAKE) clean
	cd src/gpstools/tests; $(MAKE) clean
	cd src/fldb/tests; $(MAKE) clean
	cd src/smsum/tests; $(MAKE) clean
	cd src/suuid/tests; $(MAKE) clean

remotes:
	git remote add github git@github.com:sunny256/utils.git; true
	git remote add gitorious git@gitorious.org:sunny256/utils.git; true
	git remote add repoorcz ssh://sunny256@repo.or.cz/srv/git/sunny256-utils.git; true
	git remote add sunbase sunny@git.sunbase.org:/home/sunny/Git/utils; true

pushall:
	git push --all sunbase; true
	git push --tags sunbase; true
	git push github; true
	git push gitorious; true
	git push repoorcz; true
