# Makefile for personnr.c

default:
	@echo ""
	@echo "For aa kompilere greia, skriv:"
	@echo ""
	@echo "make std"
	@echo "  for standard versjon"
	@echo ""
	@echo "make test"
	@echo "  for en testversjon med midlertidige l0sninger"
	@echo ""
	@echo "make debug"
	@echo "  kompilerer med debuggingsmeldinger og assertions"
	@echo ""
	@echo "make gdb"
	@echo "  kompileres med debuggingsinfo for gdb, debugmeldinger og assertions."
	@echo ""
	@echo "make asm"
	@echo "  lager assemblerkode"
	@echo ""

std:
	@echo Kompilererer standard versjon...
	gcc -W -lm -DLINUX -DC_STD -o personnr personnr.c

test:
	@echo Kompilererer testversjon uten debuggingsmeldinger...
	gcc -W -lm -DLINUX -o personnr personnr.c

asm:
	@echo Kompilererer assemblerkode...
	gcc -W -DLINUX -S personnr.c
	
debug:
	@echo Debuggingsmeldinger og assertions er paa.
	gcc -DLINUX -DC_DEBUG -DC_ASSERT -W -lm -o personnr personnr.c

gdb:
	@echo Kompilerer med debuggingsinfo for gdb, debuggingsmeldinger og assertions.
	gcc -DLINUX -DC_DEBUG -DC_ASSERT -W -lm -g -o personnr personnr.c
