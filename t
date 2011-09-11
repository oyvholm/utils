#!/bin/bash

#=======================================================================
# t
# File ID: e2469b62-dc83-11e0-9dfc-9f1b7346cb92
# Shortcut to task(1) and commit changes to Git
# License: GNU General Public License version 3 or later.
#=======================================================================

progname=t
lockdir=$HOME/.t-task.LOCK

myexit() {
    rmdir $lockdir || echo $progname: $lockdir: Cannot remove lockdir >&2
    exit $1
}

mkdir $lockdir || { echo $progname: $lockdir: Cannot create lockdir >&2; exit 1; }
trap "myexit 1" INT TERM

task "$@"
cd ~/src/git/task || { echo $progname: Cannot chdir >&2; exit 1; }
yes | ciall -d t "$@" >/dev/null 2>&1
myexit 0
