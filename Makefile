# utils.git/Makefile
# File ID: 455af534-fd45-11dd-a4b7-000475e441b9

default:
	@echo No default action for make >&2

clean:
	rm -fv synced.sqlite.*.bck *.pyc
	$(MAKE) testclean
	cd Lib/std/book-cmark && $(MAKE) clean
	cd Lib/std/ly && $(MAKE) clean && rm -fv STDprojnameDTS.ly STDprojnameDTS.midi

lgd:
	git lg --date-order $$(git branch -a | cut -c3- | grep -E -e 'remotes/(Spread|bitbucket|github|repoorcz|sunbase)/' | grep -v 'HEAD -> ') $$(git branch | cut -c3-)

obsolete:
	git delrembr $$(cat Div/obsolete-refs.txt); true

remotes:
	git remote add sunbase sunny@git.sunbase.org:/home/sunny/Git/utils.git; true
	git remote add bellmann sunny@bellmann:/home/sunny/repos/Git/utils.git; true
	git remote add bitbucket git@bitbucket.org:sunny256/utils.git; true
	git remote add github git@github.com:sunny256/utils.git; true
	git remote add gitlab git@gitlab.com:sunny256/utils.git; true
	git remote add repoorcz ssh://sunny256@repo.or.cz/srv/git/sunny256-utils.git; true

test:
	test -z "$$(filesynced --valid-sha)"
	cd tests && $(MAKE)
	cd Lib/std/ly && ./test-ly-files
	cd Lib/std/c && ./compile
	cd src/fldb/tests && $(MAKE)
	cd src/smsum/tests && $(MAKE)
	cd Git/spar/t && $(MAKE)
	cd Git/suuid/tests && $(MAKE)
	cd src/gpstools/tests && $(MAKE)

testclean:
	cd Lib/std/c && rm -rfv compile.tmp
	cd tests && $(MAKE) clean
	cd src/fldb/tests && $(MAKE) clean
	cd src/smsum/tests && $(MAKE) clean
	cd Git/spar/t && $(MAKE) clean
	cd Git/suuid/tests && $(MAKE) clean

unmerged:
	git br -a --no-merged | grep -v /all/ | cut -f 3- -d / | rmspcall | sort -u | grep -v ^commit-

update:
	cd Git && ./update
