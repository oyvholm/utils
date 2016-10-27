# tests/Makefile
# File ID: 4c99dd2c-5d7c-11df-86e2-90e6ba3022ac

.PHONY: test
test:
	Genlog *.t

.PHONY: clean
clean:
	rm -rfv *.tmp tmp-*
	rm -rfv datefn-files/file.txt datefn-files/repo
	rm -rfv edit-sqlite3-files/sqlite-databases
	test -d ga-fsck-size-files/annex-backends && chmod -R +w ga-fsck-size-files/annex-backends || true
	rm -rf ga-fsck-size-files/annex-backends
	test -d ga-sumsize-files/ga-sumsize-repo && chmod -R +w ga-sumsize-files/ga-sumsize-repo || true
	rm -rf ga-sumsize-files/ga-sumsize-repo
	rm -rfv sort-sqlite-files/sqlite-dbs
