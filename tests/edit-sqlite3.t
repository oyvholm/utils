#!/usr/bin/env perl

#=======================================================================
# edit-sqlite3.t
# File ID: dd33f796-6a8c-11e5-8a5b-fefdb24f8e10
#
# Test suite for edit-sqlite3(1).
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

my $CMD_BASENAME = 'edit-sqlite3';

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
    my $CMD = "../$CMD_BASENAME";
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
    likecmd('sqlite3 --version', # {{{
        '/^\d+\.\d+.+/',
        '/^$/',
        0,
        'sqlite3 is available',
    ) || BAIL_OUT('sqlite3 is not available');

    # }}}
    ok(chdir('edit-sqlite3-files'), 'chdir edit-sqlite3-files');
    testcmd("tar xvzf sqlite-databases.tar.gz", # {{{
        <<'END',
787a43c8-6adc-11e5-a8ef-fefdb24f8e10
sqlite-databases/
sqlite-databases/ok.sqlite
sqlite-databases/invalid.sqlite
END
        '',
        0,
        'Untar sqlite-databases.tar.gz',
    );

    # }}}
    $CMD = "../$CMD";
    testcmd("$CMD", # {{{
        '',
        "edit-sqlite3: No SQLite database specified\n",
        1,
        'No database specified',
    );

    # }}}
    testcmd("$CMD nonexisting_db", # {{{
        '',
        "edit-sqlite3: nonexisting_db: File not found or is not a regular file\n",
        1,
        'Non-existing database specified',
    );

    # }}}
    testcmd("$CMD sqlite-databases", # {{{
        '',
        "edit-sqlite3: sqlite-databases: File not found or is not a regular file\n",
        1,
        'Specify directory as SQLite database',
    );

    # }}}
    ok(chdir('sqlite-databases'), 'chdir sqlite-databases');
    $CMD = "../$CMD";
    testcmd("$CMD -n ok.sqlite", # {{{
        "ok\n",
        "edit-sqlite3: ok.sqlite: File would be edited\n",
        0,
        'Specify valid SQLite database with -n',
    );

    # }}}
    testcmd("$CMD --dry-run invalid.sqlite", # {{{
        '',
        <<'END',
Error: file is encrypted or is not a database
edit-sqlite3: invalid.sqlite: SQLite database contains errors
END
        1,
        'Specify invalid SQLite db with --dry-run',
    );

    # }}}
    diag('Test file permissions...');
    ok(chmod(0444, 'ok.sqlite'), 'Make ok.sqlite read-only');
    testcmd("$CMD ok.sqlite", # {{{
        '',
        "edit-sqlite3: ok.sqlite: File is not writable by you\n",
        1,
        'File is not writable, abort',
    );

    # }}}
    ok(chmod(0222, 'ok.sqlite'), 'Make ok.sqlite unreadable');
    testcmd("$CMD ok.sqlite", # {{{
        '',
        "edit-sqlite3: ok.sqlite: File is not readable by you\n",
        1,
        'File is not readable, abort',
    );

    # }}}
    ok(chmod(0000, 'ok.sqlite'), 'Make ok.sqlite unreadable and unwritable');
    testcmd("$CMD ok.sqlite", # {{{
        '',
        "edit-sqlite3: ok.sqlite: File is not readable by you\n",
        1,
        'File is not readable nor writable, abort',
    );

    # }}}
    ok(chmod(0644, 'ok.sqlite'), 'Restore permissions of ok.sqlite');
    diag('Abort if the file is a symlink...');
    ok(symlink('ok.sqlite', 'symlink-to-file.sqlite'), 'Create symlink to ok.sqlite');
    testcmd("$CMD -n symlink-to-file.sqlite", # {{{
        '',
        "edit-sqlite3: symlink-to-file.sqlite: File is a symlink\n",
        1,
        'File is a symlink to a regular file, abort',
    );

    # }}}
    ok(unlink('symlink-to-file.sqlite'), 'Delete symlink-to-file.sqlite');
    ok(symlink('.', 'symlink-to-dir.sqlite'), 'Create symlink to \'.\'');
    testcmd("$CMD --dry-run symlink-to-dir.sqlite", # {{{
        '',
        "edit-sqlite3: symlink-to-dir.sqlite: File is a symlink\n",
        1,
        'File is a symlink to a directory, abort',
    );

    # }}}
    ok(unlink('symlink-to-dir.sqlite'), 'Delete symlink-to-dir.sqlite');
    ok(symlink('nonexisting', 'symlink-to-nonexisting.sqlite'), 'Create symlink to nonexisting');
    testcmd("$CMD --dry-run symlink-to-nonexisting.sqlite", # {{{
        '',
        "edit-sqlite3: symlink-to-nonexisting.sqlite: File is a symlink\n",
        1,
        'File is a symlink to a non-existing file, abort',
    );

    # }}}
    ok(unlink('symlink-to-nonexisting.sqlite'), 'Delete symlink-to-nonexisting.sqlite');
    diag('Test empty and undefined $EDITOR environment variable...');
    $ENV{'EDITOR'} = '';
    testcmd("$CMD ok.sqlite", # {{{
        '',
        "edit-sqlite3: \$EDITOR environment variable is not defined\n",
        1,
        '$EDITOR environment variable is empty',
    );

    # }}}
    $ENV{'EDITOR'} = undef;
    testcmd("$CMD ok.sqlite", # {{{
        '',
        "edit-sqlite3: \$EDITOR environment variable is not defined\n",
        1,
        '$EDITOR environment variable is undefined',
    );

    # }}}
    diag('Test without --dry-run...');
    $ENV{'EDITOR'} = 'cat';
    testcmd("$CMD invalid.sqlite", # {{{
        '',
        <<'END',
Error: file is encrypted or is not a database
edit-sqlite3: invalid.sqlite: SQLite database contains errors
END
        1,
        'Specify invalid SQLite db without --dry-run',
    );

    # }}}
    testcmd("$CMD ok.sqlite", # {{{
        <<'END',
ok
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE t (a integer);
COMMIT;
END
        '',
        0,
        'Valid db without --dry-run',
    );

    # }}}
    is(file_data('ok.sqlite.1443959539.bck'), file_data('ok.sqlite'), # {{{
        'Backup file is identical to ok.sqlite',
    );

    # }}}
    ok(unlink('ok.sqlite.1443959539.bck'), 'Remove backup file');
    create_file('ok.sqlite.sql', <<END); # {{{
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
dCREATE TABLE t (a integer);
COMMIT;
END

