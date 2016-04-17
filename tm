#!/bin/bash

#=======================================================================
# tm
# File ID: 857031fc-049f-11e6-a354-02010e0a6634
#
# Wrapper around timidity(1) to get rid of 16-bit noise
#=======================================================================

progname=tm

timidity --output-24bit "$@"
