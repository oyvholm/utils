# sunny256/utils.git/Git/Makefile
# File ID: 83bbcb90-4aeb-11e6-b612-02010e0a6634

MAKEFILES = */Makefile
# FIXME: Make gpstools work
DIRS =  $$(echo $? | fmt -1 | cut -f 1 -d / | grep -v gpstools | sort -u)

.PHONY: default
default: $(MAKEFILES)
	for f in $(DIRS); do (cd $$f && $(MAKE)) || exit 1; done

.PHONY: clean
clean:

.PHONY: fullclean
fullclean: $(MAKEFILES)
	for f in $(DIRS); do (cd $$f && $(MAKE) clean) || exit 1; done

.PHONY: test
test: $(MAKEFILES)
	for f in $(DIRS); do (cd $$f && $(MAKE) test) || exit 1; done

.PHONY: testport
testport:
	if test -f gpstools/Makefile; then \
		cd gpstools/tests && \
		./addpoints.t && \
		./csv2gpx.t && \
		./gpst-file.t && \
		./roundgpx.t || exit 1; \
	fi
	if test -f spar/Makefile; then cd spar && $(MAKE) test; fi
	if test -f suuid/Makefile; then cd suuid && $(MAKE) test; fi

.PHONY: valgrind
valgrind: $(MAKEFILES)
	for f in $(DIRS); do \
		if grep -q ^valgrind: $$f/Makefile; then \
			(cd $$f && $(MAKE) valgrind) || exit 1; \
		fi \
	done
