#!/usr/bin/env perl

#=======================================================================
# std.t
# File ID: 685626fa-f988-11dd-af37-000475e441b9
#
# Test suite for std(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
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
use Cwd;

local $| = 1;

our $CMD_BASENAME = "std";
our $CMD = "../$CMD_BASENAME";
my $SQLITE = "sqlite3";
my $Lh = "[0-9a-fA-F]";
my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";

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
our $VERSION = '0.5.0';

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

    # FIXME: Create Git repostory to test things properly, for example 
    # that --dbname=none doesn't create a database.
    my $Tmptop = "tmp-std-t-$$-" . substr(rand, 2, 8);
    diag("Creating tempdir...");
    mkdir($Tmptop) ||
        die("$progname: $Tmptop: Cannot create directory: $!\n");
    chdir($Tmptop) || die("$progname: $Tmptop: Cannot chdir(): $!");
    mkdir("tmpuuids") ||
        die("$progname: $Tmptop/tmpuuids: Cannot mkdir(): $!");
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD bash", # {{{
        '/GNU General Public License/s',
        '/^std: Warning: Undefined tags: filename\n$/s',
        0,
        "One argument sends file to stdout",
    );

    # }}}
    my $suuid_file = glob("tmpuuids/*");
    ok(-e $suuid_file, "suuid log file exists");
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD --dbname none " .
        "bash bash-no-db", # {{{
        "/^$v1_templ\\n\$/s",
        '/^' .
            '$/',
        0,
        "--dbname none",
    );

    # }}}
    ok(-e "bash-no-db", "bash-no-db exists");
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD bash -d ./db.sqlite " .
            "bashfile", # {{{
        "/^$v1_templ\\n\$/s",
        '/^std: Creating database \'./db.sqlite\'\n$/',
        0,
        "Create bash script",
    );
    # }}}
    ok(-e "bashfile", "bashfile exists");
    ok(-x "bashfile", "bashfile is executable");
    ok(-e "db.sqlite", "db.sqlite exists");
    my $orig_dir = getcwd();
    # FIXME: Hardcoding of directory
    unless (chdir("$ENV{'HOME'}/bin")) {
        BAIL_OUT("$progname: $ENV{'HOME'}/bin: chdir error");
    }
    chomp(my $commit = `git rev-parse HEAD`);
    unless (chdir($orig_dir)) {
        BAIL_OUT("$progname: $orig_dir: chdir error");
    }
    like(sqlite_dump("db.sqlite"), # {{{
        '/^' .
            'PRAGMA foreign_keys=OFF;\n' .
            'BEGIN TRANSACTION;\n' .
            'CREATE TABLE synced \(\n' .
            '  file TEXT\n' .
            '    CONSTRAINT synced_file_length\n' .
            '      CHECK \(length\(file\) > 0\)\n' .
            '    UNIQUE\n' .
            '    NOT NULL\n' .
            '  ,\n' .
            '  orig TEXT\n' .
            '  ,\n' .
            '  rev TEXT\n' .
            '    CONSTRAINT synced_rev_length\n' .
            '      CHECK \(length\(rev\) = 40 OR rev = \'\'\)\n' .
            '  ,\n' .
            '  date TEXT\n' .
            '    CONSTRAINT synced_date_length\n' .
            '      CHECK \(date IS NULL OR length\(date\) = 19\)\n' .
            '    CONSTRAINT synced_date_valid\n' .
            '      CHECK \(date IS NULL OR datetime\(date\) IS NOT NULL\)\n' .
            '\);\n' .
            'INSERT INTO "synced" ' .
            'VALUES\(\'tests/tmp-std-t-\d+-\d+/bashfile\',' .
            '\'Lib/std/bash\',\'' .
            $commit .
            '\',' .
            '\'\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\'\);\n' .
            'CREATE TABLE todo \(\n' .
            '  file TEXT\n' .
            '    CONSTRAINT todo_file_length\n' .
            '      CHECK\(length\(file\) > 0\)\n' .
            '    UNIQUE\n' .
            '    NOT NULL\n' .
            '  ,\n' .
            '  pri INTEGER\n' .
            '    CONSTRAINT todo_pri_range\n' .
            '      CHECK\(pri BETWEEN 1 AND 5\)\n' .
            '  ,\n' .
            '  comment TEXT\n' .
            '\);\n' .
            'COMMIT;\n' .
            '$/',
        "db.sqlite looks ok",
    );

    # }}}
    diag("Check for unused tags...");
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD perl-tests", # {{{
        '/^.*Contains tests for the.*$/s',
        '/^std: Warning: Undefined tags: filename progname\n$/s',
        0,
        "Report unused tags",
    );

    # }}}
    diag("Testing -f (--force) option...");
    likecmd("../$CMD --database ./db.sqlite bash bashfile", # {{{
        '/^$/s',
        '/^' .
            'std: The --database option is obsolete and ' .
            'will be removed soon,\n' .
            'std: Please use --dbname instead\n' .
            'std: bashfile: File already exists, will not overwrite\n' .
            '$/s',
        1,
        "Create bash script, file already exists, don’t use --force",
    );

    # }}}
    # FIXME: Remove this when --database goes out the window
    testcmd("../$CMD --database ./db.sqlite --dbname ./db2.sqlite " .
            "bash bashfile", # {{{
        "",
        "std: Cannot use both --database and --dbname, " .
        "please use --dbname only\n",
        1,
        "--database and --dbname used at the same time",
    );

    # }}}
    likecmd("LC_ALL=C SUUID_LOGDIR=tmpuuids ../$CMD -fv " .
            "--dbname ./db.sqlite perl bashfile", # {{{
        "/^$v1_templ\\n\$/s",
        '/^std: Overwriting \'bashfile\'\.\.\.\n/s',
        0,
        "Overwrite bashfile with perl script using --force",
    );
    # }}}
    like(file_data("bashfile"), # {{{
        qr/use Getopt::Long/s,
        "Contents of bashfile is replaced"
    );

    # }}}
    diag("Testing -T (--notag) option...");
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD -T uuid,year perl", # {{{
        '/STDuuidDTS.*STDyearDTS/s',
        '/^std: Warning: Undefined tags: filename uuid year\n.*$/s',
        0,
        "Send perl script to stdout, don’t expand uuid and year tag",
    );

    # }}}
    diag("Test --rcfile option...");
    create_file("stdrc", <<END);
