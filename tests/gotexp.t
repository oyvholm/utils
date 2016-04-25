#!/usr/bin/env perl

#=======================================================================
# gotexp.t
# File ID: 1af95184-2988-11e5-a2f9-000df06acc56
#
# Test suite for gotexp(1).
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

our $CMD_BASENAME = "gotexp";
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

    ok(chdir('gotexp-files'), 'chdir gotexp-files') || BAIL_OUT('Could not chdir');
    testcmd("../$CMD <output1.txt", # {{{
        '',
        '',
        0,
        'Use output1.txt as stdin',
    );

    # }}}

    my $op1_1_got = <<END;
not ok 11 - "../../conv-suuid test.xml" - Read test.xml (stdout)
'<suuid t="2015-06-14T02:34:41.5608070Z" u="e8f90906-123d-11e5-81a8-000df06acc56"> <tag>std</tag> <txt>std -l python suuids-to-postgres.py</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/4</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-14T02:51:50.4477750Z" u="4e3cba36-1240-11e5-ab4e-000df06acc56"> <tag>ti</tag> <tag>another</tag> <txt>Yo mainn.</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/13</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-21T10:49:19.2036620Z" u="2b1e350c-1803-11e5-9c66-000df06acc56"> <txt>Weird characters: \\ ' ; &lt; &gt; "</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/tests</cwd> <user>sunny</user> <tty>/dev/pts/15</tty> <sess desc="xterm">edcbd7d8-16ca-11e5-9739-000df06acc56</sess> <sess desc="logging">03a706ae-16cb-11e5-becb-000df06acc56</sess> <sess desc="screen">088f9e56-16cb-11e5-a56c-000df06acc56</sess> </suuid>
# <suuid t="2015-07-14T02:07:50.9817960Z" u="2162ae68-29cd-11e5-aa3e-000df06acc56"> </suuid>
# '
END
    my $op1_1_exp = <<END;
not ok 11 - "../../conv-suuid test.xml" - Read test.xml (stdout)
'<suuid t="2015-06-14T02:34:41.5608070Z" u="e8f90906-123d-11e5-81a8-000df06acc56"> <tag>std</tag> <txt>std -l python suuids-to-postgres.py</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/4</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-14T02:51:50.4477750Z" u="4e3cba36-1240-11e5-ab4e-000df06acc56"> <tag>ti</tag> <tag>another</tag> <txt>Yo mainn.</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/13</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-21T10:49:19.2036620Z" u="2b1e350c-1803-11e5-9c66-000df06acc56"> <txt>Weird characters: \\\\ '' ; &lt; &gt; "</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/tests</cwd> <user>sunny</user> <tty>/dev/pts/15</tty> <sess desc="xterm">edcbd7d8-16ca-11e5-9739-000df06acc56</sess> <sess desc="logging">03a706ae-16cb-11e5-becb-000df06acc56</sess> <sess desc="screen">088f9e56-16cb-11e5-a56c-000df06acc56</sess> </suuid>
# <suuid t="2015-07-14T02:07:50.9817960Z" u="2162ae68-29cd-11e5-aa3e-000df06acc56"> </suuid>
# '
END
    my $op1_2_got = <<END;
not ok 14 - "../../conv-suuid -o xml test.xml" - Output XML format (stdout)
'<suuid t="2015-06-14T02:34:41.5608070Z" u="e8f90906-123d-11e5-81a8-000df06acc56"> <tag>std</tag> <txt>std -l python suuids-to-postgres.py</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/4</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-14T02:51:50.4477750Z" u="4e3cba36-1240-11e5-ab4e-000df06acc56"> <tag>ti</tag> <tag>another</tag> <txt>Yo mainn.</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/13</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-21T10:49:19.2036620Z" u="2b1e350c-1803-11e5-9c66-000df06acc56"> <txt>Weird characters: \\ ' ; &lt; &gt; "</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/tests</cwd> <user>sunny</user> <tty>/dev/pts/15</tty> <sess desc="xterm">edcbd7d8-16ca-11e5-9739-000df06acc56</sess> <sess desc="logging">03a706ae-16cb-11e5-becb-000df06acc56</sess> <sess desc="screen">088f9e56-16cb-11e5-a56c-000df06acc56</sess> </suuid>
# <suuid t="2015-07-14T02:07:50.9817960Z" u="2162ae68-29cd-11e5-aa3e-000df06acc56"> </suuid>
# '
END
    my $op1_2_exp = <<END;
not ok 14 - "../../conv-suuid -o xml test.xml" - Output XML format (stdout)
'<suuid t="2015-06-14T02:34:41.5608070Z" u="e8f90906-123d-11e5-81a8-000df06acc56"> <tag>std</tag> <txt>std -l python suuids-to-postgres.py</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/4</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-14T02:51:50.4477750Z" u="4e3cba36-1240-11e5-ab4e-000df06acc56"> <tag>ti</tag> <tag>another</tag> <txt>Yo mainn.</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/postgres</cwd> <user>sunny</user> <tty>/dev/pts/13</tty> <sess desc="xterm">f923e8fc-11e6-11e5-913a-000df06acc56</sess> <sess desc="logging">09733f50-11e7-11e5-a1ac-000df06acc56</sess> <sess>0bb564f0-11e7-11e5-bc0c-000df06acc56</sess> </suuid>
# <suuid t="2015-06-21T10:49:19.2036620Z" u="2b1e350c-1803-11e5-9c66-000df06acc56"> <txt>Weird characters: \\\\ '' ; &lt; &gt; "</txt> <host>bellmann</host> <cwd>/home/sunny/src/git/.er_ikke_i_bellmann/utils.dev/Git/suuid/tests</cwd> <user>sunny</user> <tty>/dev/pts/15</tty> <sess desc="xterm">edcbd7d8-16ca-11e5-9739-000df06acc56</sess> <sess desc="logging">03a706ae-16cb-11e5-becb-000df06acc56</sess> <sess desc="screen">088f9e56-16cb-11e5-a56c-000df06acc56</sess> </suuid>
# <suuid t="2015-07-14T02:07:50.9817960Z" u="2162ae68-29cd-11e5-aa3e-000df06acc56"> </suuid>
# '
END

    is(file_data('got'), $op1_1_got, "Check contents of 'got'");
    is(file_data('exp'), $op1_1_exp, "Check contents of 'exp'");
    testcmd("../$CMD -n 2 output1.txt", # {{{
        '',
        '',
        0,
        'Use second error in output1.txt',
    );

    # }}}
    is(file_data('got'), $op1_2_got, "Second check of 'got'");
    is(file_data('exp'), $op1_2_exp, "'exp' checked the second time");

    ok(unlink('got'), "Delete 'got'");
    ok(unlink('exp'), "Delete 'exp'");

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
