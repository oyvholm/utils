#!/bin/bash

#=======================================================================
# $Id$
# File ID: 797f5e70-fa63-11dd-9838-000475e441b9
# Kaller opp Vim.
# License: GNU General Public License version 2 or later.
#=======================================================================

uuid=`suuid -t c_v -w eo -c "v $*"`
vim "$@"
suuid -t c_v -c "Session $uuid ferdig."