dbname = ./dbfromrc.sqlite
END
    likecmd("SUUID_LOGDIR=tmpuuids ../$CMD --force --rcfile stdrc " .
            "bash bashfile", # {{{
        "/^$v1_templ\\n\$/s",
        '/^' .
            'std: Creating database \'./dbfromrc.sqlite\'\n' .
            '$/',
        0,
        "Read dbname from stdrc with --rcfile",
    );

    # }}}
    like(sqlite_dump("dbfromrc.sqlite"), # {{{
        '/^' .
            'PRAGMA foreign_keys=OFF;\n' .
            'BEGIN TRANSACTION;\n' .
            'CREATE TABLE synced \(\n' .
            '  file TEXT\n' .
            '    CONSTRAINT synced_file_length\n' .
            '      CHECK \(length\(file\) > 0\)\n' .
            '    UNIQUE\n' .
            '    NOT NULL\n' .
            '  ,\n' .
            '  orig TEXT\n' .
            '  ,\n' .
            '  rev TEXT\n' .
            '    CONSTRAINT synced_rev_length\n' .
            '      CHECK \(length\(rev\) = 40 OR rev = \'\'\)\n' .
            '  ,\n' .
            '  date TEXT\n' .
            '    CONSTRAINT synced_date_length\n' .
            '      CHECK \(date IS NULL OR length\(date\) = 19\)\n' .
            '    CONSTRAINT synced_date_valid\n' .
            '      CHECK \(date IS NULL OR datetime\(date\) IS NOT NULL\)\n' .
            '\);\n' .
            'INSERT INTO "synced" ' .
            'VALUES\(\'tests/tmp-std-t-\d+-\d+/bashfile\',' .
            '\'Lib/std/bash\',\'' .
            $commit .
            '\',' .
            '\'\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\'\);\n' .
            'CREATE TABLE todo \(\n' .
            '  file TEXT\n' .
            '    CONSTRAINT todo_file_length\n' .
            '      CHECK\(length\(file\) > 0\)\n' .
            '    UNIQUE\n' .
            '    NOT NULL\n' .
            '  ,\n' .
            '  pri INTEGER\n' .
            '    CONSTRAINT todo_pri_range\n' .
            '      CHECK\(pri BETWEEN 1 AND 5\)\n' .
            '  ,\n' .
            '  comment TEXT\n' .
            '\);\n' .
            'COMMIT;\n' .
            '$/',
        "dbfromrc.sqlite looks ok",
    );

    # }}}

    chdir("..") || die("$progname: Cannot 'chdir ..': $!");
    diag("Cleaning up temp files...");
    ok(unlink(glob "$Tmptop/tmpuuids/*"),
        "unlink('glob [Tmptop]/tmpuuids/*')");
    ok(rmdir("$Tmptop/tmpuuids"), "rmdir([Tmptop]/tmpuuids)");
    ok(unlink("$Tmptop/bash-no-db"), "unlink('[Tmptop]/bash-no-db')");
    ok(unlink("$Tmptop/bashfile"), "unlink('[Tmptop]/bashfile')");
    ok(unlink("$Tmptop/db.sqlite"), "unlink('[Tmptop]/db.sqlite')");
    ok(unlink("$Tmptop/dbfromrc.sqlite"),
        "unlink('[Tmptop]/dbfromrc.sqlite')");
    ok(unlink("$Tmptop/stdrc"), "unlink('[Tmptop]/stdrc");
    ok(rmdir($Tmptop), "rmdir([Tmptop])");

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

sub sqlite_dump {
    # Return SQLite dump of database file {{{
    my $File = shift;
    my $Txt;
    if (open(my $fp, "$SQLITE $File .dump |")) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return($Txt);
    } else {
        return;
    }
    # }}}
} # sqlite_dump()

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
