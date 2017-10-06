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
	./datefn.t            # freebsd:ok   netbsd:ok   openbsd:ok
	./edit-sqlite3.t      # freebsd:fail netbsd:ok   openbsd:ok
	./filesynced.t        # freebsd:ok   netbsd:ok   openbsd:ok
	./findhex.t           # freebsd:ok   netbsd:ok   openbsd:ok
	./fromhex.t           # freebsd:ok   netbsd:ok   openbsd:ok
	# ./ga-fsck-size.t    # freebsd:fail netbsd:fail openbsd:fail
	# ./ga-sumsize.t      # freebsd:fail netbsd:fail openbsd:fail
	./git-dangling.t      # freebsd:ok   netbsd:ok   openbsd:ok
	./git-dbr.t           # freebsd:ok   netbsd:ok   openbsd:ok
	./git-scanrefs.t      # freebsd:ok   netbsd:ok   openbsd:ok
	./git-testadd.t       # freebsd:fail netbsd:ok   openbsd:ok
	# ./git-update-dirs.t # freebsd:fail netbsd:fail openbsd:fail
	./git-wip.t           # freebsd:ok   netbsd:ok   openbsd:ok
	./gotexp.t            # freebsd:ok   netbsd:ok   openbsd:ok
	./hhi.t               # freebsd:ok   netbsd:ok   openbsd:ok
	./installed_progs.t   # freebsd:hang netbsd:skip openbsd:skip
	./jday.t              # freebsd:fail netbsd:ok   openbsd:ok
	./md-header.t         # freebsd:ok   netbsd:ok   openbsd:ok
	# ./perlmodules.t     # freebsd:fail netbsd:fail openbsd:fail
	# ./postgres.t        # freebsd:fail netbsd:fail openbsd:fail
	./sident.t            # freebsd:ok   netbsd:ok   openbsd:ok
	./sort-sqlite.t       # freebsd:ok   netbsd:ok   openbsd:ok
	./sortxml.t           # freebsd:ok   netbsd:ok   openbsd:ok
	./std.t               # freebsd:ok   netbsd:ok   openbsd:ok
	./sumdup.t            # freebsd:ok   netbsd:ok   openbsd:ok
	./tohex.t             # freebsd:ok   netbsd:ok   openbsd:ok
	./txt2uc.t            # freebsd:hang netbsd:ok   openbsd:fail
	./ustr.t              # freebsd:ok   netbsd:ok   openbsd:ok
	./zeropad.t           # freebsd:ok   netbsd:ok   openbsd:ok

.PHONY: clean
clean:
	rm -rf *.tmp tmp-*
	rm -rf *-files/*.tmp *-files/tmp-*
	rm -f install-modules
	rm -rf datefn-files/*.txt datefn-files/repo
	rm -rf edit-sqlite3-files/sqlite-databases
	test -d ga-fsck-size-files/annex-backends && chmod -R +w ga-fsck-size-files/annex-backends || true
	rm -rf ga-fsck-size-files/annex-backends
	test -d ga-sumsize-files/ga-sumsize-repo && chmod -R +w ga-sumsize-files/ga-sumsize-repo || true
	rm -rf ga-sumsize-files/ga-sumsize-repo
	rm -rf sort-sqlite-files/sqlite-dbs
	if test ! -e log/.git; then rm -rf log; fi
