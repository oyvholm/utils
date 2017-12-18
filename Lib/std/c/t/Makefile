# src/t/Makefile
# File ID: STDuuidDTS

.PHONY: all
all: test

.PHONY: build
build:
	cd .. && $(MAKE)

.PHONY: clean
clean:
	rm -rf tmp-* *-stderr.tmp

.PHONY: test
test: build
	./STDexecDTS.t
