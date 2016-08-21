#!/bin/bash

#=======================================================================
# t
# File ID: e2469b62-dc83-11e0-9dfc-9f1b7346cb92
#
# Shortcut to task(1) and commit changes to Git
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#=======================================================================

progname=t
VERSION=0.1.0

if test "$1" = "--version"; then
    echo $progname $VERSION
    exit 0
fi

if test "$1" = "-h" -o "$1" = "--help"; then
    cat <<END

Frontend to task(1) (Taskwarrior), commit the result of every command to 
Git.

Usage: $progname [options] TASK_COMMAND

Options:

  -h, --help
    Show this help.
  --version
    Print version information.

END
    exit 0
fi

lockdir=$HOME/.t-task.LOCK
taskdir=$HOME/src/git/task

myexit() {
    rmdir $lockdir || echo $progname: $lockdir: Cannot remove lockdir >&2
    exit $1
}

mkdir $lockdir || {
    echo $progname: $lockdir: Cannot create lockdir >&2
    exit 1
}
trap "myexit 1" INT TERM

cd $taskdir || { echo $progname: $taskdir: Cannot chdir >&2; myexit 1; }
if [ ! -f $taskdir/.taskrc -o ! -d $taskdir/.task ]; then
    echo $progname: Missing files in $taskdir/ >&2
    myexit 1
fi
task "$@"
yes | ciall t "$@" >/tmp/t-output.txt 2>&1 || {
    echo $progname: git commit error >&2
    exit 1
}

task &>/dev/null
yes | ciall Finish previous command >/tmp/t-output-2.txt 2>&1 || {
    echo $progname: git commit 2 error >&2
    exit 1
}

myexit 0
