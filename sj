#!/bin/sh

# File ID: 29dba898-4962-11df-adc3-d5e071bed206

test -d /n900/. && sudo=sudo || unset sudo
while :; do
    $sudo ping 193.212.1.10
    sleep 1
    echo ============================================
done
