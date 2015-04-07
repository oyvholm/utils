#!/bin/bash

#=======================================================================
# mc
# File ID: 6dbf2f84-f7c0-11e2-9a3f-001f3b596ec9
# [Description]
# License: GNU General Public License version 3 or later.
#=======================================================================

sess_str="sess -d mc -t c_mc --"
test "$HISTFILE" = "/dev/null" && unset sess_str
if test -x ~/local/bin/mc; then
    $sess_str ~/local/bin/mc -d -u "$@"
elif test -x /usr/local/bin/mc; then
    $sess_str /usr/local/bin/mc -d -u "$@"
elif test -x /usr/bin/mc; then
    $sess_str /usr/bin/mc -d -u "$@"
else
    echo mc is not installed here. >&2
    exit 1
fi
