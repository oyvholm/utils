#!/bin/sh

#=======================================================================
# mc
# File ID: 7f03fa78-5d3f-11df-bc19-90e6ba3022ac
# Midlertidig wrapper som slår av subshell support, Midnight Commander 
# er så usannsynlig treig når det brukes. Det er ikke bra.
#=======================================================================

/usr/bin/mc -u "$@"
