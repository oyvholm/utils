#!/bin/bash

# $Id$

gptrans_conv -o ygraph "$@" | ygraph -l0 -
