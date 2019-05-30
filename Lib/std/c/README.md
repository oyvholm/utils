# README for STDexecDTS.git

## Status

In the startup/design phase, does nothing yet.

## Development

The `master` branch is considered stable, no unstable development
happens there. Every new functionality or bug fix is created on topic
branches which may be rebased now and then. All tests on `master`
(executed with "make test") should succeed. If any test fails, it's
considered a bug. Please report any failing tests in the issue tracker.

To ensure compatibility between versions, the program follows the
Semantic Versioning Specification described at <http://semver.org>.
Using the version number `X.Y.Z` as an example:

  - `X` is the *major version*. This number is only incremented when
    backwards-incompatible changes are introduced.
  - `Y` is the *minor version*. Increased when new backwards-compatible
    features are added.
  - `Z` is the *patch level*. Increased when new backwards-compatible
    bugfixes are added.

## `make` commands

### make / make all

Generate the `STDexecDTS` executable.

### make clean

Remove all generated files except `tags`.

### make edit

Open all files in the subtree in your favourite editor defined in
`EDITOR`.

### make gcov

Generate test coverage with `gcov`(1). Must be as close to 100% as
possible.

### make gcov-cmt / make gcov-cmt-clean

Add or remove `gcov` markers in the source code in lines that are not
tested. Lines that are hard to test, for example full disk, full memory,
long paths and so on, can be marked with the string `/* gncov */` to
avoid marking them. To mark lines even when marked with gncov, set the
GNCOV environment variable to a non-empty value. For example:

    make gcov-cmt GNCOV=1

These commands need the `gcov-cmt` script, available from
<https://gitlab.com/sunny256/utils/raw/master/gcov-cmt>.

### make gdb

Start gdb with main() as the default breakpoint, this is defined in
`src/gdbrc`. Any additional gdb options can be added in `src/gdbopts`.
An example would be "-tty /dev/\[...\]" to send the program output to
another window.

### make install

`make install` installs `STDexecDTS` to the location defined by `PREFIX`
in `src/Makefile`. Default location is `/usr/local/bin/`, but it can be
installed somewhere else by specifying `PREFIX`. For example:

    make install PREFIX=~/local

### make tags

Generate `tags` file, used by Vim and other editors.

### make test

Run all tests. This command must never fail on purpose on `master`.

### make uninstall

Delete the installed version from `PREFIX`.

### make valgrind

Run all tests with Valgrind to find memory leaks and other problems.
Should also not fail on master.

## Download

The main Git repository is stored at GitLab:

  - URL: <https://gitlab.com/sunny256/STDexecDTS>
  - SSH clone: git@gitlab.com:sunny256/STDexecDTS.git
  - https clone: <https://gitlab.com/sunny256/STDexecDTS.git>

## License

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along
with this program. If not, see <http://www.gnu.org/licenses/>.

## Author

Øyvind A. Holm \<<sunny@sunbase.org>\>

-----

    File ID: STDuuidDTS
    vim: set ts=2 sw=2 sts=2 tw=72 et fo=tcqw fenc=utf8 :
    vim: set com=b\:#,fb\:-,fb\:*,n\:> ft=markdown :
