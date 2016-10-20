#!/usr/bin/env perl

#=======================================================================
# postgres.t
# File ID: 6c8dbc38-3b85-11e5-9db6-000df06acc56
#
# Test suite for postgres(1).
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

local $| = 1;

our $CMD_BASENAME = "";
our $CMD = "../$CMD_BASENAME";

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
our $VERSION = '0.1.0';

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

my $tmpdb = "tmp-postgres-t-$$-" . substr(rand, 2, 8);
my $tmp_stdout = '.tmp-postgres-t-stdout.tmp';
my $tmp_stderr = '.tmp-postgres-t-stderr.tmp';

exit(main());

sub main {
    # {{{
    my $Retval = 0;

    diag(sprintf('========== Executing %s v%s ==========',
        $progname,
        $VERSION));

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

    testcmd("createdb \"$tmpdb\"", # {{{
        '',
        '',
        0,
        'Create temporary database',
    ) || BAIL_OUT("Cannot create temporary database, " .
                  "not much point in going on, then");

    # }}}
    diag('Make sure the db sorting uses C locale');
    psql_cmd($tmpdb, # {{{
        <<END,
CREATE TABLE t (s varchar);
COPY t FROM stdin;
f
gh
ß
ser
a
o
æ
øæ
å

ØØØØHH
12
ÆØ
ÅØÆ
→
O
©
X
Y
x
y
🤘
❤
☮
A
B
indeed
\\.
END
        '/^' .
            'CREATE TABLE\n' .
            'COPY 27\n' .
            '$/',
        '/^$/',
        'Insert unsorted text into db',
    );

    # }}}
    psql_cmd($tmpdb, # {{{
        'COPY (SELECT * FROM t ORDER BY s) TO stdout;',
        '/^' .
            '\n' .
            '12\n' .
            'A\n' .
            'B\n' .
            'O\n' .
            'X\n' .
            'Y\n' .
            'a\n' .
            'f\n' .
            'gh\n' .
            'indeed\n' .
            'o\n' .
            'ser\n' .
            'x\n' .
            'y\n' .
            '©\n' .
            'ÅØÆ\n' .
            'ÆØ\n' .
            'ØØØØHH\n' .
            'ß\n' .
            'å\n' .
            'æ\n' .
            'øæ\n' .
            '→\n' .
            '☮\n' .
            '❤\n' .
            '🤘\n' .
            '$/',
        '/^$/',
        'Text sorting follows the Unicode table',
    );

    # }}}
    diag('Cleaning up...');
    ok(unlink($tmp_stdout), 'Delete stdout tmpfile');
    ok(unlink($tmp_stderr), 'Delete stderr tmpfile');
    testcmd("dropdb \"$tmpdb\"", # {{{
        '',
        '',
        0,
        'Drop temporary database',
    );

    # }}}

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

sub psql_cmd {
    # {{{
    my ($db, $sql, $exp_stdout, $exp_stderr, $desc) = @_;
    ok(open(my $dbpipe, "| psql -X -d \"$tmpdb\" >$tmp_stdout 2>$tmp_stderr"),
        "Open db pipe ($desc)");
    ok(print($dbpipe $sql), "Print to pipe ($desc)");
    ok(close($dbpipe), "Close db pipe ($desc)");
    like(file_data($tmp_stdout), $exp_stdout, "$desc (stdout)");
    like(file_data($tmp_stderr), $exp_stderr, "$desc (stderr)");
    return;
    # }}}
} # psql_cmd()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('',
        $cmd_outp_str,
        defined($Desc)
            ? $Desc
            : ''
    );
    my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
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
    my $Txt = join('',
        $cmd_outp_str,
        defined($Desc)
            ? $Desc
            : ''
    );
    my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
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
    if (open(my $fp, '<', $File)) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return $Txt;
    } else {
        return;
    }
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

Contains tests for the $CMD_BASENAME(1) program.

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

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
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
