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

    my $Tmptop = "tmp-git-wip-t-$$-" . substr(rand, 2, 8);
    diag("Creating tempdir...");
    ok(mkdir($Tmptop), "mkdir [Tmptop]") or
        die("$progname: $Tmptop: Cannot create directory: $!\n");
    ok(chdir($Tmptop), "chdir [Tmptop]") or
        die("$progname: $Tmptop: Cannot chdir: $!\n");

    diag("Initialise repository...");
    likecmd("git init repo", # {{{
        '/.*/',
        '/.*/',
        0,
        'description',
    );

    # }}}
    ok(chdir("repo"), "chdir repo") || BAIL_OUT("Cannot chdir repo");
    likecmd("../../$CMD", # {{{
        '/^$/',
        '/fatal: ambiguous argument \'HEAD\': unknown revision or path not in the working tree\./s',
        1,
        'master doesn\'t exist yet',
    );

    # }}}
    create_empty_commit("Initial empty commit");
    testcmd("git branch", # {{{
        "* master\n",
        '',
        0,
        'master is created',
    );

    # }}}
    commit_new_file("file1.txt");
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
    testcmd("../../$CMD add-files", # {{{
        "",
        "Switched to branch 'wip.add-files'\n",
        0,
        "subbranch add-files",
    );

    # }}}
    commit_new_file("file2.txt");
    commit_new_file("file3.txt");
    likecmd("../../$CMD -m", # {{{
        '/^wip\\nMerge made by the \'recursive\' strategy.*' .
        ' create mode 100644 file2\.txt\\n' .
        ' create mode 100644 file3\.txt\\n' .
        'Deleted branch wip\.add-files .*' .
        '/s',
        '/^Switched to branch \'wip\'\\n$/',
        0,
        "Merge wip.add-files to parent (wip)",
    );

    # }}}
    diag("Testing -s option...");
    testcmd("../../$CMD more-files", # {{{
        "",
        "Switched to branch 'wip.more-files'\n",
        0,
        "subbranch more-files",
    );

    # }}}
    commit_new_file("file4.txt");
    commit_new_file("file5.txt");
    likecmd("../../$CMD -s", # {{{
        '/^wip\\nUpdating [0-9a-f]+\.\.[0-9a-f]+\\n' .
        'Fast-forward\\n' .
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

    ok(-d $Tmptop, "[Tmptop] exists");
    ok(rmdir($Tmptop), "rmdir([Tmptop])");
    ok(!-e $Tmptop, "Tempdir is gone");

    diag('Testing finished.');
    # }}}
} # main()

sub commit_new_file {
    # {{{
    my $file = shift;
    ok(!-e $file, "$file doesn't exist");
    open(my $outfp, ">$file");
    print($outfp "This is $file\n");
    close($outfp);
    ok(-f $file, "$file exists and is a regular file");
    is(file_data($file), "This is $file\n", "Contents of $file is ok");
    testcmd("git add \"$file\"",
        '',
        '',
        0,
        "git add $file",
    );
    likecmd("git commit -m \"Add $file\"",
        "/.* Add $file.*/s",
        '/^$/',
        0,
        "git commit",
    );
    # }}}
} # commit_new_file()

sub create_empty_commit {
    # {{{
    my $msg = shift;
    likecmd("git commit --allow-empty -m \"$msg\"",
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
