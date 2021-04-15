#!/usr/bin/env perl

#==============================================================================
# ustr.t
# File ID: 01540956-06f4-11e5-bc56-000df06acc56
#
# Test suite for ustr(1).
#
# Character set: UTF-8
# ©opyleft 2015– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of file for 
# legal stuff.
#==============================================================================

use strict;
use warnings;

BEGIN {
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMDB = "ustr";
our $CMD = "../$CMDB";

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
our $VERSION = '0.0.0'; # Not used here, $CMD decides

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

my $exec_version = `$CMD --version`;

exit(main());

sub main {
    my $Retval = 0;

    diag('========== BEGIN version info ==========');
    diag($exec_version);
    diag('=========== END version info ===========');

    if ($Opt{'todo'} && !$Opt{'all'}) {
        goto todo_section;
    }

    test_standard_options();
    test_executable();

    diag('========== BEGIN version info ==========');
    diag($exec_version);
    diag('=========== END version info ===========');

    todo_section:
    ;

    if ($Opt{'all'} || $Opt{'todo'}) {
        diag('Running TODO tests...');
        TODO: {
            local $TODO = '';
            # Insert TODO tests here.
        }
    }

    diag('Testing finished.');

    return $Retval;
}

sub test_standard_options {
    diag('Testing -h (--help) option...');
    likecmd("$CMD -h",
            '/  Show this help/i',
            '/^$/',
            0,
            'Option -h prints help screen');

    likecmd("$CMD --help",
            '/'
            . '1\xCC\xB6'
            . '2\xCC\xB6'
            . '3\xCC\xB6'
            . ' \xCC\xB6'
            . 'a\xCC\xB6'
            . 'b\xCC\xB6'
            . 'c\xCC\xB6'
            . '/',
            '/^$/',
            0,
            'Strikethrough example in usage screen is displayed correctly');

    diag('Testing -v (--verbose) option...');
    likecmd("$CMD -hv",
            '/^\n\S+ \d+\.\d+\.\d+/s',
            '/^$/',
            0,
            'Option -v with -h returns version number and help screen');

    diag('Testing --version option...');
    likecmd("$CMD --version",
            '/^\S+ \d+\.\d+\.\d+/',
            '/^$/',
            0,
            'Option --version returns version number');

    return;
}

sub test_executable {
    testcmd("echo Dødens pølse ☠ | $CMD",
            "D̲ø̲d̲e̲n̲s̲ ̲p̲ø̲l̲s̲e̲ ̲☠̲\n",
            '',
            0,
            'Works with UTF-8');
    testcmd("echo Sausage of death ☠ | $CMD -s",
            "S̶a̶u̶s̶a̶g̶e̶ ̶o̶f̶ ̶d̶e̶a̶t̶h̶ ̶☠̶\n",
            '',
            0,
            'Use -s (strikethrough)');
    testcmd("echo Dødens pølse ☠ | $CMD --strikethrough",
            "D̶ø̶d̶e̶n̶s̶ ̶p̶ø̶l̶s̶e̶ ̶☠̶\n",
            '',
            0,
            'Use --strikethrough');
    testcmd("echo S̲t̲a̲n̲d̲a̲r̲d̲ ̲A̲S̲C̲I̲I̲ ̲h̲e̲r̲e̲ | $CMD -d",
            "Standard ASCII here\n",
            "",
            0,
            "-d option deletes underline");
    testcmd("echo S̶t̶a̶n̶d̶a̶r̶d̶ ̶A̶S̶C̶I̶I̶ ̶h̶e̶r̶e̶ | $CMD -ds",
            "Standard ASCII here\n",
            "",
            0,
            "-ds deletes strikethrough");
    testcmd("echo S̲t̲a̲n̲d̲a̲r̲d̲ ̲A̲S̲C̲I̲I̲ ̲h̲e̲r̲e̲ | $CMD -ds",
            "S̲t̲a̲n̲d̲a̲r̲d̲ ̲A̲S̲C̲I̲I̲ ̲h̲e̲r̲e̲\n",
            "",
            0,
            "-ds doesn't delete underline");
    testcmd("echo S̶t̶a̶n̶d̶a̶r̶d̶ ̶A̶S̶C̶I̶I̶ ̶h̶e̶r̶e̶ | $CMD -d",
            "S̶t̶a̶n̶d̶a̶r̶d̶ ̶A̶S̶C̶I̶I̶ ̶h̶e̶r̶e̶\n",
            "",
            0,
            "-d doesn't delete strikethrough");
    testcmd("echo B̲æ̲æ̲æ̲d̲i̲ ̲🐑̲ | $CMD -d",
            "Bææædi 🐑\n",
            "",
            0,
            "-d option deletes underline from UTF-8 string");
    testcmd("echo B̶æ̶æ̶æ̶d̶i̶ ̶🐑̶ | $CMD -ds",
            "Bææædi 🐑\n",
            "",
            0,
            "-ds option deletes strikethrough from UTF-8 string");

    return;
}

sub testcmd {
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc})
    && BAIL_OUT("testcmd(): '$Desc' description is used twice");
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
}

sub likecmd {
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc})
    && BAIL_OUT("likecmd(): '$Desc' description is used twice");
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
}

sub file_data {
    # Return file content as a string
    my $File = shift;
    my $Txt;

    open(my $fp, '<', $File) or return undef;
    local $/ = undef;
    $Txt = <$fp>;
    close($fp);

    return $Txt;
}

sub create_file {
    # Create new file and fill it with data
    my ($file, $text) = @_;
    my $retval = 0;

    open(my $fp, ">", $file) or return 0;
    print($fp $text);
    close($fp);
    $retval = is(file_data($file), $text,
                 "$file was successfully created");

    return $retval; # 0 if error, 1 if ok
}

sub print_version {
    # Print program version
    print("$progname $VERSION\n");

    return;
}

sub usage {
    # Send the help message to stdout
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
}

sub msg {
    # Print a status message to stderr based on verbosity level
    my ($verbose_level, $Txt) = @_;

    $verbose_level > $Opt{'verbose'} && return;
    print(STDERR "$progname: $Txt\n");

    return;
}

__END__

# This program is free software; you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation; either version 2 of the License, or (at your option) any later 
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with 
# this program.
# If not, see L<http://www.gnu.org/licenses/>.

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
