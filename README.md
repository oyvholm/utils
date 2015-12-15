README for utils.git
====================

This is a collection of scripts I've had in my `~/bin/` directory since 
the previous century. Some of them are quite specific for my own use, 
but many of them have evolved into a mature state and could probably 
have their own repository as their own project. That will probably not 
happen, as most of the scripts consists of only one file.

The `master` branch is considered stable and will never be rebased. 
Every new functionality or bug fix is created on topic branches which 
may be rebased now and then. All tests on `master` (executed with "make 
test") should succeed. If any test fails, it’s considered a bug. Please 
report any failing tests in the issue tracker.

License
-------

Everything here created by Øyvind A. Holm (<sunny@sunbase.org>) is 
licensed under the GNU General Public License version 2 or later.

Download
--------

This repository can be cloned from

- `git@gitlab.com:sunny256/utils.git` / 
  <https://gitlab.com/sunny256/utils.git> (Main repo)
- `git@github.com:sunny256/utils.git`
- `git@bitbucket.org:sunny256/utils.git`
- `ssh://sunny256@repo.or.cz/srv/git/sunny256-utils.git`

The repositories are synced with 
[Gitspread](https://gitlab.com/sunny256/gitspread).

Stable utilities
----------------

These scripts are stable and ready for public use.

### Git extensions

#### git-allbr

Scan remotes for branches and recreate them in the local repository.

#### git-bare

Change the state of the current repository to/from a bare repository 
to/from a regular repository.

#### git-bs

Alias for `git bisect`, but allows execution from a subdirectory.

#### git-dangling

Scan the current repository for dangling heads (dead branches where the 
branch names have been deleted) or tags and create branches with the 
format `commit-SHA1` and `tag-SHA1`. This makes it easy to locate 
branches and tags that shouldn't have been deleted. No need to dig 
around in the reflog anymore. Needs `git-delete-banned`.

#### git-dbr

Delete remote and local branches specified on the command line, but can 
be used with the output from `git log --format=%d` or `%D`. A quick and 
easy way to clean up the branch tree with copy+paste.

#### git-delete-banned

Delete unwanted `commit-SHA1` branches and `tag-SHA1` tags created by 
`git-dangling`. Some people like to keep old branches around after 
they've been squashed or rebased, but there are always some worthless 
branches around that only clutter the history. Those commits can be 
specified in `~/.git-dangling-banned`, and this command will delete 
them.

#### git-delrembr

Delete all remote and local branches specified on the command line.

#### git-fuckit

Throw away one or more commits and execute `git reset --hard` to another 
commit or branch. The tip of the deleted branch is not deleted, but 
marked with a branch name with a similar format to what `git-dangling` 
uses, `commit-SHA1`. Will not run if there are any changes in the 
repository, you'll have to get rid of those first.

#### git-ignore

Ignore files in Git. Automatically update `.gitignore` at the top of the 
repository (default) or add the file, directory or symlink to a local 
`.gitignore` in the current directory. Directories will have a slash 
automatically added, and if the file/directory/symlink already exists in 
Git, it will be removed from the repository without touching the actual 
file.

#### git-logdiff

Show log differences between branches with optional patch.

#### git-mnff

Merge a topic branch without using fast-forward, always create a merge 
commit. This is used for collecting related changes together and makes 
things like `git log --oneline --graph` more readable. IMHO. After the 
branch is merged, it's deleted.

#### git-nocom

Filter output from `git branch` through this to remove `commit-SHA1` 
branches.

#### git-pa

Push to all predefined remotes with a single command.

#### git-rcmd

Execute commands in remote ssh repositories. For example, to make all 
connected ssh repos (if they have a local shell, of course) fetch all 
new commits from all remotes:

    git-rcmd -c "git fetch --all --prune"

#### git-restore-dirs

Restore empty directories from the `.emptydirs` file created by 
`git-store-dirs`.

#### git-rpull

Shortcut for `git rcmd -c "git pull --ff-only"`.

#### git-store-dirs

Store the names of all empty directories in a file called `.emptydirs` 
at the top of the repository. The names are zerobyte-separated to work 
with all kinds of weird characters in the directory names. Use 
`git-restore-dirs` to recreate the directories.

#### git-wait-until-clean

If there are any modifications or unknown files in the current 
repository, wait until it's been cleaned up. Useful in scripts where the 
following commands need a clean repository. Can also ignore unknown 
files or check for the existence of ignored files.

#### git-wip

Useful for working with topic branches. Create subbranches separated 
with a full stop in the branch name. It can create new subbranches, 
merge to parent branches or `master` with or without fast-forward and 
squash the whole branch to the parent branch or `master`.

### Various

#### ampm

Read text from stdin or files and convert from am/pm to 24-hour clock.

#### datefn

Insert, replace or delete UTC timestamp from filenames.

#### dostime

Cripple the file modtime by truncating odd seconds to even. To make life 
easier for rsync and friends if one has to interact with those kinds of 
"file systems".

#### edit-sqlite3

Edit an SQLite 3.x database file in your favourite text editor. The 
original version is backuped with the file modification time in the file 
name as seconds since 1970-01-01 00:00:00 UTC.

#### find\_8bit

Read text from stdin and output all lines with bytes &gt; U+007F.

#### find\_inv\_utf8

Read text from stdin and print all lines containing invalid UTF-8.

#### goal

Print timestamp when a specific goal will be reached. Specify start date 
with value, goal value and current value, and it will print the date and 
time of when the goal will be reached.

#### zeropad

Pad decimal or hecadecimal numbers with zeroes to get equal length.

#### zerosplit

Split contents into files based on separation bytes.

## Stable, but has some limitations

### sort-sqlite

Sort the entries in an SQLite database. Warning: Quite crude, only works 
with databases with single-line entries. A backup of the previous 
version is copied to a \*.bck file containing the date of the file 
modification time in the file name.

## Not described yet

- git-add-missing-gpg-keys
- git-all-blobs
- git-all-repos
- git-allfiles
- git-authoract
- git-context-diff
- git-dl
- git-dobranch
- git-eb
- git-expand
- git-imerge
- git-inv-commits
- git-lc
- git-listbundle
- git-mkrepo
- git-plot
- git-scanrefs
- git-upstream

Create a graph in Gnuplot of the commit activity. Needs `ep`, 
`inc\_epstat` and `stpl`. And Gnuplot, of course.

FIXME: `ep` is in Nårwidsjn.

- git-realclean
- git-remote-hg
- git-repos
- git-safe-rm-remote
- git-savecommit
- git-seq-rebase
- git-size
- git-svn-myclone
- git-trash
- git-tree-size
- git-update-dirs
- git-wn

"git What's New". Create an ASCII representation of all commits that 
contain the current commit. Useful after a `git fetch` to list all new 
commits. Needs `git-lc`.

FIXME: Uses "git lg". Change that to a proper `git log` command or put 
the alias somewhere.

### git diff drivers

- rdbl-garmin-gpi
- rdbl-gpg
- rdbl-gramps-backup
- rdbl-odt
- rdbl-sort\_k5
- rdbl-sqlite3
- rdbl-unzip

### git-annex

- ga
- ga-au
- ga-findkey
- ga-fixnew
- ga-fsck-size
- ga-getnew
- ga-ignore-remote
- ga-key
- ga-other
- ga-repofix
- ga-sjekk
- ga-sumsize
- ga-tree

### Apache logs

- access\_log-date
- access\_log-drops
- access\_log2epstat
- access\_log2tab
- access\_log\_ip

### Other

- 256colors2.pl
- BUGS
- Div
- Git
- Lib
- Local
- Makefile
- Patch
- README.build-git.md
- README.md
- STDexecDTS
- Screen
- TODO
- Tools
- Utv
- access-myf
- ack
- act
- activesvn
- addpoints
- afv
- afv\_move
- afv\_rename
- afvctl
- age
- all-lpar
- allrevs
- annex-cmd
- ascii
- au
- avlytt
- bell
- bigsh
- bom
- bpakk
- bs
- build-git
- build-perl
- build-postgres
- build-vim
- ccc
- cdiff
- cdiffa
- cdiffb
- cdlabel
- center
- cfold
- charconv
- ciall
- cl
- clean\_files
- cleansrc
- cmds
- colourtest
- commify
- commout
- construct\_call\_graph.py
- conv-old-suuid
- convkeyw
- cp1252
- cp865
- create-annex-remotes
- create\_cproject
- create\_imgindex
- create\_new
- create\_svn
- cryptit
- csv2gpx
- cunw
- cutfold
- cvs-rev
- cvscat
- cvse
- cvsrootmd5
- cvsvimdiff
- dass
- date2iso
- dbk
- dbllf
- debugprompt
- deep
- degpg
- denycurrent
- detab
- dings\_it
- dings\_vimtrans
- dir-elems
- doc
- dprofpp.graphviz
- efnhtml
- emptydirs
- enc-mp4
- encap
- encr
- ep
- ep-pause
- ep\_day
- eplog2date
- epstat
- export\_kde\_svn
- extract\_mail
- ferdig
- fibonacci
- fileid
- filenamelower
- filesynced
- filmer
- filt
- filter\_ep
- filtrer\_access\_log
- findbom
- finddup
- findhex
- findrev
- finn\_triton
- firefox
- fix\_filenames
- fix\_mailman
- fixtext
- fjern\_here
- flac\_to\_ogg
- fldb
- fold-stdout
- fra\_linode
- fromdos
- fromhex
- g
- g0
- g1
- gammelsvn
- genpasswd
- geohashing
- getapr
- getpic
- getsvnfiles
- gfuck
- githubnetwork
- gotexp
- gpath
- gpgpakk
- gpsfold
- gpslist
- gpsman2gpx
- gpst
- gpst-file
- gpst-pic
- gptrans\_conv
- gq
- gqfav
- gqview
- grafkjent
- h0
- h1
- h2chin
- h2t
- h2u
- hentfilm
- hf
- hfa
- hhi
- hmsg
- href
- html2cgi
- html2db
- html2wiki
- htmlfold
- httplog
- hub
- hvor
- icat
- icatf
- impnet
- inc\_epstat
- irc-conn
- irssi
- isoname
- ivim
- jsonfmt.py
- kar
- kbd
- keyw
- kl
- klokke
- klokkesig-conv
- konvflac
- kopier\_bilder
- l
- l33t
- lag3d
- lag\_gqv
- lag\_linker
- latlon
- line\_exec.py
- linux-counter-machine-update
- list-extensions
- list-tables
- list-youtube
- livecd-exit
- livecd-init
- ll
- log\_df
- log\_df\_pg
- log\_load
- logg
- logging
- lpar
- ls-broken
- lsreadable
- maileditor
- mailfix
- mailview
- make\_svnlog
- make\_tags
- makemesh
- mangefiler
- manyfiles
- manypatch
- markdown
- mc
- mergesvn
- mime2txt
- mincvs\_vim
- mixline
- mixword
- mkFiles
- mkFiles\_rec
- mk\_local\_links
- mkcvsbck
- mkd
- mklist
- mkrepo
- mkt
- mobilstripp
- mountusb
- mp3\_to\_ogg
- mtube
- multiapt
- mvdirnewest
- myf
- mymkdir
- n0
- n1
- n95film
- netgraph
- nettradio
- nf
- nfs0
- nfs1
- ngttest
- nogit
- nosvn
- ns
- oggname
- old-git
- outl
- p
- pakk
- pakk\_logg
- pakkdir
- pakkings
- pakkut
- perldeboff
- perldebon
- perlfold
- personnr
- pget
- pgsafe
- pine
- pingstat
- plass
- pmsetdate
- po-merge.py
- poiformat
- pols
- posmap
- prearmor
- pri
- primitiv\_prompt
- purgewiki
- push-annex-sunbase
- pynt
- q3r
- r
- radiolagring
- random
- rc.firewall-2.2
- rcs-extract
- remove\_perltestnumbers
- rensk
- repo
- repodiffer
- repofix
- repopuller
- reposurgeon
- reset
- rm\_backup
- rmdup
- rmheadtail
- rmspc
- rmspcall
- rmspcbak
- rmspcforan
- rmxmlcomm
- rot13
- roundgpx
- runtest
- scrdump
- scrplay
- sea-repo
- sess
- sget
- shellshock
- sident
- sj
- sjekk\_iso
- sjekkhtmlindent
- sjekkrand
- sjekksommer
- skipline
- skiptoplines
- skjermhoyde
- slekt
- slogg
- smsum
- snu\_epstat
- sommer
- sortcvs
- sortxml
- split\_access\_log
- split\_ep-logg
- split\_log
- split\_md5
- spreadsheet
- src
- ssht
- sssh
- statgits
- statplot
- std
- still\_klokka
- storelog
- stpl
- stq
- strip-conflict
- strip-nonexisting
- strip\_english
- strip\_msgstr
- sub-mergesvn
- sumdup
- sums
- sunnyrights
- suntodofold
- suuid
- svedit
- svi
- svn-po
- svnclean
- svncvsrevs
- svndiff
- svnfiledate
- svnlog2tab
- svnrevs
- svnsize
- svnstat
- svup
- t
- t2h
- ta\_backup
- tab
- tail-errorlog
- tarsize
- telenorsms
- termtitle
- testfail
- tests
- til-ov
- tilgps
- tmux\_local\_install.sh
- todos
- togpx
- tohex
- tojson
- tolower
- tosec
- towav
- txt2uc
- txtfold
- u
- u2h
- uc
- uh2dec
- uj
- unichar
- unicode\_htmlchart
- unik\_df
- unz
- uoversatt
- upd
- update\_vim-clean
- urlstrip
- urm
- usedchars
- ustr
- utc
- v
- vd
- vekt
- vg
- view\_df
- vx
- vy
- wav\_to\_flac
- wav\_to\_mp3
- wavto16
- wdiff
- wdisk
- wikipedia-export
- wlan-list
- wlan0
- wlan1
- wn
- wpt-dupdesc
- wpt-line
- wpt-rmsym
- xf
- xml-to-lisp
- xml2html
- xmlformat
- xmlstrip
- xt
- yd
- ydd
- youtube-dl
- zero-to-lf

----

    File ID: a8487d1c-1c4f-11e5-b5a1-398b4cddfd2b
    vim: set ts=2 sw=2 sts=2 tw=72 et fo=tcqw fenc=utf8 :
    vim: set com=b\:#,fb\:-,fb\:*,n\:> ft=markdown :
