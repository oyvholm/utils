# Makefile
# File ID: 41723b1a-5d7c-11df-a35a-90e6ba3022ac

CC = gcc
EXEC = check_utf8

check_utf8: check_utf8.c
	$(CC) -Wall -o $(EXEC) -O2 check_utf8.c

.PHONY: clean
clean:
	rm -fv core $(EXEC)

.PHONY: test
test:
