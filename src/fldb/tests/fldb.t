#!/usr/bin/env perl

#=======================================================================
# tests/fldb.t
# File ID: 393bb6d2-f9f1-11dd-8b2b-000475e441b9
# Test suite for fldb(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    push(@INC, "$ENV{'HOME'}/bin/src/fldb");
    use Test::More qw{no_plan};
    use_ok('FLDBpg');
    use_ok('FLDBsum');
    use_ok('FLDButf');
}

use Getopt::Long;

local $| = 1;

our $Debug = 0;
our $CMD = '../fldb';

our %Opt = (

    'all' => 0,
    'debug' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.1.0';

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'debug' => \$Opt{'debug'},
    'help|h' => \$Opt{'help'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

diag(sprintf('========== Executing %s v%s ==========',
    $progname,
    $VERSION));

if ($Opt{'todo'} && !$Opt{'all'}) {
    goto todo_section;
}

=pod

testcmd("$CMD command", # {{{
    <<'END',
[expected stdin]
END
    "",
    0,
    "description",
);

# }}}

=cut

diag('Testing -h (--help) option...');
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    0,
    'Option -h prints help screen',
);

# }}}
diag('Testing -v (--verbose) option...');
likecmd("$CMD -hv", # {{{
    '/^\n\S+ \d\.\d+\.\d+/s',
    '/^$/',
    0,
    'Option --version with -h returns version number and help screen',
);

# }}}
diag('Testing --version option...');
likecmd("$CMD --version", # {{{
    '/^\S+ \d\.\d+\.\d+/s',
    '/^$/',
    0,
    'Option --version returns version number',
);

diag("Testing return values...");
likecmd("perl -e 'exit(0)'", '/^$/', '/^$/', 0, "likecmd(): return 0");
likecmd("perl -e 'exit(1)'", '/^$/', '/^$/', 1, "likecmd(): return 1");
likecmd("perl -e 'exit(255)'", '/^$/', '/^$/', 255, "likecmd(): return 255");
testcmd("perl -e 'exit(0)'", '', '', 0, "testcmd(): return 0");
testcmd("perl -e 'exit(1)'", '', '', 1, "testcmd(): return 1");
testcmd("perl -e 'exit(255)'", '', '', 255, "testcmd(): return 255");

# }}}
chdir('files') or die("$progname: files: Cannot chdir(): $!\n");
likecmd('tar xzf dir1.tar.gz', # {{{
    '/^$/',
    '/.*/',
    0,
    "Extract dir1.tar.gz",
);

# }}}
chdir('..') or die("$progname: ..: Cannot chdir(): $!\n");

diag("Testing safe_sql()...");
is(safe_sql(""), # {{{
    "",
    'safe_sql("") - Empty string'
);

# }}}
is(safe_sql("abc"), # {{{
    "abc",
    'safe_sql("abc") - Regular ASCII'
);

# }}}
is(safe_sql("'"), # {{{
    "''",
    'safe_sql("\'") - Apostrophe'
);

# }}}
is(safe_sql("\t\n\r"), # {{{
    "\\t\\n\\r",
    'safe_sql("\\t\\n\\r") - TAB, LF and CR'
);

# }}}
is(safe_sql("æ☺’"), # {{{
    "æ☺’",
    'safe_sql("abc") - UTF-8'
);

# }}}
is(safe_sql("a\0b"), # {{{
    "a\0b",
    'safe_sql("a\\0b") - Null byte'
);

# }}}
is(safe_sql("\xF8"), # {{{
    "\xF8", # FIXME: Is this OK? It will never happen.
    'safe_sql("\\xF8") - Invalid UTF-8'
);

# }}}
# diag("Testing checksum()...");
diag("Testing valid_utf8()...");
is(valid_utf8(""), # {{{
    1,
    'valid_utf8("") - Empty string'
);

# }}}
is(valid_utf8("abc"), # {{{
    1,
    'valid_utf8("abc") - Regular ASCII'
);

# }}}
is(valid_utf8("æ©☺"), # {{{
    1,
    'valid_utf8("æ©☺") - Valid UTF-8'
);

# }}}
is(valid_utf8("\xF8"), # {{{
    0,
    'valid_utf8("\\xF8") - Invalid UTF-8'
);

# }}}
# is(valid_utf8(""), # {{{
#     "",
#     'valid_utf8("")'
# );

# }}}
diag("Testing widechar()...");
diag("Testing latin1_to_utf8()...");
diag("Testing -d (--description) option...");
testcmd("$CMD -d Groovy -s files/dir1/random_2048", # {{{
    <<END,
INSERT INTO files (
 sha256, sha1, gitsum, md5, crc32,
 size, filename, mtime, perm,
 descr,
 latin1
) VALUES (
 '7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034', 'bd91a93ca0462da03f2665a236d7968b0fd9455d', 'ddf7d5a5e7a7b493368c2761faddb20a58bfbd59', '4a3074b2aae565f8558b7ea707ca48d2', NULL,
 2048, E'random_2048', '2008-09-22T00:18:37Z', '0644',
 E'Groovy',
 FALSE
);
END
    "",
    0,
    "Output SQL with description",
);

# }}}
testcmd("$CMD -d Yess -x files/dir1/random_2048", # {{{
    <<END,
<fldb>
<file> <size>2048</size> <sha256>7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034</sha256> <sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d</sha1> <gitsum>ddf7d5a5e7a7b493368c2761faddb20a58bfbd59</gitsum> <md5>4a3074b2aae565f8558b7ea707ca48d2</md5> <filename>files/dir1/random_2048</filename> <mtime>2008-09-22T00:18:37Z</mtime> <perm>0644</perm> <descr>Yess</descr> </file>
</fldb>
END
    "",
    0,
    "Output short XML from random_2048 with description and mtime",
);

# }}}
testcmd("$CMD --sql -d \"This is a description with spaces\" files/dir1/random_2048", # {{{
    <<END,
INSERT INTO files (
 sha256, sha1, gitsum, md5, crc32,
 size, filename, mtime, perm,
 descr,
 latin1
) VALUES (
 '7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034', 'bd91a93ca0462da03f2665a236d7968b0fd9455d', 'ddf7d5a5e7a7b493368c2761faddb20a58bfbd59', '4a3074b2aae565f8558b7ea707ca48d2', NULL,
 2048, E'random_2048', '2008-09-22T00:18:37Z', '0644',
 E'This is a description with spaces',
 FALSE
);
END
    "",
    0,
    "Output SQL with description with space and apos",
);

# }}}
testcmd("$CMD -d \"Somewhat & weird < > yepp\" -x files/dir1/random_2048", # {{{
    <<END,
<fldb>
<file> <size>2048</size> <sha256>7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034</sha256> <sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d</sha1> <gitsum>ddf7d5a5e7a7b493368c2761faddb20a58bfbd59</gitsum> <md5>4a3074b2aae565f8558b7ea707ca48d2</md5> <filename>files/dir1/random_2048</filename> <mtime>2008-09-22T00:18:37Z</mtime> <perm>0644</perm> <descr>Somewhat &amp; weird &lt; &gt; yepp</descr> </file>
</fldb>
END
    "",
    0,
    "Output short XML from random_2048 with weird description and mtime",
);

# }}}
likecmd("$CMD -sl files/dir1/random_2048", # {{{
    '/^INSERT INTO files \(\n' .
        ' sha256, sha1, gitsum, md5, crc32,\n' .
        ' size, filename, mtime, perm, descr, ctime,\n' .
        ' path,\n' .
        ' inode, links, device, hostname,\n' .
        ' uid, gid,\n' .
        ' lastver, nextver,\n' .
        ' latin1\n' .
        '\) VALUES \(\n' .
        ' \'7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034\', \'bd91a93ca0462da03f2665a236d7968b0fd9455d\', \'ddf7d5a5e7a7b493368c2761faddb20a58bfbd59\', \'4a3074b2aae565f8558b7ea707ca48d2\', NULL,\n' .
        ' 2048, E\'random_2048\', \'2008-09-22T00:18:37Z\', \'0644\', NULL, \'\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ\',\n' .
        ' E\'files\/dir1\/random_2048\',\n' .
        ' \d+, 1, E\'\d+\', E\'.+\',\n' .
        ' \d+, \d+,\n' .
        ' NULL, NULL,\n' .
        ' FALSE\n' .
        '\);\n' .
        '$/',
    '/^$/',
    0,
    "Output SQL from random_2048",
);

# }}}
diag("Testing -f (--files-from) option...");
testcmd("$CMD -f files/allfiles.txt", # {{{
    <<END,
{
 "files":{
  "files/dir1/empty":{"size":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","sha1":"da39a3ee5e6b4b0d3255bfef95601890afd80709","gitsum":"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391","md5":"d41d8cd98f00b204e9800998ecf8427e","mtime":"2008-09-22T00:10:24Z","perm":"0644"},
  "files/dir1/random_2048":{"size":2048,"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034","sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d","gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59","md5":"4a3074b2aae565f8558b7ea707ca48d2","mtime":"2008-09-22T00:18:37Z","perm":"0644"},
  "files/dir1/random_333":{"size":333,"sha256":"69fd85e4544d4057edb8954d77dfce2b2ded8177b889a4512a7456caf1a2e78b","sha1":"1fffb088a74a48447ee612dcab91dacae86570ad","gitsum":"935633dc1238e064bf841e02b1a9128d75348ffd","md5":"af6888a81369b7a1ecfbaf14791c5552","mtime":"2008-09-22T00:10:06Z","perm":"0644"},
  "files/dir1/textfile":{"size":43,"sha256":"7dcd877deb276541bc439e639b2838099406f56ec2d8337da27abab986bfcc50","sha1":"c70053a7b8f6276ff22181364430e729c7f42c5a","gitsum":"d31c8dc43d0efce334ee8099be772347eba54002","md5":"96319d5ea553d5e39fd9c843759d3175","mtime":"2008-09-22T00:09:38Z","perm":"0644"},
  "files/dir1/year_1969":{"size":41,"sha256":"81fae0df95efba03969fe59e7bbcbc94ed6448276c64770f2b5fab5d64a8932d","sha1":"07b8074463668967f6030016d719ef326eb6382d","gitsum":"fe008e59667b2eb0848d9092f4eceac8725a162b","md5":"6dce58e78b13dab939de6eef142b7543","mtime":"1969-01-21T17:12:15Z","perm":"0644"},
  "files/dir1/year_2038":{"size":41,"sha256":"0d048aa5dedb88a9198874f8fcf60ac1eaca7365217e074e798f2d5fa03f561b","sha1":"2113343435a9aadb458d576396d4f960071f8efd","gitsum":"052a58773edb46b2d494a23718cac040fb38c741","md5":"6babaa47123f4f94ae59ed581a65090b","mtime":"2038-01-19T03:14:07Z","perm":"0644"}
 }
}
END
    "fldb: files/dir1: Ignoring non-file\n" .
    "fldb: files/dir1/chmod_0000: Cannot read file: Permission denied\n",
    0,
    "Output short JSON of all files",
);

# }}}
testcmd("cat files/allfiles.txt | $CMD -f -", # {{{
    <<END,
{
 "files":{
  "files/dir1/empty":{"size":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","sha1":"da39a3ee5e6b4b0d3255bfef95601890afd80709","gitsum":"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391","md5":"d41d8cd98f00b204e9800998ecf8427e","mtime":"2008-09-22T00:10:24Z","perm":"0644"},
  "files/dir1/random_2048":{"size":2048,"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034","sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d","gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59","md5":"4a3074b2aae565f8558b7ea707ca48d2","mtime":"2008-09-22T00:18:37Z","perm":"0644"},
  "files/dir1/random_333":{"size":333,"sha256":"69fd85e4544d4057edb8954d77dfce2b2ded8177b889a4512a7456caf1a2e78b","sha1":"1fffb088a74a48447ee612dcab91dacae86570ad","gitsum":"935633dc1238e064bf841e02b1a9128d75348ffd","md5":"af6888a81369b7a1ecfbaf14791c5552","mtime":"2008-09-22T00:10:06Z","perm":"0644"},
  "files/dir1/textfile":{"size":43,"sha256":"7dcd877deb276541bc439e639b2838099406f56ec2d8337da27abab986bfcc50","sha1":"c70053a7b8f6276ff22181364430e729c7f42c5a","gitsum":"d31c8dc43d0efce334ee8099be772347eba54002","md5":"96319d5ea553d5e39fd9c843759d3175","mtime":"2008-09-22T00:09:38Z","perm":"0644"},
  "files/dir1/year_1969":{"size":41,"sha256":"81fae0df95efba03969fe59e7bbcbc94ed6448276c64770f2b5fab5d64a8932d","sha1":"07b8074463668967f6030016d719ef326eb6382d","gitsum":"fe008e59667b2eb0848d9092f4eceac8725a162b","md5":"6dce58e78b13dab939de6eef142b7543","mtime":"1969-01-21T17:12:15Z","perm":"0644"},
  "files/dir1/year_2038":{"size":41,"sha256":"0d048aa5dedb88a9198874f8fcf60ac1eaca7365217e074e798f2d5fa03f561b","sha1":"2113343435a9aadb458d576396d4f960071f8efd","gitsum":"052a58773edb46b2d494a23718cac040fb38c741","md5":"6babaa47123f4f94ae59ed581a65090b","mtime":"2038-01-19T03:14:07Z","perm":"0644"}
 }
}
END
    "fldb: files/dir1: Ignoring non-file\n" .
    "fldb: files/dir1/chmod_0000: Cannot read file: Permission denied\n",
    0,
    "Read file list from stdin",
);

# }}}
testcmd("cat files/allfiles.txt | tr '\\n' '\\0' | $CMD -zf -", # {{{
    <<END,
{
 "files":{
  "files/dir1/empty":{"size":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","sha1":"da39a3ee5e6b4b0d3255bfef95601890afd80709","gitsum":"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391","md5":"d41d8cd98f00b204e9800998ecf8427e","mtime":"2008-09-22T00:10:24Z","perm":"0644"},
  "files/dir1/random_2048":{"size":2048,"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034","sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d","gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59","md5":"4a3074b2aae565f8558b7ea707ca48d2","mtime":"2008-09-22T00:18:37Z","perm":"0644"},
  "files/dir1/random_333":{"size":333,"sha256":"69fd85e4544d4057edb8954d77dfce2b2ded8177b889a4512a7456caf1a2e78b","sha1":"1fffb088a74a48447ee612dcab91dacae86570ad","gitsum":"935633dc1238e064bf841e02b1a9128d75348ffd","md5":"af6888a81369b7a1ecfbaf14791c5552","mtime":"2008-09-22T00:10:06Z","perm":"0644"},
  "files/dir1/textfile":{"size":43,"sha256":"7dcd877deb276541bc439e639b2838099406f56ec2d8337da27abab986bfcc50","sha1":"c70053a7b8f6276ff22181364430e729c7f42c5a","gitsum":"d31c8dc43d0efce334ee8099be772347eba54002","md5":"96319d5ea553d5e39fd9c843759d3175","mtime":"2008-09-22T00:09:38Z","perm":"0644"},
  "files/dir1/year_1969":{"size":41,"sha256":"81fae0df95efba03969fe59e7bbcbc94ed6448276c64770f2b5fab5d64a8932d","sha1":"07b8074463668967f6030016d719ef326eb6382d","gitsum":"fe008e59667b2eb0848d9092f4eceac8725a162b","md5":"6dce58e78b13dab939de6eef142b7543","mtime":"1969-01-21T17:12:15Z","perm":"0644"},
  "files/dir1/year_2038":{"size":41,"sha256":"0d048aa5dedb88a9198874f8fcf60ac1eaca7365217e074e798f2d5fa03f561b","sha1":"2113343435a9aadb458d576396d4f960071f8efd","gitsum":"052a58773edb46b2d494a23718cac040fb38c741","md5":"6babaa47123f4f94ae59ed581a65090b","mtime":"2038-01-19T03:14:07Z","perm":"0644"}
 }
}
END
    "fldb: files/dir1: Ignoring non-file\n" .
    "fldb: files/dir1/chmod_0000: Cannot read file: Permission denied\n",
    0,
    "Read zero-separated file list from stdin",
);

# }}}
diag("Use default short format...");
testcmd("$CMD files/dir1/random_2048 --sql", # {{{
    <<END,
INSERT INTO files (
 sha256, sha1, gitsum, md5, crc32,
 size, filename, mtime, perm,
 descr,
 latin1
) VALUES (
 '7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034', 'bd91a93ca0462da03f2665a236d7968b0fd9455d', 'ddf7d5a5e7a7b493368c2761faddb20a58bfbd59', '4a3074b2aae565f8558b7ea707ca48d2', NULL,
 2048, E'random_2048', '2008-09-22T00:18:37Z', '0644',
 NULL,
 FALSE
);
END
    "",
    0,
    "Output short SQL from dir1/random_2048",
);

# }}}
diag("Testing -j (--json) option...");
testcmd("$CMD -j files/dir1/*", # {{{
    <<END,
{
 "files":{
  "files/dir1/empty":{"size":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","sha1":"da39a3ee5e6b4b0d3255bfef95601890afd80709","gitsum":"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391","md5":"d41d8cd98f00b204e9800998ecf8427e","mtime":"2008-09-22T00:10:24Z","perm":"0644"},
  "files/dir1/random_2048":{"size":2048,"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034","sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d","gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59","md5":"4a3074b2aae565f8558b7ea707ca48d2","mtime":"2008-09-22T00:18:37Z","perm":"0644"},
  "files/dir1/random_333":{"size":333,"sha256":"69fd85e4544d4057edb8954d77dfce2b2ded8177b889a4512a7456caf1a2e78b","sha1":"1fffb088a74a48447ee612dcab91dacae86570ad","gitsum":"935633dc1238e064bf841e02b1a9128d75348ffd","md5":"af6888a81369b7a1ecfbaf14791c5552","mtime":"2008-09-22T00:10:06Z","perm":"0644"},
  "files/dir1/textfile":{"size":43,"sha256":"7dcd877deb276541bc439e639b2838099406f56ec2d8337da27abab986bfcc50","sha1":"c70053a7b8f6276ff22181364430e729c7f42c5a","gitsum":"d31c8dc43d0efce334ee8099be772347eba54002","md5":"96319d5ea553d5e39fd9c843759d3175","mtime":"2008-09-22T00:09:38Z","perm":"0644"},
  "files/dir1/year_1969":{"size":41,"sha256":"81fae0df95efba03969fe59e7bbcbc94ed6448276c64770f2b5fab5d64a8932d","sha1":"07b8074463668967f6030016d719ef326eb6382d","gitsum":"fe008e59667b2eb0848d9092f4eceac8725a162b","md5":"6dce58e78b13dab939de6eef142b7543","mtime":"1969-01-21T17:12:15Z","perm":"0644"},
  "files/dir1/year_2038":{"size":41,"sha256":"0d048aa5dedb88a9198874f8fcf60ac1eaca7365217e074e798f2d5fa03f561b","sha1":"2113343435a9aadb458d576396d4f960071f8efd","gitsum":"052a58773edb46b2d494a23718cac040fb38c741","md5":"6babaa47123f4f94ae59ed581a65090b","mtime":"2038-01-19T03:14:07Z","perm":"0644"}
 }
}
END
    "fldb: files/dir1/chmod_0000: Cannot read file: Permission denied\n",
    0,
    "Output short JSON of all files",
);

# }}}
likecmd("$CMD -jl files/dir1/random_2048", # {{{
    '/^\{\n "files":\{\n  ' .
        '"random_2048":{' .
        '"size":2048,' .
        '"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034",' .
        '"sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d",' .
        '"gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59",' .
        '"md5":"4a3074b2aae565f8558b7ea707ca48d2",' .
        '"mtime":"2008-09-22T00:18:37Z",' .
        '"perm":"0644",' .
        '"ctime":"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ",' .
        '"path":"files\/dir1\/random_2048",' .
        '"inode":\d+,' .
        '"links":\d+,' .
        '"device":\d+,' .
        '"hostname":".*?",' .
        '"uid":\d+,' .
        '"gid":\d+' .
        '\}\n \}\n\}\n' .
        '$/',
    '/^$/',
    0,
    "Output long format JSON of dir1/random_2048",
);

# }}}
testcmd("$CMD -j files/dir1/random_2048", # {{{
    "{\n \"files\":{\n  " .
    '"files/dir1/random_2048":{' .
    '"size":2048,' .
    '"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034",' .
    '"sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d",' .
    '"gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59",' .
    '"md5":"4a3074b2aae565f8558b7ea707ca48d2",' .
    '"mtime":"2008-09-22T00:18:37Z",' .
    '"perm":"0644"' .
    "}\n }\n}\n",
    "",
    0,
    "Output short JSON of dir1/random_2048",
);

# }}}
diag("Testing -q (--quiet) option...");
testcmd("$CMD -q files/dir1/*", # {{{
    <<END,
{
 "files":{
  "files/dir1/empty":{"size":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","sha1":"da39a3ee5e6b4b0d3255bfef95601890afd80709","gitsum":"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391","md5":"d41d8cd98f00b204e9800998ecf8427e","mtime":"2008-09-22T00:10:24Z","perm":"0644"},
  "files/dir1/random_2048":{"size":2048,"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034","sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d","gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59","md5":"4a3074b2aae565f8558b7ea707ca48d2","mtime":"2008-09-22T00:18:37Z","perm":"0644"},
  "files/dir1/random_333":{"size":333,"sha256":"69fd85e4544d4057edb8954d77dfce2b2ded8177b889a4512a7456caf1a2e78b","sha1":"1fffb088a74a48447ee612dcab91dacae86570ad","gitsum":"935633dc1238e064bf841e02b1a9128d75348ffd","md5":"af6888a81369b7a1ecfbaf14791c5552","mtime":"2008-09-22T00:10:06Z","perm":"0644"},
  "files/dir1/textfile":{"size":43,"sha256":"7dcd877deb276541bc439e639b2838099406f56ec2d8337da27abab986bfcc50","sha1":"c70053a7b8f6276ff22181364430e729c7f42c5a","gitsum":"d31c8dc43d0efce334ee8099be772347eba54002","md5":"96319d5ea553d5e39fd9c843759d3175","mtime":"2008-09-22T00:09:38Z","perm":"0644"},
  "files/dir1/year_1969":{"size":41,"sha256":"81fae0df95efba03969fe59e7bbcbc94ed6448276c64770f2b5fab5d64a8932d","sha1":"07b8074463668967f6030016d719ef326eb6382d","gitsum":"fe008e59667b2eb0848d9092f4eceac8725a162b","md5":"6dce58e78b13dab939de6eef142b7543","mtime":"1969-01-21T17:12:15Z","perm":"0644"},
  "files/dir1/year_2038":{"size":41,"sha256":"0d048aa5dedb88a9198874f8fcf60ac1eaca7365217e074e798f2d5fa03f561b","sha1":"2113343435a9aadb458d576396d4f960071f8efd","gitsum":"052a58773edb46b2d494a23718cac040fb38c741","md5":"6babaa47123f4f94ae59ed581a65090b","mtime":"2038-01-19T03:14:07Z","perm":"0644"}
 }
}
END
    "fldb: files/dir1/chmod_0000: Cannot read file: Permission denied\n",
    0,
    "Single -q still shows permission denied message",
);

# }}}
testcmd("$CMD -jq --quiet files/dir1/*", # {{{
    <<END,
{
 "files":{
  "files/dir1/empty":{"size":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","sha1":"da39a3ee5e6b4b0d3255bfef95601890afd80709","gitsum":"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391","md5":"d41d8cd98f00b204e9800998ecf8427e","mtime":"2008-09-22T00:10:24Z","perm":"0644"},
  "files/dir1/random_2048":{"size":2048,"sha256":"7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034","sha1":"bd91a93ca0462da03f2665a236d7968b0fd9455d","gitsum":"ddf7d5a5e7a7b493368c2761faddb20a58bfbd59","md5":"4a3074b2aae565f8558b7ea707ca48d2","mtime":"2008-09-22T00:18:37Z","perm":"0644"},
  "files/dir1/random_333":{"size":333,"sha256":"69fd85e4544d4057edb8954d77dfce2b2ded8177b889a4512a7456caf1a2e78b","sha1":"1fffb088a74a48447ee612dcab91dacae86570ad","gitsum":"935633dc1238e064bf841e02b1a9128d75348ffd","md5":"af6888a81369b7a1ecfbaf14791c5552","mtime":"2008-09-22T00:10:06Z","perm":"0644"},
  "files/dir1/textfile":{"size":43,"sha256":"7dcd877deb276541bc439e639b2838099406f56ec2d8337da27abab986bfcc50","sha1":"c70053a7b8f6276ff22181364430e729c7f42c5a","gitsum":"d31c8dc43d0efce334ee8099be772347eba54002","md5":"96319d5ea553d5e39fd9c843759d3175","mtime":"2008-09-22T00:09:38Z","perm":"0644"},
  "files/dir1/year_1969":{"size":41,"sha256":"81fae0df95efba03969fe59e7bbcbc94ed6448276c64770f2b5fab5d64a8932d","sha1":"07b8074463668967f6030016d719ef326eb6382d","gitsum":"fe008e59667b2eb0848d9092f4eceac8725a162b","md5":"6dce58e78b13dab939de6eef142b7543","mtime":"1969-01-21T17:12:15Z","perm":"0644"},
  "files/dir1/year_2038":{"size":41,"sha256":"0d048aa5dedb88a9198874f8fcf60ac1eaca7365217e074e798f2d5fa03f561b","sha1":"2113343435a9aadb458d576396d4f960071f8efd","gitsum":"052a58773edb46b2d494a23718cac040fb38c741","md5":"6babaa47123f4f94ae59ed581a65090b","mtime":"2038-01-19T03:14:07Z","perm":"0644"}
 }
}
END
    "",
    0,
    "Two -q options suppress permission denied message",
);

# }}}
testcmd("$CMD -q files/dir1", # {{{
    <<END,
{
 "files":{
 }
}
END
    "",
    0,
    "One -q suppresses 'Ignoring non-file' message",
);

# }}}
testcmd("$CMD -vq files/dir1", # {{{
    <<END,
{
 "files":{
 }
}
END
    "fldb: files/dir1: Ignoring non-file\n",
    0,
    "Adding -v to -q gets the 'Ignoring non-file' message back",
);

# }}}
diag("Testing -x (--xml) option...");
likecmd("$CMD -xl files/dir1/random_2048", # {{{
    '/^<fldb>\n' .
            '<file> ' .
                '<size>2048<\/size> ' .
                '<sha256>7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034</sha256> ' .
                '<sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d<\/sha1> ' .
                '<gitsum>ddf7d5a5e7a7b493368c2761faddb20a58bfbd59<\/gitsum> ' .
                '<md5>4a3074b2aae565f8558b7ea707ca48d2<\/md5> ' .
                '<filename>random_2048<\/filename> ' .
                '<mtime>2008-09-22T00:18:37Z<\/mtime> ' .
                '<perm>0644<\/perm> ' .
                '<ctime>\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ<\/ctime> ' .
                '<path>files\/dir1\/random_2048<\/path> ' .
                '<inode>\d+<\/inode> <links>1<\/links> ' .
                '<device>\d+<\/device> ' .
                '<hostname>.*?<\/hostname> ' .
                '<uid>\d+<\/uid> <gid>\d+<\/gid> ' .
            '<\/file>\n' .
        '<\/fldb>\n' .
        '$/',
    '/^$/',
    0,
    "Output long XML from dir1/random_2048",
);

# }}}
testcmd("$CMD -x files/dir1/random_2048", # {{{
    <<END,
<fldb>
<file> <size>2048</size> <sha256>7706d48f361957858fc567d82f9a765104e0d5383674ce72e946357696127034</sha256> <sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d</sha1> <gitsum>ddf7d5a5e7a7b493368c2761faddb20a58bfbd59</gitsum> <md5>4a3074b2aae565f8558b7ea707ca48d2</md5> <filename>files/dir1/random_2048</filename> <mtime>2008-09-22T00:18:37Z</mtime> <perm>0644</perm> </file>
</fldb>
END
    "",
    0,
    "Output short XML from dir1/random_2048",
);

# }}}
diag("Test strange mtimes...");
testcmd("$CMD -j files/dir1/year_1969", # {{{
    "{\n \"files\":{\n  " .
    '"files/dir1/year_1969":{' .
    '"size":41,' .
    '"sha256":"81fae0df95efba03969fe59e7bbcbc94ed6448276c64770f2b5fab5d64a8932d",' .
    '"sha1":"07b8074463668967f6030016d719ef326eb6382d",' .
    '"gitsum":"fe008e59667b2eb0848d9092f4eceac8725a162b",' .
    '"md5":"6dce58e78b13dab939de6eef142b7543",' .
    '"mtime":"1969-01-21T17:12:15Z",' .
    '"perm":"0644"' .
    "}\n }\n}\n",
    "",
    0,
    "Display mtime from 1969 correctly",
);

# }}}
testcmd("$CMD -x files/dir1/year_2038", # {{{
    "<fldb>\n" .
        join(' ',
            '<file>',
                '<size>41</size>',
                '<sha256>0d048aa5dedb88a9198874f8fcf60ac1eaca7365217e074e798f2d5fa03f561b</sha256>',
                '<sha1>2113343435a9aadb458d576396d4f960071f8efd</sha1>',
                '<gitsum>052a58773edb46b2d494a23718cac040fb38c741</gitsum>',
                '<md5>6babaa47123f4f94ae59ed581a65090b</md5>',
                '<filename>files/dir1/year_2038</filename>',
                '<mtime>2038-01-19T03:14:07Z</mtime>',
                '<perm>0644</perm>',
            '</file>',
        ) .
    "\n</fldb>\n",
    "",
    0,
    "Display mtime from 2038 correctly",
);

# }}}
diag("Clean up...");
ok(chmod(0644, "files/dir1/chmod_0000"), "chmod(0644, 'files/dir1/chmod_0000')");
ok(unlink(glob("files/dir1/*")), 'Delete files in files/dir1/*');
ok(rmdir("files/dir1"), 'rmdir files/dir1');

todo_section:
;

if ($Opt{'all'} || $Opt{'todo'}) {
    diag('Running TODO tests...'); # {{{

    TODO: {

local $TODO = '';
# Insert TODO tests here.

    }
    # TODO tests }}}
}

diag('Testing finished.');

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'fldb-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, $Exp_stdout, $Txt);
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'fldb-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", $Txt);
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            like(file_data($TMP_STDERR), "$Exp_stderr", "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;
    if (open(my $fp, '<', $File)) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return($Txt);
    } else {
        return;
    }
    # }}}
} # file_data()

sub print_version {
    # Print program version {{{
    print("$progname v$VERSION\n");
    return;
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<"END");

Usage: $progname [options] [file [files [...]]]

Contains tests for the fldb(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
  -t, --todo
    Run only the TODO tests.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.
  --debug
    Print debugging messages.

END
    exit($Retval);
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
    return;
    # }}}
} # msg()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 SYNOPSIS

fldb.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the fldb(1) program.

=head1 OPTIONS

=over 4

=item B<-a>, B<--all>

Run all tests, also TODOs.

=item B<-h>, B<--help>

Print a brief help summary.

=item B<-t>, B<--todo>

Run only the TODO tests.

=item B<-v>, B<--verbose>

Increase level of verbosity. Can be repeated.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation, either version 2 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program.
If not, see L<http://www.gnu.org/licenses/>.

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
