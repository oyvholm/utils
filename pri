#!/bin/sh

# $Id: pri,v 1.3 2003/07/30 13:38:15 sunny Exp $

pri_dir=~sunny/etc

if [ ! -d $pri_dir ]; then
	mkdir $pri_dir &>/dev/null
fi

if [ ! -d $pri_dir ]; then
	echo "$0: $pri_dir: Directory not found, unable to create it" >&2
	exit 1
fi

# $EDITOR $pri_dir/pri.txt

gvim ~/p/plan/todo.txt
