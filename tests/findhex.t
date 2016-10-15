#!/usr/bin/env perl

#=======================================================================
# findhex.t
# File ID: 0d6b92c8-284a-11e5-8487-000df06acc56
#
# Test suite for findhex(1).
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

our $CMD_BASENAME = "findhex";
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
    my $stdtxt = 'asBAdcjkbw abdFF 2349.kjdc3211a abd 2349jk';
    diag('No options (except -vvv)...');
    testcmd("echo $stdtxt | $CMD -vvv", # {{{
        <<'END',
a
dc
b
abd
2349
dc3211a
abd
2349
END
        "findhex: minlen = '1', maxlen = '0'\n",
        0,
        'Find all hexadecimal numbers',
    );

    # }}}
    diag('Testing -d/--decimal option...');
    testcmd("echo $stdtxt | $CMD -vvv -d", # {{{
        <<'END',
2349
3211
2349
END
        "findhex: minlen = '1', maxlen = '0'\n",
        0,
        'Find all decimal numbers',
    );

    # }}}
    diag('Testing -i/--ignore-case option...');
    testcmd("echo $stdtxt | $CMD -i", # {{{
        <<'END',
a
badc
b
abdff
2349
dc3211a
abd
2349
END
        '',
        0,
        'Find all hex numbers, regardless of case',
    );

    # }}}
    diag('Testing -l/--length option...');
    testcmd("echo $stdtxt | $CMD -l 4 -vvv", # {{{
        <<'END',
2349
2349
END
        "findhex: minlen = '4', maxlen = '4'\n",
        0,
        'Find all hexadecimal with length of four chars',
    );

    # }}}
    testcmd("echo $stdtxt | $CMD -l 4- -vvv", # {{{
        <<'END',
2349
dc3211a
2349
END
        "findhex: minlen = '4', maxlen = '0'\n",
        0,
        'Find all hex four or more in length',
    );

    # }}}
    testcmd("echo $stdtxt | $CMD -l -3 -vvv", # {{{
        <<'END',
a
dc
b
abd
abd
END
        "findhex: minlen = '1', maxlen = '3'\n",
        0,
        'Up to three chars in length',
    );

    # }}}
    testcmd("echo $stdtxt | $CMD -l 3-4 -vvv", # {{{
        <<'END',
abd
2349
abd
2349
END
        "findhex: minlen = '3', maxlen = '4'\n",
        0,
        'Three or four chars',
    );

    # }}}

    diag('Test various predefined units...');
    unit_test('arj', 8);
    unit_test('byte', 2);
    unit_test('crc16', 4);
    unit_test('crc32', 8);
    unit_test('git', 40);
    unit_test('gzip', 8);
    unit_test('hg', 40);
    unit_test('md2', 32);
    unit_test('md4', 32);
    unit_test('md5', 32);
    unit_test('sha0', 40);
    unit_test('sha1', 40);
    unit_test('sha224', 56);
    unit_test('sha256', 64);
    unit_test('sha384', 96);
    unit_test('sha512', 128);
    unit_test('skein256', 64);
    unit_test('skein384', 96);
    unit_test('skein512', 128);
    unit_test('zip', 8);

    testcmd("$CMD -l yaman", # {{{
        '',
        "findhex: yaman: Unknown length unit\n",
        1,
        'Unknown value',
    );

    # }}}
    diag('Testing -u/--unique option...');
    testcmd("echo $stdtxt | $CMD -u", # {{{
        <<'END',
a
dc
b
abd
2349
dc3211a
END
        "",
        0,
        'Don\'t print same value twice with -u',
    );

    # }}}
    testcmd("echo $stdtxt badc AbD | $CMD -u -i", # {{{
        <<'END',
a
badc
b
abdff
2349
dc3211a
abd
END
        '',
        0,
        'Unique with upper/lower case',
    );

    # }}}
    diag('Various option combinations...');
    testcmd("echo $stdtxt | $CMD -vvv -d -l -3", # {{{
        '',
        "findhex: minlen = '1', maxlen = '3'\n",
        0,
        'No decimal-only with length 3 or less',
    );

    # }}}
    testcmd("echo $stdtxt | $CMD --decimal --unique", # {{{
        <<'END',
2349
3211
END
        '',
        0,
        'Unique decimal',
    );

    # }}}
    testcmd("echo $stdtxt | $CMD -i -l -3 --verbose -v -v", # {{{
        <<'END',
a
b
abd
END
        "findhex: minlen = '1', maxlen = '3'\n",
        0,
        'Upper/lower case, max length 3',
    );

    # }}}
    testcmd("echo $stdtxt | $CMD -i --length 4-5 --verbose -q --quiet -vvvv", # {{{
        <<'END',
badc
abdff
2349
2349
END
        "findhex: minlen = '4', maxlen = '5'\n",
        0,
        'Length 4-5, upper/lower case, -v and -q',
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

sub unit_test {
    # {{{
    my ($name, $size) = @_;
    return(testcmd("$CMD -vvv -l $name /dev/null",
        '',
        "findhex: minlen = '$size', maxlen = '$size'\n",
        0,
        "Unit: $name, size: $size",
    ));
    # }}}
} # unit_test()

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
