#!/usr/bin/env perl

#=======================================================================
# fromhex.t
# File ID: 05b995a4-f988-11dd-aac9-000475e441b9
#
# Test suite for fromhex(1).
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

our $CMD_BASENAME = "fromhex";
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
    testcmd("echo 76 72 c3 b8 76 6c 65 62 c3 b8 74 74 65 | $CMD", # {{{
        'vrøvlebøtte',
        '',
        0,
        'Read standard two-digit lowercase hex',
    );

    # }}}
    testcmd("echo 466ac3b873756c66206865722c2076656c6b6f6d6d656e2e | $CMD", # {{{
        'Fjøsulf her, velkommen.',
        '',
        0,
        'No spaces between hex',
    );

    # }}}
    testcmd("echo '4j4r6%%574.20 677w26_1756c6+ 573206§9206cg69:612/1.' | $CMD", # {{{
        'Det graules i lia!',
        '',
        0,
        'Ignore non-hex digits',
    );

    # }}}
    testcmd("echo 4B4A48426a6b62686a68626a6b6861732F262F36353435252629282f0A | $CMD", # {{{
        "KJHBjkbhjhbjkhas/&/6545%&)(/\n",
        '',
        0,
        'Include upper case',
    );

    # }}}
    testcmd("$CMD -d fromhex-files/decimal.txt", # {{{
        <<'END',
 __________________________
< Have to test decimal too >
 --------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
END
        '',
        0,
        'Read decimal numbers with -d, ignore other chars',
    );

    # }}}
    testcmd("echo 53 74 65 69 6b 6a 65 20 66 69 6e 65 20 67 61 72 64 69 6e 65 2 | $CMD", # {{{
        'Steikje fine gardine',
        '',
        0,
        'Don\'t output the byte that\'s missing a nibble',
    );

    # }}}
    testcmd("$CMD fromhex-files/single.txt", # {{{
        <<'END',

 ☺
/S\
/'\
END
        '',
        0,
        'Read single digits on their own line',
    );

    # }}}
    testcmd("$CMD fromhex-files/standardpudding.bin", # {{{
        <<'END',
Standardpudding til Folket. Det er vel ikke for mye forlangt. Eller skal
vi sitte her og råtne i luksusen?

    Mvh              ~                                         +--------,
    Øyvind         _~              +        )        +      '  |/ _      \
  ,_______________| |______   ,                  ,           .   (~)  + +
 /________________________/\         .      *           +         U    *
 |                        ||                                       `.
+-------------------------------------------------------------_      (o_.'
| All you touch and all you see is all your life will ever be. -_    //\
| ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭ ✭  -_  V_/_
+-------------------------------------------------------------------------
END
        '',
        0,
        'Read digits from file with lots of binary noise',
    );

    # }}}
    diag('Test -u/--unicode option...');
    testcmd("echo 59 65 70_2E 20.2192/263a 2190 20 1f6BD | $CMD --unicode", # {{{
        'Yep. →☺← 🚽',
        '',
        0,
        'Read hex values in Unicode mode (--unicode)',
    );

    # }}}
    testcmd("echo 89 101 112_46 32%8594 9786 8592+32 128701 | $CMD -du", # {{{
        'Yep. →☺← 🚽',
        '',
        0,
        'Read decimal values in Unicode mode (-u)',
    );

    # }}}
    testcmd("echo 89 101 112-46 32%8594?9786 8592b32 128701 | $CMD -d", # {{{
        'Yep. ',
        "fromhex: Cannot print byte value 8594 in bytewise mode, use -u\n",
        1,
        'Read high decimal values when not in Unicode mode',
    );

    # }}}
    diag('Suppress Perl warnings about invalid UTF-8...');
    testcmd("echo ffff | $CMD -u", # {{{
        "\xef\xbf\xbf",
        "",
        0,
        "Perl doesn't complain about U+FFFF",
    );

    # }}}
    testcmd("echo d800 | $CMD -u", # {{{
        "\xed\xa0\x80",
        "",
        0,
        "Perl doesn't complain about U+D800",
    );

    # }}}
    testcmd("echo 65535 | $CMD -ud", # {{{
        "\xef\xbf\xbf",
        "",
        0,
        "Perl doesn't complain about U+FFFF (decimal)",
    );

    # }}}
    testcmd("echo 55296 | $CMD -ud", # {{{
        "\xed\xa0\x80",
        "",
        0,
        "Perl doesn't complain about U+D800 (decimal)",
    );

    # }}}
    diag('Enable Perl UTF-8 warnings with -w/--warnings');
    likecmd("echo ffff | $CMD -uw", # {{{
        '/^\xef\xbf\xbf$/',
        '/Unicode/',
        0,
        "Perl complains about U+FFFF",
    );

    # }}}
    likecmd("echo d800 | $CMD -u --warning", # {{{
        '/^\xed\xa0\x80$/',
        '/surrogate .*D800/i',
        0,
        "Perl complains about U+D800",
    );

    # }}}
    likecmd("echo 65535 | $CMD -u --decimal -w", # {{{
        '/^\xef\xbf\xbf$/',
        '/Unicode/',
        0,
        "Perl complains about U+FFFF (decimal)",
    );

    # }}}
    likecmd("echo 55296 | $CMD -udw", # {{{
        '/^\xed\xa0\x80$/',
        '/surrogate .*D800/i',
        0,
        "Perl complains about U+D800 (decimal)",
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

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    defined($descriptions{$Desc}) &&
        BAIL_OUT("testcmd(): '$Desc' description is used twice");
    $descriptions{$Desc} = 1;
    my $stderr_cmd = '';
    my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
    my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
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
    my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
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
