#!/bin/bash

#=======================================================================
# t
# File ID: e2469b62-dc83-11e0-9dfc-9f1b7346cb92
# Shortcut to task(1) and commit changes to Git
# License: GNU General Public License version 3 or later.
#=======================================================================

task "$@"
cd ~/src/git/task || { echo t: Cannot chdir >&2; exit 1; }
yes | ciall -d t "$@" >/dev/null 2>&1
