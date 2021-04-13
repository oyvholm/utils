#!/usr/bin/env bash

#=======================================================================
# t
# File ID: e2469b62-dc83-11e0-9dfc-9f1b7346cb92
#
# Shortcut to task(1) or timew(1) and commit changes to Git
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#=======================================================================

progname=t
VERSION=0.6.0

if test "$1" = "--version"; then
    echo $progname $VERSION
    exit 0
fi

T_BOLD=$(tput bold)
T_GREEN=$(tput setaf 2)
T_RED=$(tput setaf 1)
T_RESET=$(tput sgr0)

lockdir=$HOME/.t-task.LOCK
taskdir=$HOME/src/git/task

if test "$1" = "-h" -o "$1" = "--help"; then
    cat <<END

Frontend to task(1) (Taskwarrior) or timew(1) (Timewarrior), depending 
on what the script is called. If the file name of the script is "t", 
call Taskwarrior, if it's "tw", call Timewarrior. Other names result in 
an error.

Commits the result of every command to Git.

Usage: $progname [options] TASK_COMMAND
       $progname --is-active
       $progname angre

Options:

  -h, --help
    Show this help.
  --is-active
    Check that the task repository is marked as active, that the t.active Git 
    config value is set to "true". If it's anything else, the script will abort 
    with exit value 1.
  --version
    Print version information.

"$progname angre" assumes that $taskdir is version controlled by Git and 
will throw away the newest commit. If the repository is modified in any 
way, the operation aborts.

END
    exit 0
fi

myexit() {
    rmdir $lockdir || echo $progname: $lockdir: Cannot remove lockdir >&2
    exit $1
}

cd $taskdir || { echo $progname: $taskdir: Cannot chdir >&2; exit 1; }

if test "$1" = "--is-active"; then
    if test "$(git config --get t.active)" != "true"; then
        echo >&2
        echo "The task repository ($taskdir) is not marked as active," >&2
        echo "set the Git config variable t.active to \"true\"." >&2
        echo >&2
        exit 1
    fi
    exit 0
fi

base="$(basename "$0")"
if test "$base" = "t"; then
    cmd=task
elif test "$base" = "tw"; then
    cmd=timew
else
    echo $progname: $base: Unknown script name, must be \"t\" or \"tw\" >&2
    exit 1
fi

t --is-active || exit 1

mkdir $lockdir || {
    echo $progname: $lockdir: Cannot create lockdir >&2
    exit 1
}
trap "myexit 1" INT TERM

if [ ! -f $taskdir/.taskrc -o ! -d $taskdir/.task ]; then
    echo $progname: Missing files in $taskdir/ >&2
    myexit 1
fi

if [ "$1" = "angre" ]; then
    if [ ! -d .git ]; then
        echo $progname: $taskdir/.git not found >&2
        myexit 1
    fi
    if ! (git-wait-until-clean -e); then
        echo $progname: $taskdir has modifications, aborting >&2
        myexit 1
    fi
    echo -n "$T_BOLD$T_RED"
    GIT_PAGER=cat git log -1 --format='Deleting rev: %h ("%s", %cd)'
    echo -n "$T_RESET"
    git reset --hard HEAD^
    echo -n "$T_BOLD$T_GREEN"
    GIT_PAGER=cat git log -1 --format='New rev: %h ("%s", %cd)'
    echo -n "$T_RESET"
    git dangling
    myexit
fi

$cmd "$@"
oldcommit=$(git rev-parse HEAD)
ciall -d -y -- $cmd "$@" >/tmp/t-output.txt 2>&1 || {
    echo $progname: git commit error >&2
    exit 1
}

$cmd &>/dev/null
ciall -d -y -- Finish previous command >/tmp/t-output-2.txt 2>&1 || {
    echo $progname: git commit 2 error >&2
    exit 1
}
newcommit=$(git rev-parse HEAD)
GIT_PAGER=cat git log --abbrev-commit --format=oneline --decorate=short \
    $oldcommit..$newcommit

myexit 0
