#!/usr/bin/env perl

#=======================================================================
# datefn.t
# File ID: a9a05f2e-4d60-11e2-8d2a-0016d364066c
#
# Test suite for datefn(1).
#
# Character set: UTF-8
# ©opyleft 2012– Øyvind A. Holm <sunny@sunbase.org>
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

our $CMD_BASENAME = "datefn";
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

    my $topdir = "datefn-files";
    ok(chdir($topdir), "chdir $topdir");

    testcmd("tar xzf file.tar.gz", "", "", 0, "Untar file.tar.gz (1)");
    testcmd("../$CMD file.txt",
        "datefn: 'file.txt' renamed to '20121224T002858Z.file.txt'\n",
        "",
        0,
    );
    my $newname = "20121224T002858Z.file.txt";
    is(
        file_data($newname),
        "Sånn går now the days.\n",
        "file.txt was properly renamed",
    );

    diag('Testing --force option...');
    testcmd("tar xzf file.tar.gz", "", "", 0, "Untar file.tar.gz (2)");
    testcmd("../$CMD file.txt",
        "",
        "datefn: 20121224T002858Z.file.txt: File already exists, use --force to overwrite\n",
        0,
        "Don't overwrite file without --force",
    );

    testcmd("../$CMD -f file.txt",
        "datefn: 'file.txt' renamed to '20121224T002858Z.file.txt'\n",
        "",
        0,
        "File is overwritten with --force",
    );

    testcmd("../$CMD 20121224T002858Z.file.txt",
        "",
        "datefn: 20121224T002858Z.file.txt: Filename already has date\n",
        0,
        "Don't add date when there's already one there",
    );

    diag("Testing --replace option...");

    ok(utime(1433116800, 1433116800, "20121224T002858Z.file.txt"), "Change mtime of 20121224T002858Z.file.txt");
    testcmd("../$CMD --replace 20121224T002858Z.file.txt",
        "datefn: '20121224T002858Z.file.txt' renamed to '20150601T000000Z.file.txt'\n",
        "",
        0,
        "Replace timestamp with new modification time",
    );
    is(
        file_data("20150601T000000Z.file.txt"),
        "Sånn går now the days.\n",
        "file.txt was renamed to new mtime with -r",
    );

    diag('Testing --delete option...');
    testcmd("../$CMD --delete 20150601T000000Z.file.txt",
        "datefn: '20150601T000000Z.file.txt' renamed to 'file.txt'\n",
        "",
        0,
        "Delete date with --delete",
    );

    testcmd("../$CMD -d -v file.txt",
        "",
        "datefn: Filename for file.txt is unchanged\n",
        0,
        "Delete non-existing date with -d",
    );

    testcmd("../$CMD -d -r -v file.txt",
        "",
        "datefn: Cannot mix -d/--delete and -r/--replace options\n",
        1,
        "-d and -r can't be mixed",
    );

    testcmd("../$CMD -r -v file.txt",
        "datefn: 'file.txt' renamed to '20150601T000000Z.file.txt'\n",
        "",
        0,
        "-r on file without date adds timestamp",
    );

    diag("Check that it works with paths...");
    ok(chdir(".."), "chdir ..");

    testcmd("$CMD -d datefn-files/20150601T000000Z.file.txt",
        "datefn: 'datefn-files/20150601T000000Z.file.txt' renamed to 'datefn-files/file.txt'\n",
        "",
        0,
        "Delete date from parent directory",
    );

    testcmd("$CMD datefn-files/file.txt",
        "datefn: 'datefn-files/file.txt' renamed to 'datefn-files/20150601T000000Z.file.txt'\n",
        "",
        0,
        "Re-add date from parent directory",
    );

    ok(chdir("datefn-files"), "chdir datefn-files");

    ok(unlink("20150601T000000Z.file.txt"), "unlink 20150601T000000Z.file.txt");

    diag('Testing --git option...');
    my $git_version = `git --version 2>/dev/null`;
    if ($git_version =~ /^git version \d/) {
        testcmd("tar xzf repo.tar.gz",
            '',
            '',
            0,
            "Unpack repo.tar.gz (3)"
        );
        ok(chdir("repo"), "chdir repo");
        ok(-d ".git" && -f "file.txt", "repo.tar.gz was properly unpacked");
        testcmd("../../$CMD --git file.txt",
            "datefn: 'file.txt' renamed to '20150611T123129Z.file.txt'\n",
            "datefn: Executing \"git mv file.txt 20150611T123129Z.file.txt\"...\n",
            0,
            "Use --git option in Git repository",
        );
        is(
            file_data("20150611T123129Z.file.txt"),
            "This is the most amazing file.\n",
            "file.txt was properly renamed",
        );
        testcmd("git status --porcelain",
            <<END,
R  file.txt -> 20150611T123129Z.file.txt
?? datefn-stderr.tmp
?? unknown.txt
END
            "",
            0,
            "File status looks ok in git",
        );
        testcmd("../../$CMD -gd 20150611T123129Z.file.txt",
            "datefn: '20150611T123129Z.file.txt' renamed to 'file.txt'\n",
            "datefn: Executing \"git mv 20150611T123129Z.file.txt file.txt\"...\n",
            0,
            "Use -d and -g option in Git repository",
        );
        is(
            file_data("file.txt"),
            "This is the most amazing file.\n",
            "20150611T123129Z.file.txt was properly renamed",
        );
        testcmd("git status --porcelain",
            <<END,
?? datefn-stderr.tmp
?? unknown.txt
END
            "",
            0,
            "File status in git is ok, changes to file.txt are gone",
        );
        testcmd("LC_ALL=C ../../$CMD -g unknown.txt",
            "",
            <<END,
datefn: Executing "git mv unknown.txt 20150611T141445Z.unknown.txt"...
fatal: not under version control, source=unknown.txt, destination=20150611T141445Z.unknown.txt
datefn: unknown.txt: Cannot rename file to '20150611T141445Z.unknown.txt': No such file or directory
END
            0,
            "Use --git option on file unknown to Git",
        );
        ok(chdir(".."), "chdir ..");
        testcmd("rm -rf repo", "", "", 0, "Remove repo/");
        ok(!-e "repo", "repo/ is gone");
    } else {
        diag("Cannot find 'git' executable, skipping --git tests");
    }

    diag('Testing --skew option...');
    testcmd("tar xzf file.tar.gz", "", "", 0, "Untar file.tar.gz (4)");
    testcmd("../$CMD -s 86400 file.txt",
        "datefn: 'file.txt' renamed to '20121225T002858Z.file.txt'\n",
        "",
        0,
        "Test -s (--skew) with positive integer",
    );
    ok(unlink('20121225T002858Z.file.txt'), "unlink '20121225T002858Z.file.txt'");

    testcmd("tar xzf file.tar.gz", "", "", 0, "Untar file.tar.gz (5)");
    testcmd("../$CMD --skew -86400 file.txt",
        "datefn: 'file.txt' renamed to '20121223T002858Z.file.txt'\n",
        "",
        0,
        "--skew with negative integer",
    );
    ok(unlink('20121223T002858Z.file.txt'), "unlink '20121223T002858Z.file.txt'");

    # FIXME: Add tests for --bwf

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
