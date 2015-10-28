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
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMD = '../gotexp';

our %Opt = (

    'all' => 0,
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
    my $TMP_STDERR = 'gotexp-stderr.tmp';

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
    my $TMP_STDERR = 'gotexp-stderr.tmp';

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

Contains tests for the gotexp(1) program.

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

gotexp.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the gotexp(1) program.

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
