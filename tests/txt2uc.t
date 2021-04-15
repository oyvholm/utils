#!/usr/bin/env perl

#=======================================================================
# txt2uc.t
# File ID: 3c8499a2-394c-11e5-b0e5-fefdb24f8e10
#
# Test suite for txt2uc(1).
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

our $CMDB = "txt2uc";
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

exit(main());

sub main {
    # {{{
    my $Retval = 0;
    my $ucfile = "$ENV{'HOME'}/.unichar.sqlite";

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
    likecmd("$CMD -h -v", # {{{
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
    if (!-r $ucfile) {
        diag("$ucfile not found, skipping tests");
        return 0;
    }
    testcmd("echo -n Boring. | $CMD", # {{{
        <<'END',
0042;LATIN CAPITAL LETTER B;Lu;0;L;;;;;N;;;;0062;
006F;LATIN SMALL LETTER O;Ll;0;L;;;;;N;;;004F;;004F
0072;LATIN SMALL LETTER R;Ll;0;L;;;;;N;;;0052;;0052
0069;LATIN SMALL LETTER I;Ll;0;L;;;;;N;;;0049;;0049
006E;LATIN SMALL LETTER N;Ll;0;L;;;;;N;;;004E;;004E
0067;LATIN SMALL LETTER G;Ll;0;L;;;;;N;;;0047;;0047
002E;FULL STOP;Po;0;CS;;;;;N;PERIOD;;;;
END
        '',
        0,
        'Convert ASCII',
    );

    # }}}
    testcmd("echo Rock on. 🤘 | $CMD", # {{{
        <<'END',
0052;LATIN CAPITAL LETTER R;Lu;0;L;;;;;N;;;;0072;
006F;LATIN SMALL LETTER O;Ll;0;L;;;;;N;;;004F;;004F
0063;LATIN SMALL LETTER C;Ll;0;L;;;;;N;;;0043;;0043
006B;LATIN SMALL LETTER K;Ll;0;L;;;;;N;;;004B;;004B
0020;SPACE;Zs;0;WS;;;;;N;;;;;
006F;LATIN SMALL LETTER O;Ll;0;L;;;;;N;;;004F;;004F
006E;LATIN SMALL LETTER N;Ll;0;L;;;;;N;;;004E;;004E
002E;FULL STOP;Po;0;CS;;;;;N;PERIOD;;;;
0020;SPACE;Zs;0;WS;;;;;N;;;;;
1F918;SIGN OF THE HORNS;So;0;ON;;;;;N;;;;;
000A;<control>;Cc;0;B;;;;;N;LINE FEED (LF);;;;
END
        '',
        0,
        'Use char from Unicode 8.0',
    );

    # }}}
    testcmd("echo 🥓 FTW 🕺 | $CMD", # {{{
        <<'END',
1F953;BACON;So;0;ON;;;;;N;;;;;
0020;SPACE;Zs;0;WS;;;;;N;;;;;
0046;LATIN CAPITAL LETTER F;Lu;0;L;;;;;N;;;;0066;
0054;LATIN CAPITAL LETTER T;Lu;0;L;;;;;N;;;;0074;
0057;LATIN CAPITAL LETTER W;Lu;0;L;;;;;N;;;;0077;
0020;SPACE;Zs;0;WS;;;;;N;;;;;
1F57A;MAN DANCING;So;0;ON;;;;;N;;;;;
000A;<control>;Cc;0;B;;;;;N;LINE FEED (LF);;;;
END
        '',
        0,
        'Use chars from Unicode 9.0',
    );

    # }}}
    testcmd("echo The 🧟 wants 🧠, not 🥟 or ₿ | $CMD", # {{{
        <<'END',
0054;LATIN CAPITAL LETTER T;Lu;0;L;;;;;N;;;;0074;
0068;LATIN SMALL LETTER H;Ll;0;L;;;;;N;;;0048;;0048
0065;LATIN SMALL LETTER E;Ll;0;L;;;;;N;;;0045;;0045
0020;SPACE;Zs;0;WS;;;;;N;;;;;
1F9DF;ZOMBIE;So;0;ON;;;;;N;;;;;
0020;SPACE;Zs;0;WS;;;;;N;;;;;
0077;LATIN SMALL LETTER W;Ll;0;L;;;;;N;;;0057;;0057
0061;LATIN SMALL LETTER A;Ll;0;L;;;;;N;;;0041;;0041
006E;LATIN SMALL LETTER N;Ll;0;L;;;;;N;;;004E;;004E
0074;LATIN SMALL LETTER T;Ll;0;L;;;;;N;;;0054;;0054
0073;LATIN SMALL LETTER S;Ll;0;L;;;;;N;;;0053;;0053
0020;SPACE;Zs;0;WS;;;;;N;;;;;
1F9E0;BRAIN;So;0;ON;;;;;N;;;;;
002C;COMMA;Po;0;CS;;;;;N;;;;;
0020;SPACE;Zs;0;WS;;;;;N;;;;;
006E;LATIN SMALL LETTER N;Ll;0;L;;;;;N;;;004E;;004E
006F;LATIN SMALL LETTER O;Ll;0;L;;;;;N;;;004F;;004F
0074;LATIN SMALL LETTER T;Ll;0;L;;;;;N;;;0054;;0054
0020;SPACE;Zs;0;WS;;;;;N;;;;;
1F95F;DUMPLING;So;0;ON;;;;;N;;;;;
0020;SPACE;Zs;0;WS;;;;;N;;;;;
006F;LATIN SMALL LETTER O;Ll;0;L;;;;;N;;;004F;;004F
0072;LATIN SMALL LETTER R;Ll;0;L;;;;;N;;;0052;;0052
0020;SPACE;Zs;0;WS;;;;;N;;;;;
20BF;BITCOIN SIGN;Sc;0;ET;;;;;N;;;;;
000A;<control>;Cc;0;B;;;;;N;LINE FEED (LF);;;;
END
        '',
        0,
        'Use chars from Unicode 10.0',
    );

    # }}}
    testcmd("echo U̲l̲i̲n̲e̲ and s̶t̶r̶i̶k̶e̶. | $CMD", # {{{
        <<'END',
0055;LATIN CAPITAL LETTER U;Lu;0;L;;;;;N;;;;0075;
0332;COMBINING LOW LINE;Mn;220;NSM;;;;;N;NON-SPACING UNDERSCORE;;;;
006C;LATIN SMALL LETTER L;Ll;0;L;;;;;N;;;004C;;004C
0332;COMBINING LOW LINE;Mn;220;NSM;;;;;N;NON-SPACING UNDERSCORE;;;;
0069;LATIN SMALL LETTER I;Ll;0;L;;;;;N;;;0049;;0049
0332;COMBINING LOW LINE;Mn;220;NSM;;;;;N;NON-SPACING UNDERSCORE;;;;
006E;LATIN SMALL LETTER N;Ll;0;L;;;;;N;;;004E;;004E
0332;COMBINING LOW LINE;Mn;220;NSM;;;;;N;NON-SPACING UNDERSCORE;;;;
0065;LATIN SMALL LETTER E;Ll;0;L;;;;;N;;;0045;;0045
0332;COMBINING LOW LINE;Mn;220;NSM;;;;;N;NON-SPACING UNDERSCORE;;;;
0020;SPACE;Zs;0;WS;;;;;N;;;;;
0061;LATIN SMALL LETTER A;Ll;0;L;;;;;N;;;0041;;0041
006E;LATIN SMALL LETTER N;Ll;0;L;;;;;N;;;004E;;004E
0064;LATIN SMALL LETTER D;Ll;0;L;;;;;N;;;0044;;0044
0020;SPACE;Zs;0;WS;;;;;N;;;;;
0073;LATIN SMALL LETTER S;Ll;0;L;;;;;N;;;0053;;0053
0336;COMBINING LONG STROKE OVERLAY;Mn;1;NSM;;;;;N;NON-SPACING LONG BAR OVERLAY;;;;
0074;LATIN SMALL LETTER T;Ll;0;L;;;;;N;;;0054;;0054
0336;COMBINING LONG STROKE OVERLAY;Mn;1;NSM;;;;;N;NON-SPACING LONG BAR OVERLAY;;;;
0072;LATIN SMALL LETTER R;Ll;0;L;;;;;N;;;0052;;0052
0336;COMBINING LONG STROKE OVERLAY;Mn;1;NSM;;;;;N;NON-SPACING LONG BAR OVERLAY;;;;
0069;LATIN SMALL LETTER I;Ll;0;L;;;;;N;;;0049;;0049
0336;COMBINING LONG STROKE OVERLAY;Mn;1;NSM;;;;;N;NON-SPACING LONG BAR OVERLAY;;;;
006B;LATIN SMALL LETTER K;Ll;0;L;;;;;N;;;004B;;004B
0336;COMBINING LONG STROKE OVERLAY;Mn;1;NSM;;;;;N;NON-SPACING LONG BAR OVERLAY;;;;
0065;LATIN SMALL LETTER E;Ll;0;L;;;;;N;;;0045;;0045
0336;COMBINING LONG STROKE OVERLAY;Mn;1;NSM;;;;;N;NON-SPACING LONG BAR OVERLAY;;;;
002E;FULL STOP;Po;0;CS;;;;;N;PERIOD;;;;
000A;<control>;Cc;0;B;;;;;N;LINE FEED (LF);;;;
END
        '',
        0,
        'Display combining chars',
    );

    # }}}
    testcmd("echo feff 48 61 74 65 2e | fromhex -u | $CMD", # {{{
        <<'END',
FEFF;ZERO WIDTH NO-BREAK SPACE;Cf;0;BN;;;;;N;BYTE ORDER MARK;;;;
0048;LATIN CAPITAL LETTER H;Lu;0;L;;;;;N;;;;0068;
0061;LATIN SMALL LETTER A;Ll;0;L;;;;;N;;;0041;;0041
0074;LATIN SMALL LETTER T;Ll;0;L;;;;;N;;;0054;;0054
0065;LATIN SMALL LETTER E;Ll;0;L;;;;;N;;;0045;;0045
002E;FULL STOP;Po;0;CS;;;;;N;PERIOD;;;;
END
        '',
        0,
        'Display bloody BOM',
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
