#!/bin/sh

# pri
# File ID: af1db854-5d42-11df-bfc8-90e6ba3022ac

pri_dir=~sunny/etc

if [ ! -d $pri_dir ]; then
	mkdir $pri_dir &>/dev/null
fi

if [ ! -d $pri_dir ]; then
	echo "$0: $pri_dir: Directory not found, unable to create it" >&2
	exit 1
fi

# $EDITOR $pri_dir/pri.txt

cd ~/p/plan
cvs -q upd -d
echo -n Trykk ENTER...
read
vim todo.txt
echo -n Trykk ENTER for cvs checkin, cller CTRL-C for å drite i det...
read
cvs ci -m "Lagt inn med pri-scriptet" todo.txt
cd -
