#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""jsonfmt.py

File ID: 423dd854-4a64-11e4-97b1-c80aa9e67bbd
License: GNU General Public License version 2 or later.
Author: Øyvind A. Holm <sunny@sunbase.org>

"""

def main():
    import argparse
    import os

    progname = os.path.basename(__file__)

    parser = argparse.ArgumentParser(
        description='',
        )
    args = parser.parse_args()

if __name__ == "__main__":
    main()
