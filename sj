#!/bin/bash

#=======================================================================
# sj
# File ID: 29dba898-4962-11df-adc3-d5e071bed206
#
# Shortcut to check various stuff.
#
# Author: Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later.
#=======================================================================

progname=sj
VERSION=0.1.0

ARGS="$(getopt -o "hqv" -l "help,quiet,verbose,version" \
    -n "$progname" -- "$@")"
test "$?" = "0" || exit 1
eval set -- "$ARGS"

opt_quiet=0
opt_verbose=0
while :; do
    case "$1" in
        (-h|--help) opt_help=1; shift ;;
        (-q|--quiet) opt_quiet=$(($opt_quiet + 1)); shift ;;
        (-v|--verbose) opt_verbose=$(($opt_verbose + 1)); shift ;;
        (--version) echo $progname $VERSION; exit 0 ;;
        (--) shift; break ;;
        (*) echo $progname: Internal error >&2; exit 1 ;;
    esac
done
opt_verbose=$(($opt_verbose - $opt_quiet))

if test "$opt_help" = "1"; then
    test $opt_verbose -gt 0 && { echo; echo $progname $VERSION; }
    cat <<END

Usage: $progname [options] [command]

Options:

  -h, --help
    Show this help.
  -q, --quiet
    Be more quiet. Can be repeated to increase silence.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.

If no command is specified, it checks that the network is up by issuing 
a ping command until interrupted. These commands are also available:

  allspace
    Display free space of all local disks every 2nd second until interrupted.
  date
    Run a query against pool.ntp.org to see how accurate the system clock is.
  df
    Display free space of all local disks, sorted by free space.
  kern
    Follow the kernel log and display new entries immediately when they occur.
  space
    Display free space of the current disk every second until interrupted.

END
    exit 0
fi

free_space() {
    df -h "$1" | grep /dev/ | tr -s ' ' | cut -f 4 -d ' ' | tr -d '\n'
}

all_free_space() {
    mount | grep ^/dev/ | cut -f 3 -d ' ' | sort | while read f; do
        if test "$f" = "/"; then
            echo -n "/ ";
            free_space /
        else
            echo "$f " | rev | cut -f 1 -d / | rev | tr -d '\n'
            free_space "$f"
        fi
        echo -n "  "
    done
    echo
}

if test "$1" = "allspace"; then
    unset prev
    while :; do
        curr="$(all_free_space)"
        test "$curr" != "$prev" && (echo; echo -n "$curr")
        prev="$curr"
        sleep 2
    done
elif test "$1" = "date"; then
    ntpdate -q pool.ntp.org
elif test "$1" = "df"; then
    df -h | grep ^Filesystem
    df -h --total | grep -e /dev/ -e ^total | sort -h -k4
elif test "$1" = "kern"; then
    tail -F /var/log/kern.log /var/log/syslog
elif test "$1" = "space"; then
    unset prevlast
    while :; do
        lastspace=$(free_space .)
        if test "$lastspace" != "$prevlast"; then
            echo -n $lastspace
            echo -n '  '
            prevlast=$lastspace
        fi
        sleep 1
    done
else
    test -d /n900/. && sudo=sudo || unset sudo
    while :; do
        $sudo ping 178.79.142.16
        sleep 1
        echo ============================================
    done
fi
