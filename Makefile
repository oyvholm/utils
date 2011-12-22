#!/usr/bin/make

# Makefile
# File ID: 455af534-fd45-11dd-a4b7-000475e441b9

all:
	@echo Syntax: make test

update:
	cd Git && ./update
	cd Externals && ./update

test:
	cd tests; $(MAKE)
	cd Lib/std/c; ./compile
	cd src/fldb/tests; $(MAKE)
	cd src/smsum/tests; $(MAKE)
	cd src/suuid/tests; $(MAKE)
	cd src/gpstools/tests; $(MAKE)

testclean:
	cd Lib/std/c && rm -rfv compile.tmp
	cd tests && $(MAKE) clean
	cd src/fldb/tests && $(MAKE) clean
	cd src/smsum/tests && $(MAKE) clean
	cd src/suuid/tests && $(MAKE) clean
	cd src/gpstools/tests && $(MAKE) clean

unmerged:
	git br -a --no-merged | grep -v /all/ | cut -f 3- -d / | rmspcall | sort -u | grep -v ^commit-

clean: testclean

remotes:
	git remote add Spread sunny@git.sunbase.org:/home/sunny/Git-spread/utils.git; true
	git remote add bitbucket git@bitbucket.org:sunny256/utils.git
	git remote add github git@github.com:sunny256/utils.git; true
	git remote add gitorious git@gitorious.org:sunny256/utils.git; true
	git remote add repoorcz ssh://sunny256@repo.or.cz/srv/git/sunny256-utils.git; true
	git remote add sunbase sunny@git.sunbase.org:/home/sunny/Git/utils; true
