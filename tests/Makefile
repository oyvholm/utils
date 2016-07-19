# tests/Makefile
# File ID: 4c99dd2c-5d7c-11df-86e2-90e6ba3022ac

test:
	Genlog *.t

clean:
	rm -rf *.tmp tmp-*
	rm -rf datefn-files/file.txt datefn-files/repo
	rm -rf edit-sqlite3-files/sqlite-databases
	test -d ga-fsck-size-files/annex-backends && chmod -Rc +w ga-fsck-size-files/annex-backends || true
	rm -rf ga-fsck-size-files/annex-backends
	test -d ga-sumsize-files/ga-sumsize-repo && chmod -Rc +w ga-sumsize-files/ga-sumsize-repo || true
	rm -rf ga-sumsize-files/ga-sumsize-repo
	rm -rf sort-sqlite-files/sqlite-dbs
