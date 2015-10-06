#!/usr/bin/env perl

#=======================================================================
# git-update-dirs.t
# File ID: 9072b5a4-f909-11e4-b80e-000df06acc56
#
# Test suite for git-update-dirs(1).
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

our $CMD = '../git-update-dirs';

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

    my $Tmptop = "tmp-git-update-dirs-t-$$-" . substr(rand, 2, 8);
    ok(mkdir($Tmptop), "mkdir [Tmptop]") || BAIL_OUT("$Tmptop: mkdir error, can't continue\n");

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
    likecmd("git --version", # {{{
        '/^git version /',
        '/^$/',
        0,
        'git is installed',
    ) || BAIL_OUT("git is not installed, cannot continue");

    # }}}
    likecmd("git annex version", # {{{
        '/^git-annex version:/',
        '/^$/',
        0,
        'git-annex is installed',
    ) || BAIL_OUT("git-annex is not installed, cannot continue");

    # }}}
    ok(chdir($Tmptop), "chdir [Tmptop]") || BAIL_OUT("$progname: $Tmptop: chdir error, can't continue\n");
    likecmd("git init repo", # {{{
        '/.*/',
        '/^$/',
        0,
        'Create Git repository',
    );

    # }}}
    ok(chdir("repo"), "chdir repo");
    likecmd("git commit --allow-empty -m 'Empty start commit'", # {{{
        '/.*/',
        '/^$/',
        0,
        'Create empty start commit',
    );

    # }}}
    likecmd("git annex init testrepo", # {{{
        '/.*/',
        '/^$/',
        0,
        'Make it an annex',
    );

    # }}}
    $CMD = "../../$CMD";
    my $sep = "================ . ================\n";

    diag('--exec-before');
    testcmd("$CMD -E 'echo This is nice' .", # {{{
        "${sep}This is nice\n\n",
        "git-update-dirs: Executing 'echo This is nice'...\n",
        0,
        'Test -E option',
    );

    # }}}
    testcmd("$CMD --exec-before 'echo This is nice' .", # {{{
        "${sep}This is nice\n\n",
        "git-update-dirs: Executing 'echo This is nice'...\n",
        0,
        'Test --exec-before option',
    );

    # }}}
    diag('--lpar');
    testcmd("$CMD -n -l .", # {{{
        "$sep\n",
        "git-update-dirs: Simulating 'lpar'...\n" .
            "git-update-dirs: Simulating 'lpar'...\n",
        0,
        'Test -l option',
    );

    # }}}
    testcmd("$CMD -n --lpar .", # {{{
        "$sep\n",
        "git-update-dirs: Simulating 'lpar'...\n" .
            "git-update-dirs: Simulating 'lpar'...\n",
        0,
        'Test --lpar option',
    );

    # }}}
    diag('--test');
    test_option('-t', 'git fsck');
    test_option('--test', 'git fsck');
    diag('--fetch-prune');
    test_option('-F', 'git fetch --all --prune');
    test_option('--fetch-prune', 'git fetch --all --prune');
    diag('--fetch');
    test_option('-f', 'git fetch --all');
    test_option('--fetch', 'git fetch --all');
    diag('--pull');
    test_option('-p', 'git pull --ff-only');
    test_option('--pull', 'git pull --ff-only');
    diag('--ga-sync');
    test_option('-g', 'ga sync');
    test_option('--ga-sync', 'ga sync');
    diag('--ga-dropget');
    test_option('-G', nolf(<<END));
ga sync'...
git-update-dirs: Simulating 'ga drop --auto'...
git-update-dirs: Simulating 'ga sync'...
git-update-dirs: Simulating 'ga get --auto'...
git-update-dirs: Simulating 'ga sync
END
    test_option('--ga-dropget', nolf(<<END));
ga sync'...
git-update-dirs: Simulating 'ga drop --auto'...
git-update-dirs: Simulating 'ga sync'...
git-update-dirs: Simulating 'ga get --auto'...
git-update-dirs: Simulating 'ga sync
END
    diag('--ga-dropunused');
    test_option('-u', nolf(<<END));
ga sync'...
git-update-dirs: Simulating 'ga unused'...
git-update-dirs: Simulating 'ga dropunused all'...
git-update-dirs: Simulating 'ga sync
END
    test_option('--ga-dropunused', nolf(<<END));