# }}}
    testcmd("echo q | $CMD ok.sqlite", # {{{
        <<'END',
ok
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
dCREATE TABLE t (a integer);
COMMIT;
END
        "Error: near line 3: near \"dCREATE\": syntax error\n" .
            "edit-sqlite3: Press Enter to edit again, or q to abort...",
        0,
        'Display "edit again" message if invalid SQL',
    );

    # }}}
    ok(unlink('ok.sqlite.sql'), 'Delete ok.sqlite.sql');
    my $bckfile = glob('ok.sqlite.*.bck');
    ok(unlink($bckfile), 'Delete backup file');
    diag('Clean up...');
    ok(unlink('invalid.sqlite'), 'Delete invalid.sqlite');
    ok(unlink('ok.sqlite'), 'Delete ok.sqlite');
    ok(chdir('..'), 'chdir ..');
    ok(rmdir('sqlite-databases'), 'rmdir sqlite-databases');

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
    my $TMP_STDERR = 'edit-sqlite3-stderr.tmp';
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
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'edit-sqlite3-stderr.tmp';
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

sub create_file {
    # Create new file and fill it with data {{{
    my ($file, $text) = @_;
    my $retval = 0;
    if (open(my $fp, ">$file")) {
        print($fp $text);
        close($fp);
        $retval = is(
            file_data($file),
            $text,
            "$file was successfully created",
        );
    }
    return($retval); # 0 if error, 1 if ok
    # }}}
} # create_file()

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

Contains tests for the edit-sqlite3(1) program.

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

edit-sqlite3.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the edit-sqlite3(1) program.

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