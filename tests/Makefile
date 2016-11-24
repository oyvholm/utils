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
	./datefn.t # netbsd:ok openbsd:ok
	# ./edit-sqlite3.t # netbsd:fail openbsd:fail
	./filesynced.t # netbsd:ok openbsd:ok
	./findhex.t # netbsd:ok openbsd:ok
	./fromhex.t # netbsd:ok openbsd:ok
	# ./ga-fsck-size.t # netbsd:fail openbsd:fail
	# ./ga-sumsize.t # netbsd:fail openbsd:fail
	./git-dangling.t # netbsd:ok openbsd:ok
	./git-dbr.t # netbsd:ok openbsd:ok
	./git-scanrefs.t # netbsd:ok openbsd:ok
	# ./git-testadd.t # netbsd:fail openbsd:fail
	# ./git-update-dirs.t # netbsd:fail openbsd:fail
	./git-wip.t # netbsd:ok openbsd:ok
	./gotexp.t # netbsd:ok openbsd:ok
	./hhi.t # netbsd:ok openbsd:ok
	# ./installed_progs.t # netbsd:fail openbsd:fail
	# ./jday.t # netbsd:fail openbsd:fail
	# ./md-header.t # netbsd:fail openbsd:ok
	# ./perlmodules.t # netbsd:fail openbsd:fail
	# ./postgres.t # netbsd:fail openbsd:fail
	./sident.t # netbsd:ok openbsd:ok
	# ./sort-sqlite.t # netbsd:fail openbsd:ok
	./sortxml.t # netbsd:ok openbsd:ok
	./std.t # netbsd:ok openbsd:fail
	./sumdup.t # netbsd:ok openbsd:ok
	./tohex.t # netbsd:ok openbsd:ok
	# ./txt2uc.t # netbsd:fail openbsd:fail
	./ustr.t # netbsd:ok openbsd:ok
	# ./zeropad.t # netbsd:fail openbsd:ok

.PHONY: clean
clean:
	rm -rf *.tmp tmp-*
	rm -rf *-files/*.tmp *-files/tmp-*
	rm -f install-modules
	rm -rf datefn-files/*.txt datefn-files/repo
	rm -f datefn-files/95a4b9f6-*
	rm -rf edit-sqlite3-files/sqlite-databases
	rm -f edit-sqlite3-files/787a43c8-*
	test -d ga-fsck-size-files/annex-backends && chmod -R +w ga-fsck-size-files/annex-backends || true
	rm -rf ga-fsck-size-files/annex-backends
	rm -f ga-fsck-size-files/8626cc04-*
	test -d ga-sumsize-files/ga-sumsize-repo && chmod -R +w ga-sumsize-files/ga-sumsize-repo || true
	rm -rf ga-sumsize-files/ga-sumsize-repo
	rm -f ga-sumsize-files/8aef4e74-*
	rm -rf sort-sqlite-files/sqlite-dbs
	rm -f sort-sqlite-files/127d434a-*
	if test ! -e log/.git; then rm -rf log; fi
