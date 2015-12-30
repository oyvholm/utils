# Makefile
# File ID: STDuuidDTS

default:
	@make -s wc

clean:
	rm -fv index.html synced.sqlite.*.bck

edit:
	mkdir .make-edit.lock
	(v index.md; rmdir .make-edit.lock)

html:
	bin/create-html index.md

loop:
	git wait-until-clean
	git checkout master
	git fp || true
	git mff
	git allbr -a
	git checkout loop-5sec
	git mff master
	while :; do echo; ciall -y -- Loop 5sec - $$(bin/stats index.md); sleep 5; done

spar:
	sqlite3 ~/spar/.STDprojnameDTS.spar.make-spar.tmp <dat/STDprojnameDTS.sql
	mv ~/spar/.STDprojnameDTS.spar.make-spar.tmp ~/spar/STDprojnameDTS.spar

stat:
	bin/loop-stat --colour index.md

wc:
	@bin/stats -c index.md
	@echo wc: $$(bin/stats --data index.md | wc -w)
	@make -s spar
	@spar -s STDprojnameDTS | tail -1
