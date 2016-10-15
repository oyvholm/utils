# sunny256/utils.git/Makefile
# File ID: 455af534-fd45-11dd-a4b7-000475e441b9
# Author: Øyvind A. Holm <sunny@sunbase.org>

.PHONY: default
default:
	cd Lib && $(MAKE)
	cd src && $(MAKE)
	cd Git && $(MAKE)

.PHONY: clean
clean:
	rm -fv synced.sqlite.*.bck *.pyc
	cd tests && $(MAKE) clean
	cd Lib && $(MAKE) clean
	cd src && $(MAKE) clean
	cd Git && $(MAKE) clean

.PHONY: lgd
lgd:
	git lg --date-order $$(git branch -a | cut -c3- | \
	    grep -Ee 'remotes/(Spread|bitbucket|github|repoorcz|sunbase)/' | \
	    grep -v 'HEAD -> ') $$(git branch | cut -c3-)

.PHONY: obsolete
obsolete:
	git delrembr $$(cat Div/obsolete-refs.txt); true

.PHONY: remotes
remotes:
	git remote add \
	    sunbase sunny@git.sunbase.org:/home/sunny/Git/utils.git; true
	git remote add \
	    bellmann sunny@bellmann:/home/sunny/repos/Git/utils.git; true
	git remote add bitbucket git@bitbucket.org:sunny256/utils.git; true
	git remote add github git@github.com:sunny256/utils.git; true
	git remote add gitlab git@gitlab.com:sunny256/utils.git; true
	git remote add \
	    repoorcz ssh://sunny256@repo.or.cz/srv/git/sunny256-utils.git; true

.PHONY: test
test:
	test ! -e synced.sql.lock
	test -z "$$(filesynced --valid-sha 2>&1)"
	test -z "$$(filesynced --unsynced -- --since=6.months 2>&1)"
	test "$$(git log | grep -- -by: | sort -u | wc -l)" = "2"
	cd tests && $(MAKE) test
	cd Lib && $(MAKE) test
	cd src && $(MAKE) test
	cd Git && $(MAKE) test

.PHONY: unmerged
unmerged:
	git log --graph --date-order --format=fuller -p --decorate=short \
		$$(git br -a --contains firstrev --no-merged | git nocom) \
		^master
