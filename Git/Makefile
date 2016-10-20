# sunny256/utils.git/Git/Makefile
# File ID: 83bbcb90-4aeb-11e6-b612-02010e0a6634

DIRS = gpstools spar suuid

.PHONY: default
default:
	@for d in $(DIRS); do \
		if test -f "$$d/Makefile"; then \
			echo Running $(MAKE) in $$d/ >&2; \
			(cd "$$d" && $(MAKE)) || exit 1; \
		else \
			echo Skipping $$d/, Makefile not found >&2; \
			true; \
		fi \
	done

.PHONY: clean
clean:
	@for d in $(DIRS); do \
		if test -f "$$d/Makefile"; then \
			echo Running $(MAKE) clean in $$d/ >&2; \
			(cd "$$d" && $(MAKE) clean) || exit 1; \
		else \
			echo Skipping $$d/, Makefile not found >&2; \
			true; \
		fi \
	done

.PHONY: test
test:
	@for d in $(DIRS); do \
		if test -f "$$d/Makefile"; then \
			echo Running $(MAKE) test in $$d/ >&2; \
			(cd "$$d" && $(MAKE) test) || exit 1; \
		else \
			echo Skipping $$d/, Makefile not found >&2; \
			true; \
		fi \
	done
