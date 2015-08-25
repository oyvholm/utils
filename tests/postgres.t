#!/usr/bin/env perl

#=======================================================================
# postgres.t
# File ID: 6c8dbc38-3b85-11e5-9db6-000df06acc56
#
# Test suite for postgres(1).
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

our $CMD = '../postgres';

our %Opt = (

    'all' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.0.0';

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

my $tmpdb = "tmp-postgres-t-$$-" . substr(rand, 2, 8);
my $tmp_stdout = '.tmp-postgres-t-stdout.tmp';
my $tmp_stderr = '.tmp-postgres-t-stderr.tmp';

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

    testcmd("createdb \"$tmpdb\"", # {{{
        '',
        '',
        0,
        'Create temporary database',
    ) && BAIL_OUT("Cannot create temporary database, " .
                  "not much point in going on, then");

    # }}}
    diag('Make sure the db sorting uses C locale');
    psql_cmd($tmpdb, # {{{
        <<END,
CREATE TABLE t (s varchar);
COPY t FROM stdin;
f
gh
ß
ser
a
o
æ
øæ
å

ØØØØHH
12
ÆØ
ÅØÆ
→
O
©
X
Y
x
y
🤘
❤
☮
A
B
indeed
\\.
END
        '/^' .
            'CREATE TABLE\n' .
            'COPY 27\n' .
            '$/',
        '/^$/',
        'Insert unsorted text into db',
    );

    # }}}
    psql_cmd($tmpdb, # {{{
        'COPY (SELECT * FROM t ORDER BY s) TO stdout;',
        '/^' .
            '\n' .
            '12\n' .
            'A\n' .
            'B\n' .
            'O\n' .
            'X\n' .
            'Y\n' .
            'a\n' .
            'f\n' .
            'gh\n' .
            'indeed\n' .
            'o\n' .
            'ser\n' .
            'x\n' .
            'y\n' .
            '©\n' .
            'ÅØÆ\n' .
            'ÆØ\n' .
            'ØØØØHH\n' .
            'ß\n' .
            'å\n' .
            'æ\n' .
            'øæ\n' .
            '→\n' .
            '☮\n' .
            '❤\n' .
            '🤘\n' .
            '$/',
        '/^$/',
        'Text sorting follows the Unicode table',
    );

    # }}}
    diag('Cleaning up...');
    ok(unlink($tmp_stdout), 'Delete stdout tmpfile');
    ok(unlink($tmp_stderr), 'Delete stderr tmpfile');
    testcmd("dropdb \"$tmpdb\"", # {{{
        '',
        '',
        0,
        'Drop temporary database',
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

sub psql_cmd {
    # {{{
    my ($db, $sql, $exp_stdout, $exp_stderr, $desc) = @_;
    ok(open(my $dbpipe, "| psql -X -d \"$tmpdb\" >$tmp_stdout 2>$tmp_stderr"),
        "Open db pipe ($desc)");
    ok(print($dbpipe $sql), "Print to pipe ($desc)");
    ok(close($dbpipe), "Close db pipe ($desc)");
    like(file_data($tmp_stdout), $exp_stdout, "$desc (stdout)");
    like(file_data($tmp_stderr), $exp_stderr, "$desc (stderr)");
    return;
    # }}}
} # psql_cmd()

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
    $Txt =~ s/$tmpdb/\[tmpdb\]/g;
    my $TMP_STDERR = 'postgres-stderr.tmp';

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
    return($ret_val >> 8);
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
    $Txt =~ s/$tmpdb/\[tmpdb\]/g;
    my $TMP_STDERR = 'postgres-stderr.tmp';

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
    return($ret_val >> 8);
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

Contains tests for the postgres(1) program.

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

postgres.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the postgres(1) program.

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
