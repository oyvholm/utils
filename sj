#!/bin/sh

# File ID: 29dba898-4962-11df-adc3-d5e071bed206

free_space() {
    df --block-size=1M "$1" | commify | grep /dev/ | tr -s ' ' | cut -f 4 -d ' ' | tr -d '\n'
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
    while :; do
        all_free_space
        sleep 5
    done
elif test "$1" = "date"; then
    ntpdate -q pool.ntp.org
elif test "$1" = "kern"; then
    tail -F /var/log/kern.log
elif test "$1" = "space"; then
    while :; do
        free_space .
        sleep 1
        echo -n '  '
    done
else
    test -d /n900/. && sudo=sudo || unset sudo
    while :; do
        $sudo ping 178.79.142.16
        sleep 1
        echo ============================================
    done
fi
