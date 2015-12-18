#!/usr/bin/env perl

#=======================================================================
# zeropad.t
# File ID: af9a9f46-f988-11dd-a1c1-000475e441b9
#
# Test suite for zeropad(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
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

our $CMD_BASENAME = "zeropad";
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
        '/^\n\S+ \d+\.\d+\.\d+(\+git)?\n/s',
        '/^$/',
        0,
        'Option -v with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ \d+\.\d+\.\d+(\+git)?\n/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}
    testcmd("echo 1 5 12 156 1024 | $CMD", # {{{
        "0001 0005 0012 0156 1024\n",
        '',
        0,
        '1 5 12 156 1024 with LF',
    );

    # }}}
    testcmd("echo -n 1 5 12 156 1024 | $CMD", # {{{
        '0001 0005 0012 0156 1024',
        '',
        0,
        'No terminating LF',
    );

    # }}}
    testcmd("echo -n 0 jada 1234567 e 345 - 23477 æøå | $CMD", # {{{
        '0000000 jada 1234567 e 0000345 - 0023477 æøå',
        '',
        0,
        'Contains non-numbers',
    );

    # }}}
    testcmd("echo -n 0 12345 -4 1000 | $CMD", # {{{
        '00000 12345 -00004 01000',
        '',
        0,
        'Contains negative number',
    );

    # }}}
    testcmd("echo -n 0 jada 143022551321802064700594651108964515733 e 345 - 23477 æøå | $CMD", # {{{
        '000000000000000000000000000000000000000 jada 143022551321802064700594651108964515733 e 000000000000000000000000000000000000345 - 000000000000000000000000000000000023477 æøå',
        '',
        0,
        'Manage large numbers',
    );

    # }}}
    diag('Testing -s/--size option...');
    testcmd("echo -n 1 234444 5 2312 233333333156 1024 | $CMD -s 4", # {{{
        '0001 234444 0005 2312 233333333156 1024',
        '',
        0,
        'Pad decimal numbers to four digits, -s 4',
    );

    # }}}
    testcmd("echo -n 0 jada 1234567 e 345 - 23477 æøå | $CMD -x --size 5", # {{{
        '00000 j00ada 1234567 0000e 00345 - 23477 æøå',
        '',
        0,
        'Pad to five hex digits with --size 5',
    );

    # }}}
    diag('Testing -x/--hex option...');
    testcmd("echo 1 5 12 156 1024 | $CMD -x", # {{{
        "0001 0005 0012 0156 1024\n",
        '',
        0,
        '-x: 1 5 12 156 1024 with LF',
    );

    # }}}
    testcmd("echo -n 1 5 12 156 1024 | $CMD -x", # {{{
        '0001 0005 0012 0156 1024',
        '',
        0,
        '-x: No terminating LF',
    );

    # }}}
    testcmd("echo -n 0 jada 1234567 e 345 - 23477 æøå | $CMD -x", # {{{
        '0000000 j0000ada 1234567 000000e 0000345 - 0023477 æøå',
        '',
        0,
        '-x: Contains non-numbers',
    );

    # }}}
    testcmd("echo -n 0 12345 -a4 1000 | $CMD -x", # {{{
        '00000 12345 -000a4 01000',
        '',
        0,
        '-x: Contains negative number',
    );

    # }}}
    testcmd("echo -n 0 jada 143022551321802064700594651108964515733 e 345 - 23477 æøå | $CMD -x", # {{{
        '000000000000000000000000000000000000000 j000000000000000000000000000000000000ada 143022551321802064700594651108964515733 00000000000000000000000000000000000000e 000000000000000000000000000000000000345 - 000000000000000000000000000000000023477 æøå',
        '',
        0,
        '-x: Manage large numbers',
    );

    # }}}
    testcmd("echo 76abCD ffFFf f F yyyabcyyy | $CMD --hex", # {{{
        "76abCD 0ffFFf 00000f 00000F yyy000abcyyy\n",
        '',
        0,
        '--hex: Upper/lower case and "abc" inside word',
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
    return($Retval);
    # }}}
} # main()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $Txt = defined($Desc) ? $Desc : '';
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
    return($retval);
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("likecmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $Txt = defined($Desc) ? $Desc : '';
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
    return($retval);
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

Usage: $progname [options] [file [files [...]]]

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
