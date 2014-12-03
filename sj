#!/bin/sh

# File ID: 29dba898-4962-11df-adc3-d5e071bed206

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
    tail -F /var/log/kern.log
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
