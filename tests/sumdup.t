#!/usr/bin/env perl

#=======================================================================
# sumdup.t
# File ID: 72d68c8c-f988-11dd-989d-000475e441b9
#
# Test suite for sumdup(1).
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

our $CMD_BASENAME = "sumdup";
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
    diag('Testing sorted input...');
    testcmd("sort sumdup-files/files.md5 | $CMD", # {{{
        <<'END',

99754106633f94d350db34d548d6091a  file2
99754106633f94d350db34d548d6091a  file4
99754106633f94d350db34d548d6091a  file5

ab4e78bf3b9d8b1aa18537c3f780245c  file3
ab4e78bf3b9d8b1aa18537c3f780245c  file6
END
        '',
        0,
        'Finds duplicates in sorted output from sumdup-files/files.md5',
    );

    # }}}
    testcmd("sort sumdup-files/files.sha1 | $CMD", # {{{
        <<'END',

38d0f91a99c57d189416439ce377ccdcd92639d0  file2
38d0f91a99c57d189416439ce377ccdcd92639d0  file4
38d0f91a99c57d189416439ce377ccdcd92639d0  file5
38d0f91a99c57d189416439ce377ccdcd92639d0  file6
38d0f91a99c57d189416439ce377ccdcd92639d0  file7

ad2aeab58d53f21a7004250c49fa0a6bff59477d  file0
ad2aeab58d53f21a7004250c49fa0a6bff59477d  file3

f62e5bcda4fae4f82370da0c6f20697b8f8447ef  file1
f62e5bcda4fae4f82370da0c6f20697b8f8447ef  file8
f62e5bcda4fae4f82370da0c6f20697b8f8447ef  file9
END
        '',
        0,
        'Finds duplicates in sorted output from sumdup-files/files.sha1',
    );

    # }}}
    testcmd("sort sumdup-files/files.sha256 | $CMD", # {{{
        <<'END',

6ac3c336e4094835293a3fed8a4b5fedde1b5e2626d9838fed50693bba00af0e  file2
6ac3c336e4094835293a3fed8a4b5fedde1b5e2626d9838fed50693bba00af0e  file6

dfc7027894e168c3292c50b5461ef8ec635a5e04874b1e13b5ad7596a98f3bda  file1
dfc7027894e168c3292c50b5461ef8ec635a5e04874b1e13b5ad7596a98f3bda  file4
dfc7027894e168c3292c50b5461ef8ec635a5e04874b1e13b5ad7596a98f3bda  file5

e2c4470a88f236a403c49d4be7c8f2f9e5e54f914e0d342ff24ee707ca85f070  file3
e2c4470a88f236a403c49d4be7c8f2f9e5e54f914e0d342ff24ee707ca85f070  file7
END
        '',
        0,
        'Finds duplicates in sorted output from sumdup-files/files.sha256',
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
