#!/usr/bin/perl

#=======================================================================
# git-wip.t
# File ID: 3e1ac1d2-14cc-11e5-810f-000df06acc56
#
# Test suite for git-wip(1).
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

our $CMD = '../git-wip';

our %Opt = (

    'all' => 0,
    'git' => defined($ENV{'GITWIP_GIT'}) ? $ENV{'GITWIP_GIT'} : 'git',
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
    'git|g=s' => \$Opt{'git'},
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

    # git(1) refuses to commit if user.email or user.name isn't defined, 
    # so abort if that's how things are.
    like(`git config --get user.email`, qr/./, 'user.email is defined in Git') ||
        BAIL_OUT('user.email is not defined in Git');
    like(`git config --get user.name`, qr/./, 'user.name is defined in Git') ||
        BAIL_OUT('user.name is not defined in Git');

    my $Tmptop = "tmp-git-wip-t-$$-" . substr(rand, 2, 8);
    diag("Creating tempdir...");
    ok(mkdir($Tmptop), "mkdir [Tmptop]") or
        die("$progname: $Tmptop: Cannot create directory: $!\n");
    ok(chdir($Tmptop), "chdir [Tmptop]") or
        die("$progname: $Tmptop: Cannot chdir: $!\n");

    diag("Initialise repository...");
    ok(mkdir("repo"), "mkdir repo");
    ok(chdir("repo"), "chdir repo") || BAIL_OUT("Cannot chdir repo");
    likecmd("$Opt{'git'} init", # {{{
        '/.*/',
        '/.*/',
        0,
        'Initialise Git repository',
    );

    # }}}
    likecmd("../../$CMD", # {{{
        '/^$/',
        '/fatal: ambiguous argument \'HEAD\': unknown revision or path not in the working tree\./s',
        1,
        'master doesn\'t exist yet',
    );

    # }}}
    create_empty_commit("Init");
    testcmd("$Opt{'git'} branch", # {{{
        "* master\n",
        '',
        0,
        'master is created',
    );

    # }}}
    commit_new_file("file1.txt");
    is(commit_log(''), <<END, "Commit log with file1.txt is ok"); # {{{
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    diag("Test without arguments...");
    testcmd("../../$CMD", # {{{
        "",
        "Switched to branch 'wip'\n",
        0,
        "Command without arguments uses default 'wip' branch",
    );

    # }}}
    testcmd("../../$CMD", # {{{
        "",
        "Switched to branch 'wip.wip'\n",
        0,
        "No args again, create wip.wip",
    );

    # }}}
    diag("Test -d option...");
    likecmd("../../$CMD -d", # {{{
        '/^wip\\nAlready up-to-date.*Deleted branch wip\.wip.*$/s',
        '/^Switched to branch \'wip\'\\n$/',
        0,
        "Delete empty branch with -d",
    );

    # }}}
    diag("Test -m option...");
    create_and_switch_to_subbranch('add-files', 'wip.add-files');
    is(commit_log(''), <<END, "Commit log is unchanged since file1.txt"); # {{{
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    commit_new_file("file2.txt");
    commit_new_file("file3.txt");
    is(commit_log(''), <<END, "Commit log with file3.txt is ok"); # {{{
5c0f1e77ac82fe0d382b312202a467446d5948f4 Add file3.txt
9ddbad632f192f4edd053709b3aaedc95bd9ac0e Add file2.txt
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    likecmd("../../$CMD -m", # {{{
        '/^wip\\nMerge made by (the \')?recursive(\' strategy)?.*' .
        ' create mode 100644 file2\.txt\\n' .
        ' create mode 100644 file3\.txt\\n' .
        'Deleted branch wip\.add-files .*' .
        '/s',
        '/^Switched to branch \'wip\'\\n$/',
        0,
        "Merge wip.add-files to parent (wip)",
    );

    # }}}
    is(commit_log(''), <<END, "Commit log after -m is ok"); # {{{
5c0f1e77ac82fe0d382b312202a467446d5948f4 Merge branch 'wip.add-files' into wip
5c0f1e77ac82fe0d382b312202a467446d5948f4 Add file3.txt
9ddbad632f192f4edd053709b3aaedc95bd9ac0e Add file2.txt
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    create_and_switch_to_subbranch('more-files', 'wip.more-files');
    commit_new_file("file4.txt");
    diag("Test -p option...");
    likecmd("../../$CMD -p", # {{{
        '/^wip\\n$/',
        '/^Switched to branch \'wip\'\\n$/',
        0,
        "-p option works",
    );

    # }}}
    testcmd("$Opt{'git'} branch", # {{{
        <<END,
  master
* wip
  wip.more-files
END
        '',
        0,
        "Branches after -p looks fine",
    );

    # }}}
    likecmd("echo y | ../../$CMD -p", # {{{
        '/^master$/',
        '/^git-wip: Type \'y\' \+ Enter to set active branch to \'master\' \(git checkout\)\.\.\.Switched to branch \'master\'$/',
        0,
        'If -p option and no parent, checkout master',
    );

    # }}}
    testcmd("$Opt{'git'} branch", # {{{
        <<END,
* master
  wip
  wip.more-files
END
        '',
        0,
        "Check current branch status after -p to master",
    );

    # }}}
    likecmd("$Opt{'git'} checkout wip.more-files", # {{{
        '/^$/',
        '/^Switched to branch \'wip\.more-files\'\\n$/',
        0,
        "Go back to wip.more-files",
    );

    # }}}
    commit_new_file("file5.txt");
    is(commit_log(''), <<END, "Commit log with file5.txt is ok"); # {{{
375860ebe00ccc64321c2ade0c1525e7428458fa Add file5.txt
6c4c1a3c2c479e74e02394040d6da63046c1458c Add file4.txt
5c0f1e77ac82fe0d382b312202a467446d5948f4 Merge branch 'wip.add-files' into wip
5c0f1e77ac82fe0d382b312202a467446d5948f4 Add file3.txt
9ddbad632f192f4edd053709b3aaedc95bd9ac0e Add file2.txt
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    diag("Testing -s option...");
    likecmd("../../$CMD -s", # {{{
        '/^wip\\nUpdating [0-9a-f]+\.\.[0-9a-f]+\\n' .
        'Fast(-| )forward\\n' .
        'Squash commit -- not updating HEAD\\n' .
        '.*' .
        ' create mode 100644 file4\.txt\\n' .
        ' create mode 100644 file5\.txt\\n' .
        '/s',
        '/^Switched to branch \'wip\'\\n$/',
        0,
        "Squash wip.more-files to parent with -s",
    );

    # }}}
    is(commit_log(''), <<END, "Commit log after squash (-s) is ok"); # {{{
5c0f1e77ac82fe0d382b312202a467446d5948f4 Merge branch 'wip.add-files' into wip
5c0f1e77ac82fe0d382b312202a467446d5948f4 Add file3.txt
9ddbad632f192f4edd053709b3aaedc95bd9ac0e Add file2.txt
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    likecmd("$Opt{'git'} commit -m 'Squash wip.more-files into wip'", # {{{
        '/^\[wip [0-9a-f]+\] Squash wip\.more-files into wip\\n' .
        ' 2 files changed, 2 insertions\(\+\)(, 0 deletions\(-\))?\\n' .
        ' create mode 100644 file4\.txt\\n' .
        ' create mode 100644 file5\.txt\\n$' .
        '/s',
        '/^$/',
        0,
        "Commit squashed changes",
    );

    # }}}
    is(commit_log(''), <<END, "Commit log after squash commit is ok"); # {{{
375860ebe00ccc64321c2ade0c1525e7428458fa Squash wip.more-files into wip
5c0f1e77ac82fe0d382b312202a467446d5948f4 Merge branch 'wip.add-files' into wip
5c0f1e77ac82fe0d382b312202a467446d5948f4 Add file3.txt
9ddbad632f192f4edd053709b3aaedc95bd9ac0e Add file2.txt
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    likecmd("echo y | ../../$CMD -m", # {{{
        '/^master\\n' .
        'Merge made by (the \')?recursive(\' strategy)?\.\\n' .
        ' file2\.txt \| +1 \+\\n' .
        ' file3\.txt \| +1 \+\\n' .
        ' file4\.txt \| +1 \+\\n' .
        ' file5\.txt \| +1 \+\\n' .
        ' 4 files changed, 4 insertions\(\+\)(, 0 deletions\(-\))?\\n' .
        ' create mode 100644 file2\.txt\\n' .
        ' create mode 100644 file3\.txt\\n' .
        ' create mode 100644 file4\.txt\\n' .
        ' create mode 100644 file5\.txt\\n' .
        'Deleted branch wip \(was [0-9a-f]+\)\.\\n$' .
        '/s',
        '/^git-wip: Type \'y\' \+ Enter to merge wip to master\.\.\.Switched to branch \'master\'\\n$/',
        0,
        "Merge wip to master with -m",
    );

    # }}}
    is(commit_log(''), <<END, "Commit log after -m"); # {{{
375860ebe00ccc64321c2ade0c1525e7428458fa Merge branch 'wip'
375860ebe00ccc64321c2ade0c1525e7428458fa Squash wip.more-files into wip
5c0f1e77ac82fe0d382b312202a467446d5948f4 Merge branch 'wip.add-files' into wip
5c0f1e77ac82fe0d382b312202a467446d5948f4 Add file3.txt
9ddbad632f192f4edd053709b3aaedc95bd9ac0e Add file2.txt
04c774c04d6f3c4915c535077c24bc00dba82828 Add file1.txt
4b825dc642cb6eb9a060e54bf8d69288fbee4904 Init
END

    # }}}
    likecmd("echo y | ../../$CMD -m", # {{{
        '/^$/',
        '/^Is already on master, nowhere to merge branch\\n$/',
        1,
        "Option -m on master doesn't work",
    );

    # }}}
    likecmd("echo y | ../../$CMD -s", # {{{
        '/^$/',
        '/^Is already on master, nowhere to squash branch\\n$/',
        1,
        "Neither does -s",
    );

    # }}}
    diag("Test for unknown options...");
    likecmd("../../$CMD -W", # {{{
        '/^$/',
        '/^git-wip: -W: Unknown option\\n$/',
        1,
        "It doesn't recognise -W",
    );

    # }}}
    likecmd("../../$CMD -e", # {{{
        '/^$/',
        '/^git-wip: -e: Unknown option\\n$/',
        1,
        "It doesn't recognise -e (used by echo)",
    );

    # }}}
    likecmd("../../$CMD --", # {{{
        '/^$/',
        '/^git-wip: --: Unknown option\\n$/',
        1,
        "It doesn't recognise --",
    );

    # }}}
    likecmd("../../$CMD -", # {{{
        '/^$/',
        '/^git-wip: -: Unknown option\\n$/',
        1,
        "Abort if a single hyphen is specified",
    );

    # }}}
    diag("Cleaning up temp files...");
    ok(chdir(".."), "chdir .."); # From $Tmptop/repo/
    likecmd("rm -rf repo", # {{{
        '/^$/',
        '/^$/',
        0,
        'Delete repo/',
    );

    # }}}
    ok(chdir(".."), "chdir .."); # From $Tmptop/

    ok(-d $Tmptop, "[Tmptop] exists");
    ok(rmdir($Tmptop), "rmdir([Tmptop])");
    ok(!-e $Tmptop, "Tempdir is gone");

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

sub create_and_switch_to_subbranch {
    # {{{
    my ($branch, $exp_branch) = @_;
    testcmd("../../$CMD $branch",
        "",
        "Switched to branch '$exp_branch'\n",
        0,
        "Create subbranch '$branch' and checkout '$exp_branch'",
    );
    return;
    # }}}
} # create_and_switch_to_subbranch()

sub commit_log {
    # {{{
    my $ref = shift;
    my $retval = '';
    open(my $pipefp, "$Opt{'git'} log --format='%T %s' --topo-order $ref |") or
        return("'$Opt{'git'} log' pipe error: $!\n");
    while (<$pipefp>) {
        $retval .= $_;
    }
    close($pipefp);
    return($retval);
    # }}}
} # commit_log()

sub commit_new_file {
    # {{{
    my $file = shift;
    ok(!-e $file, "$file doesn't exist");
    ok(open(my $outfp, ">$file"), "Create file '$file'");
    ok(print($outfp "This is $file\n"), "Add content to $file");
    ok(close($outfp), "Close $file");
    ok(-f $file, "$file exists and is a regular file");
    is(file_data($file), "This is $file\n", "Contents of $file is ok");
    testcmd("$Opt{'git'} add \"$file\"",
        '',
        '',
        0,
        "$Opt{'git'} add $file",
    );
    likecmd("$Opt{'git'} commit -m \"Add $file\"",
        "/.* Add $file.*/s",
        '/^$/',
        0,
        "$Opt{'git'} commit",
    );
    # }}}
} # commit_new_file()

sub create_empty_commit {
    # {{{
    my $msg = shift;
    likecmd("$Opt{'git'} commit --allow-empty -m \"$msg\"",
        '/.*/', '/.*/', 0, "Create empty commit");
    return;
    # }}}
} # create_empty_commit()

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
    my $TMP_STDERR = 'git-wip-stderr.tmp';

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
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
    my $TMP_STDERR = 'git-wip-stderr.tmp';

    if (defined($Exp_stderr)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$stderr_cmd`, "$Exp_stdout", "$Txt (stdout)");
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        like(file_data($TMP_STDERR), "$Exp_stderr", "$Txt (stderr)");
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

Contains tests for the git-wip(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -g X, --git X
    Specify alternative git executable to use. Used to execute the tests 
    with different git versions. This can also be set with the GITWIP_GIT 
    environment variable.
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

git-wip.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the git-wip(1) program.

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
