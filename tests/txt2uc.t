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
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMD = '../txt2uc';

our %Opt = (

    'all' => 0,
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
    'help|h' => \$Opt{'help'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

exit(main(%Opt));

sub main {
    # {{{
    my %Opt = @_;
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
        '/  Show this help\./',
        '/^$/',
        0,
        'Option -h prints help screen',
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
    # }}}
} # main()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'txt2uc-stderr.tmp';

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
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
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'txt2uc-stderr.tmp';

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        like(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
        unlink($TMP_STDERR);
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

Contains tests for the txt2uc(1) program.

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

txt2uc.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the txt2uc(1) program.

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

=back

=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your 
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
