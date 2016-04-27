#!/usr/bin/env perl

#=======================================================================
# ga-sumsize.t
# File ID: e64cce20-5619-11e5-a28a-000df06acc56
#
# Test suite for ga-sumsize(1).
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

our $CMD_BASENAME = "ga-sumsize";
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
our $VERSION = '0.1.1';

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
        '/^\n\S+ \d+\.\d+\.\d+\b\S*\n/s',
        '/^$/',
        0,
        'Option -v with -h returns version number and help screen',
    );

    # }}}
    diag('Testing --version option...');
    likecmd("$CMD --version", # {{{
        '/^\S+ \d+\.\d+\.\d+\b\S*\n/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}

    testcmd("$CMD </dev/null", # {{{
        "\nga-sumsize: Total size of keys: 0 (0)\n",
        '',
        0,
        'Read empty input from stdin',
    );

    # }}}
    testcmd("$CMD /dev/null", # {{{
        "\nga-sumsize: Total size of keys: 0 (0)\n",
        '',
        0,
        'Read directly from /dev/null',
    );

    # }}}
    testcmd("$CMD ga-sumsize-files/1.txt", # {{{
        <<END,
unused . (checking for unused data...) (checking master...)
  Some annexed data is no longer used by any files:
    NUMBER  KEY
    1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
    2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
    3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
    4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
  (To see where data was previously used, try: git log --stat -S'KEY')

  To remove unwanted data: git-annex dropunused NUMBER

ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Read from 1.txt',
    );

    # }}}
    testcmd("$CMD <ga-sumsize-files/1.txt", # {{{
        <<END,
unused . (checking for unused data...) (checking master...)
  Some annexed data is no longer used by any files:
    NUMBER  KEY
    1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
    2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
    3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
    4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
  (To see where data was previously used, try: git log --stat -S'KEY')

  To remove unwanted data: git-annex dropunused NUMBER

ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Read from 1.txt via stdin',
    );

    # }}}
    testcmd("$CMD --display ga-sumsize-files/1.txt", # {{{
        <<END,
0 unused . (checking for unused data...) (checking master...)
0   Some annexed data is no longer used by any files:
0     NUMBER  KEY
487883366     1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
972190509     2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
1462668990     3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
1948027876     4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
1948027876   (To see where data was previously used, try: git log --stat -S'KEY')
1948027876 
1948027876   To remove unwanted data: git-annex dropunused NUMBER
1948027876 
1948027876 ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Test --display option',
    );

    # }}}
    testcmd("$CMD -d ga-sumsize-files/1.txt", # {{{
        <<END,
0 unused . (checking for unused data...) (checking master...)
0   Some annexed data is no longer used by any files:
0     NUMBER  KEY
487883366     1       SHA256-s487883366--2125edd12f347e19dc9d5c2c2f4cee14b44f9cbba1ea46ff8af54ae020c58563
972190509     2       SHA256-s484307143--049e14e3af3bf9aece17ddab008b3cb9be6ab0fb42c91e6ad383364d26b3ffa7
1462668990     3       SHA256-s490478481--12453004cbf74f56adf115f9da32d2b783c9c967469668dbf0f88b85efc856b8
1948027876     4       SHA256-s485358886--bf6c061f378e04d6f45a95e13412aabc4c420a714cfebe7ab70034b72605bc47
1948027876   (To see where data was previously used, try: git log --stat -S'KEY')
1948027876 
1948027876   To remove unwanted data: git-annex dropunused NUMBER
1948027876 
1948027876 ok

ga-sumsize: Total size of keys: 1948027876 (1.9G)
END
        '',
        0,
        'Test -d option',
    );

    # }}}
    ok(chdir("ga-sumsize-files"), "chdir ga-sumsize-files");
    likecmd("tar xvzf ga-sumsize-repo.tar.gz", # {{{
        '/^8aef4e74-7976-11e5-910f-fefdb24f8e10\nga-sumsize-repo\/\n.+$/s',
        '/^$/s',
        0,
        "Untar ga-sumsize-repo.tar.gz",
    );

    # }}}
    ok(chdir("ga-sumsize-repo"), "chdir ga-sumsize-repo");
    likecmd("ga unused", # {{{
        '/^.+' .
            '(' .
                'SHA256-s1000--541b3e9daa09b20bf85fa273e5cbd3e80185aa4ec298e765db87742b70138a53\n' .
                '.+' .
                'SHA256-s123--409a7f83ac6b31dc8c77e3ec18038f209bd2f545e0f4177c2e2381aa4e067b49\n' .
            '|' .
                'SHA256-s123--409a7f83ac6b31dc8c77e3ec18038f209bd2f545e0f4177c2e2381aa4e067b49\n' .
                '.+' .
                'SHA256-s1000--541b3e9daa09b20bf85fa273e5cbd3e80185aa4ec298e765db87742b70138a53\n' .
            ')' .
            '.+' .
            'ga-sumsize: Total size of keys: 1123 \(1\.1K\)\n' .
            '$/s',
        '/^$/s',
        0,
        "ga unused",
    );

    # }}}
    ok(chdir(".."), "chdir ..");
    testcmd("chmod -R +w \"ga-sumsize-repo\"", # {{{
        "",
        "",
        0,
        "chmod -R +w ga-sumsize-repo"
    );

    # }}}
    testcmd("rm -rf \"ga-sumsize-repo\"", # {{{
        "",
        "",
        0,
        "rm -rf ga-sumsize-repo",
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
