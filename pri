#!/bin/sh

# $Id: pri,v 1.2 1999/05/05 02:49:45 sunny Exp $

pri_dir=~sunny/etc

if [ ! -d $pri_dir ]; then
	mkdir $pri_dir &>/dev/null
fi

if [ ! -d $pri_dir ]; then
	echo "$0: $pri_dir: Directory not found, unable to create it" >&2
	exit 1
fi

$EDITOR $pri_dir/pri.txt
