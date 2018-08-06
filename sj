#!/usr/bin/env bash

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
VERSION=0.8.4

ARGS="$(getopt -o "\
h\
q\
v\
" -l "\
help,\
maxtemp:,\
quiet,\
space:,\
verbose,\
version,\
" -n "$progname" -- "$@")"
test "$?" = "0" || exit 1
eval set -- "$ARGS"

std_maxtemp=94

opt_help=0
opt_maxtemp=$std_maxtemp
opt_quiet=0
opt_space='0'
opt_verbose=0
while :; do
    case "$1" in
        -h|--help) opt_help=1; shift ;;
        --maxtemp) opt_maxtemp=$2; shift 2 ;;
        -q|--quiet) opt_quiet=$(($opt_quiet + 1)); shift ;;
        --space) opt_space=$2; shift 2 ;;
        -v|--verbose) opt_verbose=$(($opt_verbose + 1)); shift ;;
        --version) echo $progname $VERSION; exit 0 ;;
        --) shift; break ;;
        *) echo $progname: Internal error >&2; exit 1 ;;
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
  --maxtemp NUM
    Define maximum acceptable temperature for "$progname temp-warn".
    Default value: $std_maxtemp
  -q, --quiet
    Be more quiet. Can be repeated to increase silence.
  --space BYTES
    When used with "dfull":
      Estimate time until the free disk space reaches BYTES. This value 
      is parsed by numfmt(1) from GNU coreutils, check the man page for 
      allowed values. Examples: 10M = 10000000, 10Mi = 10485760.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.

If no command is specified, it checks that the network is up by issuing 
a ping command until interrupted. These commands are also available:

  allspace
    Display free space of all local disks every 2nd second until 
    interrupted.
  date
    Run a query against pool.ntp.org to see how accurate the system 
    clock is.
  dfull
    Display estimated time until the current disk is full based on the 
    disk usage since the script was started.
  df
    Display free space of all local disks, sorted by free space.
  kern
    Follow the kernel log and display new entries immediately when they 
    occur.
  space
    Display free space of the current disk every second until 
    interrupted.
  temp
    Display current temperature.
  temp-warn, tw
    Loop and check CPU temperature. If it gets too high, create an 
    xmessage(1) window and send a warning to stderr.

END
    exit 0
fi

space_val="$(numfmt --from=auto -- $opt_space)"
test -z "$space_val" && {
    echo "$progname: Invalid value in --space argument" >&2
    exit 1
}
test $opt_verbose -ge 1 &&
    echo "$progname: Using --space $space_val" >&2

free_space() {
    df -h --si "$1" -P | tail -1 | tr -s ' ' | cut -f 4 -d ' ' | tr -d '\n'
}

free_space_bytes() {
    df -B 1 "$1" -P | tail -1 | tr -s ' ' | cut -f 4 -d ' ' | tr -d '\n'
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
        if test "$curr" != "$prev"; then
            echo
            echo -n "$(date +"%d %H:%M:%S")  $curr$(tput el)"
        fi
        prev="$curr"
        sleep 2
    done
elif test "$1" = "date"; then
    ntpdate -q pool.ntp.org
elif test "$1" = "df"; then
    df -h --si | grep ^Filesystem
    df -h --si --total | grep -e /dev/ -e ^total | sort -h -k4
elif test "$1" = "dfull"; then
    origsec=$(date +%s)
    origtime="$(date -u +"%Y-%m-%d %H:%M:%S.%N")"
    origdf=$(( $(free_space_bytes .) - $space_val ))
    prevdf=$origdf
    ml_goalint=14
    ml_goaltime=9
    ml_dfdiff=1
    while :; do
        currtime="$(date -u +"%Y-%m-%d %H:%M:%S.%N")"
        currsec=$(date +%s)
        currdf=$(( $(free_space_bytes .) - $space_val ))
        goal_output="$(
            goal "$origtime" "$origdf" 0 "$currdf" 2>/dev/null
        )"
        dfdiff="$(( $currdf-$origdf ))"
        goalint=$(echo $goal_output | awk '{print $1}' | sed 's/\..*//')
        goaldate=$(echo $goal_output | awk '{print $2}')
        goaltime=$(echo $goal_output | awk '{print $3}' | sed 's/\..*//')
        cl_goalint=$(echo $goalint | wc -L)
        cl_goaltime=$(echo $goaltime | wc -L)
        cl_dfdiff=$(echo $dfdiff | commify | wc -L)
        seconds=$(echo $currsec-$origsec | bc)

        test $cl_goalint -gt $ml_goalint && ml_goalint=$cl_goalint
        test $cl_goaltime -gt $ml_goaltime && ml_goaltime=$cl_goaltime
        test $cl_dfdiff -gt $ml_dfdiff && ml_dfdiff=$cl_dfdiff

        if test "$(echo "$currdf < $prevdf" | bc)" = "1"; then
            t_diskfree="$(tput bold; tput setaf 1)"
            t_diskfree_reset="$(tput sgr0)"
        elif test "$(echo "$currdf > $prevdf" | bc)" = "1"; then
            t_diskfree="$(tput bold; tput setaf 2)"
            t_diskfree_reset="$(tput sgr0)"
        else
            t_diskfree=""
            t_diskfree_reset=""
        fi

        if test -n "$goal_output"; then
            printf \
