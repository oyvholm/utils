#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""jsonfmt.py - JSON formatter

File ID: 423dd854-4a64-11e4-97b1-c80aa9e67bbd
License: GNU General Public License version 2 or later.
Author: Øyvind A. Holm <sunny@sunbase.org>

"""

def format_json(text, indent=4):
    """Return formatted JSON"""
    import json

    return json.dumps(
        json.loads(text),
        ensure_ascii=False,
        indent=indent,
        sort_keys=True,
        )

def main():
    import argparse
    import os
    import sys

    progname = os.path.basename(__file__)

    parser = argparse.ArgumentParser(
        description='JSON formatter',
        )
    parser.add_argument(
        '-i', '--indent',
        default=4,
        help='Use X spaces as indent',
        metavar='X',
        type=int,
        )
    args = parser.parse_args()

    try:
        print(format_json(''.join(sys.stdin.readlines()), indent=args.indent))
    except ValueError:
        sys.stderr.write("%s: Invalid JSON\n" % progname)

if __name__ == "__main__":
    main()
