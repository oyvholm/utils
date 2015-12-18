#!/usr/bin/env perl

#=======================================================================
# ga-fsck-size.t
# File ID: 4ac10522-2719-11e5-85fa-000df06acc56
#
# Test suite for ga-fsck-size(1).
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

our $CMD_BASENAME = "ga-fsck-size";
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

    diag("Initialise temprepo...");
    ok(chdir('ga-fsck-size-files'), 'chdir ga-fsck-size-files');
    testcmd('tar xzf annex-backends.tar.gz', '', '', 0, 'Untar annex-backends.tar.gz');

    ok(chdir('annex-backends'), 'chdir annex-backends');

    testcmd("git annex fsck 2>&1 | ../../$CMD", # {{{
       <<END,
fsck MD5.txt (checksum...) ok
fsck MD5E.txt (checksum...) ok
fsck SHA1.txt (checksum...) ok
fsck SHA1E.txt (checksum...) ok
fsck SHA224.txt (checksum...) ok
fsck SHA224E.txt (checksum...) ok
fsck SHA256.txt (checksum...) ok
fsck SHA256E.txt (checksum...) ok
fsck SHA384.txt (checksum...) ok
fsck SHA384E.txt (checksum...) ok
fsck SHA3_224.txt (checksum...) ok
fsck SHA3_224E.txt (checksum...) ok
fsck SHA3_256.txt (checksum...) ok
fsck SHA3_256E.txt (checksum...) ok
fsck SHA3_384.txt (checksum...) ok
fsck SHA3_384E.txt (checksum...) ok
fsck SHA3_512.txt (checksum...) ok
fsck SHA3_512E.txt (checksum...) ok
fsck SHA512.txt (checksum...) ok
fsck SHA512E.txt (checksum...) ok
fsck SKEIN256.txt (checksum...) ok
fsck SKEIN256E.txt (checksum...) ok
fsck SKEIN512.txt (checksum...) ok
fsck SKEIN512E.txt (checksum...) ok
fsck WORM.txt ok
(recording state in git...)

Total size of files that need more copies: 0
Total space needed to get enough copies  : 0
END
        '',
        0,
        "Filter 'git annex fsck' through $CMD"
    );

    # }}}
    likecmd("git annex fsck --numcopies=2 2>&1 | ../../$CMD", # {{{
        (
            '/^' .
            'fsck MD5.txt \(checksum...\)' .
            '.+' .
            'Only 1 of 2 trustworthy copies exist of MD5\.txt \(4(\.0)? bytes\)\n' .
            'failed\n' .
            '.+' .
            'Only 1 of 2 trustworthy copies exist of SHA256\.txt \(7(\.0)? bytes\)\n' .
            'failed\n' .
            '.+' .
            'git-annex: fsck: 25 failed\n' .
            '\n' .
            'Total size of files that need more copies: 199\n' .
            'Total space needed to get enough copies  : 199\n' .
            '$/s'
        ),
        '/^$/',
        0,
        "Copies missing when numcopies=2",
    );

    # }}}

    ok(chdir('..'), 'chdir ..');

    diag('Clean up temporary files...');
    testcmd('chmod -R +w annex-backends', '', '', 0, 'chmod everything under annex-backends/ to +write');
    testcmd('rm -rf annex-backends', '', '', 0, 'Delete temp repo');
    ok(!-e 'annex-backends', 'annex-backends is gone');

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
