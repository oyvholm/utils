#!/usr/bin/env perl

#=======================================================================
# wi.t
# File ID: 66726d84-2fdd-11e5-9bf9-000df06acc56
#
# Test suite for wi(1).
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

our $CMD = '../wi --test-simul';

our %Opt = (

    'all' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.0.1';

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
        '/^\S+ v\d+.\d+\.\d+(\+git)?\n/',
        '/^$/',
        0,
        'Option --version returns version number',
    );

    # }}}
    diag('Read from stdin...');
    testcmd("$CMD </dev/null", # {{{
        '',
        "wi: No search strings found\n",
        1,
        'Read from /dev/null with no arguments',
    );

    # }}}
    testcmd("echo jeppec3a1814-2feb-11e5-a5f7-bd3e22fb78992345234553ed5c0a-cbf4-4878-91ae-9dc97431793daaa | $CMD", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%ec3a1814-2feb-11e5-a5f7-bd3e22fb7899%' OR s::varchar LIKE '%53ed5c0a-cbf4-4878-91ae-9dc97431793d%') TO STDOUT;\n",
        <<END,
f = 'ec3a1814-2feb-11e5-a5f7-bd3e22fb7899'
f = '53ed5c0a-cbf4-4878-91ae-9dc97431793d'
END
        0,
        'Search for UUIDs found in stdin',
    );

    # }}}
    diag('Search for command line arguments...');
    testcmd("$CMD abc", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%') TO STDOUT;\n",
        "f = 'abc'\n",
        0,
        'Single argument specified',
    );

    # }}}
    testcmd("$CMD abc def", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' OR s::varchar LIKE '%def%') TO STDOUT;\n",
        <<END,
f = 'abc'
f = 'def'
END
        0,
        'Two arguments specified, use OR as default',
    );

    # }}}
    testcmd("$CMD abc def 'with space'", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' OR s::varchar LIKE '%def%' OR s::varchar LIKE '%with space%') TO STDOUT;\n",
        <<END,
f = 'abc'
f = 'def'
f = 'with space'
END
        0,
        'Three args, the last one contains space',
    );

    # }}}
    testcmd("$CMD abc def ' with space '", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' OR s::varchar LIKE '%def%' OR s::varchar LIKE '% with space %') TO STDOUT;\n",
        <<END,
f = 'abc'
f = 'def'
f = ' with space '
END
        0,
        'Three args, one with surrounding space',
    );

    # }}}
    diag("Test -a (AND) and -o (OR)...");
    testcmd("$CMD abc -o def", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' OR s::varchar LIKE '%def%') TO STDOUT;\n",
        <<END,
f = 'abc'
f = '-o'
andor set to OR
f = 'def'
END
        0,
        'Use -o, but that\'s default anyway',
    );

    # }}}
    testcmd("$CMD -a abc def", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' AND s::varchar LIKE '%def%') TO STDOUT;\n",
        <<END,
f = '-a'
andor set to AND
f = 'abc'
f = 'def'
END
        0,
        '-a specified first, use AND from now on',
    );

    # }}}
    testcmd("$CMD abc -a def", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' AND s::varchar LIKE '%def%') TO STDOUT;\n",
        <<END,
f = 'abc'
f = '-a'
andor set to AND
f = 'def'
END
        0,
        'Use AND between args',
    );

    # }}}
    testcmd("$CMD abc -a def -o ghi", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' AND s::varchar LIKE '%def%' OR s::varchar LIKE '%ghi%') TO STDOUT;\n",
        <<END,
f = 'abc'
f = '-a'
andor set to AND
f = 'def'
f = '-o'
andor set to OR
f = 'ghi'
END
        0,
        '-a and -o between args',
    );

    # }}}
    testcmd("$CMD abc -o -a def -a -o ghi", # {{{
        "COPY (SELECT s FROM uuids WHERE s::varchar LIKE '%abc%' AND s::varchar LIKE '%def%' OR s::varchar LIKE '%ghi%') TO STDOUT;\n",
        <<END,
f = 'abc'
f = '-o'
andor set to OR
f = '-a'
andor set to AND
f = 'def'
f = '-a'
andor set to AND
f = '-o'
andor set to OR
f = 'ghi'
END
        0,
        '-a followed by -o and vice versa',
    );

    # }}}
    testcmd("$CMD abc def -a ghi jkl mno -o pqr", # {{{
        "COPY (SELECT s FROM uuids WHERE " .
            "s::varchar LIKE '%abc%' OR " .
            "s::varchar LIKE '%def%' AND " .
            "s::varchar LIKE '%ghi%' AND " .
            "s::varchar LIKE '%jkl%' AND " .
            "s::varchar LIKE '%mno%' OR " .
            "s::varchar LIKE '%pqr%'" .
        ") TO STDOUT;\n",
        <<END,
f = 'abc'
f = 'def'
f = '-a'
andor set to AND
f = 'ghi'
f = 'jkl'
f = 'mno'
f = '-o'
andor set to OR
f = 'pqr'
END
        0,
        'Several args with no -a or -o between',
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
    my $TMP_STDERR = 'wi-stderr.tmp';

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
    my $TMP_STDERR = 'wi-stderr.tmp';

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

Contains tests for the wi(1) program.

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

wi.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the wi(1) program.

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
