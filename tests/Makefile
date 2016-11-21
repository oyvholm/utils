# tests/Makefile
# File ID: 4c99dd2c-5d7c-11df-86e2-90e6ba3022ac

.PHONY: test
test:
	test ! -e ../synced.sql.lock
	./datefn.t
	./edit-sqlite3.t
	./filesynced.t
	./findhex.t
	./fromhex.t
	./ga-fsck-size.t
	./ga-sumsize.t
	./git-dangling.t
	./git-dbr.t
	./git-scanrefs.t
	./git-testadd.t
	./git-update-dirs.t
	./git-wip.t
	./gotexp.t
	./hhi.t
	./installed_progs.t
	./jday.t
	./md-header.t
	./perlmodules.t
	./postgres.t
	./sident.t
	./sort-sqlite.t
	./sortxml.t
	./std.t
	./sumdup.t
	./tohex.t
	./txt2uc.t
	./ustr.t
	./zeropad.t

.PHONY: testport
testport:
	./findhex.t
	./git-wip.t
	./hhi.t
	./sident.t

.PHONY: clean
clean:
	rm -rfv *.tmp tmp-*
	rm -rfv *-files/*.tmp *-files/tmp-*
	rm -rfv datefn-files/*.txt datefn-files/repo
	rm -f datefn-files/95a4b9f6-*
	rm -rfv edit-sqlite3-files/sqlite-databases
	rm -f edit-sqlite3-files/787a43c8-*
	test -d ga-fsck-size-files/annex-backends && chmod -R +w ga-fsck-size-files/annex-backends || true
	rm -rf ga-fsck-size-files/annex-backends
	test -d ga-sumsize-files/ga-sumsize-repo && chmod -R +w ga-sumsize-files/ga-sumsize-repo || true
	rm -rf ga-sumsize-files/ga-sumsize-repo
	rm -rfv sort-sqlite-files/sqlite-dbs
	if test ! -e log/.git; then rm -rfv log; fi