"\\n"\
"%-${ml_goalint}s "\
"%s "\
"%-${ml_goaltime}s "\
"diff: %s%-${ml_dfdiff}s%s  "\
"free: %s%s%s"\
"%s "\
"%s"\
                "$goalint" \
                "$goaldate" \
                "$goaltime" \
                "$t_diskfree" \
                "$(echo $dfdiff | commify)" \
                "$t_diskfree_reset" \
                "$t_diskfree" \
                "$(echo $currdf | commify)" \
                "$t_diskfree_reset" \
                "$(tput el)" \
                "$(
                    if test $seconds -gt 0; then
                        printf " %s B/s" $(
                            printf 'scale=0; %d/%u\n' $dfdiff $seconds |
                                bc | commify
                        )
                    fi
                )"
        else
            printf "\\n$progname dfull: No changes yet, %s%s%s bytes free%s" \
                "$t_diskfree" \
                "$(echo $currdf | commify)" \
                "$t_diskfree_reset" \
                "$(tput el)"
        fi
        prevdf=$currdf
        sleep 2
    done
elif test "$1" = "kern"; then
    tail -Fq /var/log/kern.log /var/log/syslog /var/log/auth.log
elif test "$1" = "space"; then
    unset prevlast
    while :; do
        lastspace=$(free_space .)
        if test "$lastspace" != "$prevlast"; then
            echo -n " $lastspace $(tput el)"
            prevlast=$lastspace
        fi
        sleep 1
    done
elif test "$1" = "temp"; then
    temperature_file=/sys/devices/virtual/thermal/thermal_zone0/temp
    if test ! -e "$temperature_file"; then
        echo $progname: $temperature_file: File not found >&2
        echo $progname: Cannot read temperature >&2
        exit 1
    fi
    (
        echo scale=1
        echo -n $(cat "$temperature_file")
        echo / 1000
    ) | bc -l
elif test "$1" = "temp-warn" -o "$1" = "tw"; then
    unset prevtemp
    dispfile="/tmp/sj_tw.$(date +%s).$$.tmp"
    if test -e "$dispfile"; then
        echo $progname: $dispfile: Tempfile already exists, that\'s spooky >&2
        exit 1
    fi
    while :; do
        currtemp="$($progname temp)"
        if test -z "$currtemp"; then
            echo -n "$progname: Unable to read temperature, " >&2
            echo \"$progname temp\" returned nothing >&2
            exit 1
        fi
        if test "$currtemp" != "$prevtemp"; then
            echo $(date -u +"%Y-%m-%dT%H:%M:%SZ") $currtemp >>~/log/temp.log
            echo -n " $currtemp $(tput el)"
            prevtemp=$currtemp
        fi
        if test $(echo "$currtemp > $opt_maxtemp" | bc) = "1"; then
            grep Blimey "$dispfile" 2>/dev/null | grep -q . && rm "$dispfile"
            if test ! -e $dispfile; then
                warning="Oi! The temperature is $currtemp!"
                xmessage -button Blimey -print "$warning" >"$dispfile" &
                (
                    echo
                    tput setab 1
                    tput bold
                    tput setaf 3
                    echo -n "$progname: $warning"
                    tput sgr0
                    echo -n " "
                    tput el
                ) >&2
            fi
        fi
        sleep 2
    done
else
    test -d /n900/. && sudo=sudo || unset sudo
    while :; do
        $sudo ping 178.79.142.16
        sleep 1
        echo ============================================
    done
fi
