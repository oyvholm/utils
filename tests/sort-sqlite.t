#!/usr/bin/env perl

#=======================================================================
# sort-sqlite.t
# File ID: b5f7d80e-70ff-11e5-96fa-fefdb24f8e10
#
# Test suite for sort-sqlite(1).
#
# Character set: UTF-8
# ©opyleft 2015– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;
use IPC::Open3;

local $| = 1;

our $CMDB = "sort-sqlite";
our $CMD = "../$CMDB";
our $SQLITE = "sqlite3";

our %Opt = (

    'all' => 0,
    'help' => 0,
    'quiet' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.0.0';

my %descriptions = ();

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'help|h' => \$Opt{'help'},
    'quiet|q+' => \$Opt{'quiet'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'verbose'} -= $Opt{'quiet'};
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

my $sql_error = 0;

exit(main());

sub main {
    # {{{
    my $Retval = 0;

    diag(sprintf('========== Executing %s v%s ==========',
                 $progname, $VERSION));

    if ($Opt{'todo'} && !$Opt{'all'}) {
        goto todo_section;
    }

=pod

    testcmd("$CMD command", # {{{
        <<'END',
[expected stdout]
END
        '',
        0,
        'description',
    );

    # }}}

=cut

    diag('Testing -h (--help) option...');
    likecmd("$CMD -h", # {{{
        '/  Show this help/i',
        '/^$/',
        0,
        'Option -h prints help screen',
    );

    # }}}
    diag('Testing -v (--verbose) option...');
    likecmd("$CMD -hv", # {{{
        '/^\n\S+ \d+\.\d+\.\d+/s',
        '/^$/',
        0,
        'Option -v with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ \d+\.\d+\.\d+/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}
    ok(chdir("sort-sqlite-files"), "chdir sort-sqlite-files");
    $CMD = "../$CMD";
    testcmd("tar xzf sqlite-dbs.tar.gz", # {{{
        '',
        '',
        0,
        "Untar sqlite-dbs.tar.gz",
    );

    # }}}
    ok(chdir("sqlite-dbs"), "chdir sqlite-dbs");
    $CMD = "../$CMD";
    testcmd("$CMD -c abc.def non-existing.sqlite", # {{{
        "",
        "sort-sqlite: non-existing.sqlite: File is not readable by you or is not a regular file\n",
        1,
        "Try to open a non-existing file",
    );

    # }}}
    testcmd("$CMD unsorted1.sqlite", # {{{
        "",
        "sort-sqlite: Missing -c/--column option\n",
        1,
        "Missing -c/--column option",
    );

    # }}}
    likecmd("$CMD -c non.existing unsorted1.sqlite", # {{{
        '/^$/',
        '/^.*sort-sqlite: unsorted1.sqlite: sqlite3 error, aborting\n$/s',
        1,
        "Try to sort unsorted1.sqlite with unknown table and column",
    );

    # }}}
    is(sqlite_dump("unsorted1.sqlite"), # {{{
        <<END,
CREATE TABLE t (
  a TEXT
);
t|a
t|b
t|d
t|c
END
        "unsorted1.sqlite is not modified",
    );

    # }}}
    testcmd("$CMD -c t.a unsorted1.sqlite", # {{{
        "",
        "",
        0,
        "Sort unsorted1.sqlite",
    );

    # }}}
    is(sqlite_dump("unsorted1.sqlite"), # {{{
        <<END,
CREATE TABLE t (
  a TEXT
);
t|a
t|b
t|c
t|d
END
        "unsorted1.sqlite looks ok",
    );

    # }}}
    ok(-f "unsorted1.sqlite.20151012T164244Z.bck", "Backup file 1 exists");
    testcmd("$CMD -v --column t.a -c u.a unsorted2.sqlite " .
            "unsorted3.sqlite", # {{{
        "",
        "sort-sqlite: Sorting unsorted2.sqlite\n" .
        "sort-sqlite: Sorting unsorted3.sqlite\n",
        0,
        "Sort several tables in unsorted2.sqlite",
    );

    # }}}
    is(sqlite_dump("unsorted2.sqlite"), # {{{
        <<END,
CREATE TABLE u (
  a TEXT
);
CREATE TABLE t (
  a TEXT
);
t|a
t|b
t|c
t|d
u|0
u|1
u|a
u|aa
u|→
END
        "unsorted2.sqlite looks ok",
    );

    # }}}
    is(sqlite_dump("unsorted3.sqlite"), # {{{
        <<END,
CREATE TABLE u (
  a TEXT
);
CREATE TABLE one (
  single TEXT
);
CREATE TABLE t (
  a TEXT
);
one|z
t|a
t|b
t|c
t|d
u|0
u|1
u|a
u|aa
u|→
END
        "unsorted3.sqlite looks ok",
    );

    # }}}
    testcmd("$CMD -c t.a unsorted4.sqlite --column u.a", # {{{
        "",
        "",
        0,
        "Sort unsorted4.sqlite, entries have several lines",
    );

    # }}}
    ok(-f "unsorted4.sqlite.20161103T235439Z.bck", "Backup file 4 exists");
    is(sqlite_dump("unsorted4.sqlite"), # {{{
        <<END,
CREATE TABLE u (
  a TEXT
);
CREATE TABLE t (
  a TEXT
);
t|\n\nanother\n\nmulti\nline\n
t|a
t|b
t|c
u|0
u|1
u|aa
u|multi\nline\nhere
u|→
END
        "unsorted4.sqlite looks ok",
    );

    # }}}
    ok(-f "unsorted2.sqlite.20151012T164437Z.bck", "Backup file 2 exists");
    ok(-f "unsorted3.sqlite.20151012T181141Z.bck", "Backup file 3 exists");
    ok(unlink("unsorted1.sqlite"), "Delete unsorted1.sqlite");
    ok(unlink("unsorted2.sqlite"), "Delete unsorted2.sqlite");
    ok(unlink("unsorted3.sqlite"), "Delete unsorted3.sqlite");
    ok(unlink("unsorted4.sqlite"), "Delete unsorted4.sqlite");
    ok(unlink("unsorted1.sqlite.20151012T164244Z.bck"), "Delete backup 1");
    ok(unlink("unsorted2.sqlite.20151012T164437Z.bck"), "Delete backup 2");
    ok(unlink("unsorted3.sqlite.20151012T181141Z.bck"), "Delete backup 3");
    ok(unlink("unsorted4.sqlite.20161103T235439Z.bck"), "Delete backup 4");
    ok(chdir(".."), "chdir ..");
    ok(rmdir("sqlite-dbs"), "rmdir sqlite-dbs");

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
    return $Retval;
    # }}}
} # main()

sub sql {
    # {{{
    my ($db, $sql) = @_;
    my @retval = ();

    msg(5, "sql(): db = '$db'");
    local(*CHLD_IN, *CHLD_OUT, *CHLD_ERR);

    my $pid = open3(*CHLD_IN, *CHLD_OUT, *CHLD_ERR, $SQLITE, $db) or (
        $sql_error = 1,
        msg(0, "sql(): open3() error: $!"),
        return("sql() error"),
    );
    msg(5, "sql(): sql = '$sql'");
    print(CHLD_IN "$sql\n") or msg(0, "sql(): print CHLD_IN error: $!");
    close(CHLD_IN);
    @retval = <CHLD_OUT>;
    msg(5, "sql(): retval = '" . join('|', @retval) . "'");
    my @child_stderr = <CHLD_ERR>;
    if (scalar(@child_stderr)) {
        msg(1, "$SQLITE error: " . join('', @child_stderr));
        $sql_error = 1;
    }
    return(join('', @retval));
    # }}}
} # sql()

sub sqlite_dump {
    # Return contents of database file {{{
    my $File = shift;

    return sql($File, <<END);
.nullvalue NULL
.schema
SELECT 'one', * FROM one;
SELECT 't', * FROM t;
SELECT 'u', * FROM u;
END
    # }}}
} # sqlite_dump()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
    my $TMP_STDERR = "$CMDB-stderr.tmp";
    my $retval = 1;

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    $retval &= is(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        $retval &= is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    $retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

    return $retval;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("likecmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
    my $TMP_STDERR = "$CMDB-stderr.tmp";
    my $retval = 1;

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    $retval &= like(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        $retval &= like(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    $retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

    return $retval;
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;

    open(my $fp, '<', $File) or return undef;
    local $/ = undef;
    $Txt = <$fp>;
    close($fp);
    return $Txt;
    # }}}
} # file_data()

sub print_version {
    # Print program version {{{
    print("$progname $VERSION\n");
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

Usage: $progname [options]

Contains tests for the $CMDB(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
  -q, --quiet
    Be more quiet. Can be repeated to increase silence.
  -t, --todo
    Run only the TODO tests.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.

END
    exit($Retval);
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    $verbose_level > $Opt{'verbose'} && return;
    print(STDERR "$progname: $Txt\n");
    return;
    # }}}
} # msg()

__END__

# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or (at 
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program.
# If not, see L<http://www.gnu.org/licenses/>.

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
