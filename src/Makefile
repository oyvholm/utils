
# Makefile for ting i ~/bin
# $Id: Makefile,v 1.1 2000/07/08 11:02:49 sunny Exp $

CC = gcc

remouse: remouse.c
	$(CC) -o remouse -Wall -O2 remouse.c
	su -c "chown root.root remouse; chmod +s remouse"

clean:
	rm -f remouse *~ core core.remouse
