# oyvholm/utils/Makefile
# File ID: 455af534-fd45-11dd-a4b7-000475e441b9
# Author: Øyvind A. Holm <sunny@sunbase.org>

PYFILES  =
PYFILES += git-expand
PYFILES += jsonfmt.py
PYFILES += line_exec.py
T_GREEN=$$(tput setaf 2)
T_RESET=$$(tput sgr0)

.PHONY: all
all:
	cd Lib && $(MAKE)
	cd src && $(MAKE)
	cd Git && $(MAKE)

.PHONY: c-demo
c-demo:
	@cd Lib/std/c/src && $(MAKE) -s -f Makefile.std-test demo

.PHONY: clean
clean:
	rm -f synced.sqlite.*.bck *.pyc
	cd tests && $(MAKE) clean
	cd Lib && $(MAKE) clean
	cd src && $(MAKE) clean
	cd Git && $(MAKE) clean
	find . -name .testadd.tmp -type d -print0 | xargs -0r rm -rf

.PHONY: format
format:
	black -l 79 $(PYFILES)
	cd Lib && $(MAKE) $@

.PHONY: fullclean
fullclean:
	$(MAKE) clean
	cd src && $(MAKE) fullclean
	cd Git && $(MAKE) fullclean

.PHONY: lgd
lgd:
	git lg --date-order $$(git branch -a | cut -c3- | \
	    grep -Ee 'remotes/(Spread|bitbucket|repoorcz|sunbase)/' | \
	    grep -v 'HEAD -> ') $$(git branch | cut -c3-)

.PHONY: obsolete
obsolete:
	git delrembr $$(cat Div/obsolete-refs.txt); true

.PHONY: push
push:
	git push-to-gitlab
	git pa
	git push bitbucket

.PHONY: remotes
remotes:
	git remote add \
	    sunbase sunny@git.sunbase.org:/home/sunny/Git/utils.git; true
	git remote add bitbucket git@bitbucket.org:sunny256/utils.git; true
	git remote add gitlab git@gitlab.com:oyvholm/utils.git; true
	git remote add \
	    repoorcz ssh://sunny256@repo.or.cz/srv/git/sunny256-utils.git; true

.PHONY: test
test:
	test ! -e synced.sql.lock
	# FIXME: synced.sql is modified in Gitlab CI, disable it for now
	if test "$(GITLAB_CI)" != "true"; then \
		test -z "$$(filesynced --valid-sha 2>&1)"; \
	fi
	test "$$(git log | grep -- -by: | sort -u | wc -l)" = "2"
	cd tests && $(MAKE) test
	cd Lib && $(MAKE) test
	cd src && $(MAKE) test
	cd Git && $(MAKE) test

.PHONY: test-clean
test-clean:
	$(MAKE) fullclean
	git status --porcelain --ignored | grep ^ && exit 1 || true

.PHONY: testport
testport:
	cd tests && $(MAKE) testport
	cd Lib && $(MAKE) testport
	cd src && $(MAKE) testport
	cd Git && $(MAKE) testport

.PHONY: tlok
tlok: c-demo
	@cd Lib/std/c/src/compile.tmp && $(MAKE) -s tlok

.PHONY: tlokall
tlokall: c-demo
	@cd Lib/std/c/src/compile.tmp && $(MAKE) -s tlokall

.PHONY: unmerged
unmerged:
	git log --graph --date-order --format=fuller -p --decorate=short \
		$$(git br -a --contains firstrev --no-merged | git nocom) \
		^master

.PHONY: update-synced
update-synced:
	test ! -e .update-synced_token.tmp
	test ! -e synced.sql.lock
	filesynced --lock >.update-synced_token.tmp
	git ls-files | while read f; do \
		if test -f "$$f" -a ! -h "$$f" ; then \
			echo "INSERT INTO synced (file) VALUES ('$$f');"; \
		fi; \
	done | sqlite3 synced.sqlite 2>/dev/null || true
	echo "SELECT file FROM synced ORDER BY file;" | \
	    sqlite3 synced.sqlite | while read f; do \
		if test ! -f "$$f"; then \
			echo "DELETE FROM synced WHERE file = '$$f';"; \
			echo "DELETE FROM todo WHERE file = '$$f';"; \
		fi; \
	done | sqlite3 synced.sqlite
	filesynced --unlock $$(cat .update-synced_token.tmp)
	rm -f .update-synced_token.tmp

.PHONY: valgrind
valgrind:
	cd Git && $(MAKE) valgrind
