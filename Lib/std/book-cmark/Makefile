# Makefile
# File ID: STDuuidDTS

.PHONY: default
default:
	@$(MAKE) -s wc

.PHONY: clean
clean:
	rm -f index.html synced.sqlite.*.bck

.PHONY: edit
edit:
	mkdir .make-edit.lock
	(v index.md; rmdir .make-edit.lock)

.PHONY: html
html:
	bin/create-html index.md

.PHONY: loop
loop:
	git wait-until-clean
	git checkout master
	git fp || true
	git mff
	git allbr -a
	git checkout loop-5sec
	git mff master
	while :; do echo; ciall -y -- Loop 5sec - $$(bin/stats index.md); sleep 5; done

.PHONY: spar
spar:
	sqlite3 ~/spar/.STDprojnameDTS.spar.make-spar.tmp <dat/STDprojnameDTS.sql
	mv ~/spar/.STDprojnameDTS.spar.make-spar.tmp ~/spar/STDprojnameDTS.spar

.PHONY: stat
stat:
	bin/loop-stat --colour index.md

.PHONY: test
test:

.PHONY: wc
wc:
	@bin/stats -c index.md
	@echo wc: $$(bin/stats --data index.md | wc -w)
	@$(MAKE) -s spar
	@spar -s STDprojnameDTS | tail -1