ga sync'...
git-update-dirs: Simulating 'ga unused'...
git-update-dirs: Simulating 'ga dropunused all'...
git-update-dirs: Simulating 'ga sync
END
    diag('--ga-moveunused');
    test_option('-U', nolf(<<END));
ga sync
END
    testcmd('git remote add seagate-3tb yep',
        '',
        '',
        0,
        'Add fake seagate-3tb remote',
    );
    test_option('--ga-moveunused', nolf(<<END));
ga sync'...
git-update-dirs: Simulating 'ga unused'...
git-update-dirs: Simulating 'ga move --unused --to seagate-3tb'...
git-update-dirs: Simulating 'ga sync
END
    diag('--ga-getnew');
    test_option('-N', 'ga-getnew | fold-stdout');
    diag('--dangling');
    test_option('-d', 'git dangling');
    test_option('--dangling', 'git dangling');
    diag('--allbr');
    test_option('-a', nolf(<<END));
git nobr'...
git-update-dirs: Simulating 'git checkout -
END
    test_option('--allbr', nolf(<<END));
git nobr'...
git-update-dirs: Simulating 'git checkout -
END
    diag('--push');
    test_option('-P', 'git pa');
    test_option('--push', 'git pa');
    diag('--submodule');
    testcmd("$CMD --dry-run -s .", # {{{
        "================ . ================\n\n",
        '',
        0,
        'Test -s option, .gitmodules is missing',
    );

    # }}}
    testcmd("touch .gitmodules", '', '', 0, 'Create empty .gitmodules');
    test_option('--submodule', nolf(<<END));
git submodule init'...
git-update-dirs: Simulating 'git submodule update
END

    my $compress_output =
        '/^' .
        '================ \. ================\n' .
        '\n' .
        'Before: \d+\n' .
        'After : \d+\n' .
        'Saved : \d+ \(\d+.\d+%\)\n' .
        'Number of files in .git\/objects: before: \d+, after: \d+, saved: \d+\n' .
        '\n' .
        'Before: \d+\n' .
        'After : \d+\n' .
        'Total : \d+ \(\d+.\d+%\)\n' .
        'Number of object files: before: \d+, after: \d+, saved: \d+\n' .
        '/';
    diag('--compress');
    likecmd("$CMD -n -c .",
        $compress_output,
        '/^git-update-dirs: Simulating \'git gc\'\.\.\.\n$/',
        0,
        'Test -c option',
    );
    likecmd("$CMD -n --compress .",
        $compress_output,
        '/^git-update-dirs: Simulating \'git gc\'\.\.\.\n$/',
        0,
        'Test --compress option',
    );
    diag('--aggressive-compress');
    likecmd("$CMD -n -C .",
        $compress_output,
        '/^git-update-dirs: Simulating \'git gc --aggressive\'\.\.\.\n$/',
        0,
        'Test -c option',
    );
    likecmd("$CMD --dry-run --aggressive-compress .",
        $compress_output,
        '/^git-update-dirs: Simulating \'git gc --aggressive\'\.\.\.\n$/',
        0,
        'Test --aggressive-compress option',
    );
    diag('--delete-dangling');
    test_option('-D', 'git dangling -D');
    test_option('--delete-dangling', 'git dangling -D');

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

    ok(chdir(".."), "chdir ..");
    testcmd("rm -rf repo", # {{{
        '',
        '',
        0,
        'Remove test repository',
    );

    # }}}
    ok(chdir(".."), "chdir ..");
    ok(rmdir($Tmptop), "rmdir [Tmptop]");
    ok(!-d $Tmptop, "[Tmptop] is gone");

    diag('Testing finished.');
    # }}}
} # main()

sub nolf {
    # Strip \n from string, replacement for chomp() {{{
    my $str = shift;
    $str =~ s/\n$//s;
    return($str);
    # }}}
} # nolf()

sub test_option {
    # {{{
    my ($option, $cmd) = @_;

    return(testcmd("$CMD -n $option .",
        "================ . ================\n\n",
        "git-update-dirs: Simulating '$cmd'...\n",
        0,
        "Test $option option",
    ));
    # }}}
} # test_option()

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
    my $TMP_STDERR = 'git-update-dirs-stderr.tmp';
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
    my $TMP_STDERR = 'git-update-dirs-stderr.tmp';
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

Contains tests for the git-update-dirs(1) program.

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

git-update-dirs.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the git-update-dirs(1) program.

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
