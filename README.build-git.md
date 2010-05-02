README for `build-git`
======================

This bash script builds, tests and installs the newest version of Git, 
fetched from the master branch in the Git repository. Git is installed 
under `/usr/local/varprg/`_version_ by default, and creates symlinks in 
`/usr/local/prg/`, `/usr/local/bin/` and `/usr/local/share/man/` to the 
installed version. This makes it easy to revert to another version for 
testing. These defaults can be changed by changing variables in the 
beginning of the script. Written with paranoia in mind and aborts on 
every little error.

Dependencies
------------

The script uses the default `Makefile`, and needs the following packages 
(Ubuntu/Debian, other distros may vary):

- GNU make
  - Package: `make`

- GNU C Copiler
  - Package: `gcc`

- GNU gettext
  - Package: `gettext`

- curl-config
  - Package: `libcurl4-openssl-dev`

- expat
  - Package: `libexpat1-dev`

- AsciiDoc
  - Package: `asciidoc`

- DocBook conversion utility
  - Package: `docbook2x`

- OpenSSL
  - Package: `libssl-dev`
  - Package: `openssl`

### Not essential, but nice to have

- Tk toolkit for Tcl and X11
  - Necessary to run gitk(1)
  - Package: `tk`

- Subversion
  - Necessary for use with git-svn
  - Package: `subversion`

---

    f741de12-b199-11de-8dec-00248cd5cf1e
    vim: set ts=2 sw=2 sts=2 tw=72 et fo=tcqw fenc=utf8 :
    vim: set com=b\:#,fb\:-,fb\:*,n\:> ft=markdown :
