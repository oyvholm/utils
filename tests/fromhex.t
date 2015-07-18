#!/usr/bin/perl

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
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $Debug = 0;
our $CMD = '../fromhex';

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
our $VERSION = '0.00';

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
    diag('Testing -v (--verbose) option...');
    likecmd("$CMD -hv", # {{{
        '/^\n\S+ v\d\.\d\d\n/s',
        '/^$/',
        0,
        'Option --version with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ v\d\.\d\d\n/',
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
        '/Unicode .* illegal/',
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
        '/Unicode .* illegal/',
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
    # }}}
} # main()

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
    my $TMP_STDERR = 'fromhex-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
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
    my $TMP_STDERR = 'fromhex-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
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

Contains tests for the fromhex(1) program.

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

fromhex.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the fromhex(1) program.

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
