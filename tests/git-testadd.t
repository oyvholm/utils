#!/usr/bin/env perl

#==============================================================================
# git-testadd.t
# File ID: dd2d5468-4cdb-11e6-bed9-02010e0a6634
#
# Test suite for git-testadd(1).
#
# Character set: UTF-8
# ©opyleft 2016– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of file for 
# legal stuff.
#==============================================================================

use strict;
use warnings;

BEGIN {
	use Test::More qw{no_plan};
	# use_ok() goes here
}

use Getopt::Long;

our $CMD_BASENAME = "git-testadd";
our $CMD = "../$CMD_BASENAME";

our %Opt = (

	'all' => 0,
	'git' => defined($ENV{'TESTADD_GIT'}) ? $ENV{'TESTADD_GIT'} : 'git',
	'help' => 0,
	'quiet' => 0,
	'todo' => 0,
	'verbose' => 0,
	'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.8.0';

my %descriptions = ();

Getopt::Long::Configure('bundling');
GetOptions(

	'all|a' => \$Opt{'all'},
	'git|g=s' => \$Opt{'git'},
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
	my $Retval = 0;

	diag(sprintf('========== Executing %s v%s ==========',
	             $progname, $VERSION));

	if ($Opt{'todo'} && !$Opt{'all'}) {
		ok(1, "No todo tests here");
		return 0;
	}

	test_standard_options();
	test_executable();

	diag('Testing finished.');

	return $Retval;
}

sub test_standard_options {
	diag('Testing -h (--help) option...');
	likecmd("$CMD -h",
	        '/  Show this help/i',
	        '/^$/',
	        0,
	        'Option -h prints help screen');

	diag('Testing -v (--verbose) option...');
	likecmd("$CMD -hv",
	        '/^\n\S+ \d+\.\d+\.\d+/s',
	        '/^$/',
	        0,
	        'Option -v with -h returns version number and help screen');

	diag('Testing --version option...');
	likecmd("$CMD --version",
	        '/^\S+ \d+\.\d+\.\d+/',
	        '/^$/',
	        0,
	        'Option --version returns version number');
}

sub test_executable {
	my $toptmp = "tmp-git-testadd-t-$$-" . substr(rand, 2, 8);
	my $repo = "$toptmp/repo";

	diag("Initialise Git repository");
	ok(! -d $toptmp, "[toptmp] doesn't exist") ||
		BAIL_OUT("$toptmp already exists");
	ok(mkdir($toptmp), "mkdir [toptmp]");
	cmd("$Opt{'git'} init \"$repo\"", "$Opt{'git'} init [repo]");
	ok(-d "$repo/.git", "[repo]/.git exists") ||
		BAIL_OUT("$repo/.git doesn't exist");
	ok(chdir($repo), "chdir [repo]");
	$CMD = "../../$CMD";

	test_options_without_commits();

	diag("Clean up files");
	ok(chdir("../.."), "chdir ../..");
	$CMD =~ s/^\.\.\/\.\.\///;
	ok(-d $repo, "[repo] exists") || BAIL_OUT("$repo not found");
	testcmd("rm -rf \"$repo\"", "", "", 0, "rm -rf [repo]");
	ok(rmdir($toptmp), "rmdir [toptmp]");
}

sub test_options_without_commits {
	diag("No options");
	test_options("No options",
	             ",rm(),clone(),cd(),cmd,", ",using(),nostaged,cmd,", 0,
	             "");
}

=pod

test_options() - Test the executable with the received options. Runs the 
program with -n (--dry-run) and checks stdout, stderr and exit value.

=cut

sub test_options {
	my ($desc, $stdout, $stderr, $exitval, @opts) = @_;

	for my $opt (@opts) {
		my $spc = length($opt) ? " " : "";

		likecmd("$CMD -n$spc$opt cmd",
		        o_out($stdout), o_err($stderr), $exitval,
		        "$desc ($opt)");
	}
}

=pod

o_out() - Return string with expected stdout output. Parse contents of $flags, 
a comma-separated list of flags with optional arguments in ().

=cut

sub o_out {
	my $flags = shift;
	my $retval = "";

	$retval .= '/^';
	if ($flags =~ /,rm\(([^\(\)]*)\),/) {
		my $val = $1;

		$val = length($val) ? "-$val" : "";
		$retval .= "rm -rf \\.testadd$val\\.tmp\\n";
	}
	if ($flags =~ /,clone\(([^\(\)]*)\),/) {
		my $val = $1;

		$val = length($val) ? "-$val" : "";
		$retval .= "git clone .+ \\.testadd$val\\.tmp\\n";
	}
	if ($flags =~ /,cd\(([^\(\)]*)\),/) {
		my $val = $1;

		$val = length($val) ? "-$val" : "";
		$retval .= "cd \\.testadd$val\\.tmp\\/\\n";
	}
	if ($flags =~ /,cmd,/) {
		$retval .= "eval cmd\\n";
	}
	$retval .= '$/s';

	return $retval;
}

=pod

o_err() - Return string with expected stderr output. Parse contents of $flags, 
a comma-separated list of flags with optional arguments in ().

=cut

sub o_err {
	my $flags = shift;
	my $retval = "";

	$retval .= '/^';
	if ($flags =~ /,using\(([^\(\)]*)\),/) {
		my $val = $1;

		$val = length($val) ? "-$val" : "";
		$retval .= "git-testadd: Using \"\\.testadd$val\\.tmp\" as " .
		           "destination directory\\n";
	}
	if ($flags =~ /,nostaged,/) {
		$retval .= "git-testadd: No staged changes, running command " .
		           "with clean HEAD\\n";
	}
	if ($flags =~ /,cmd,/) {
		$retval .= "\\n";
		$retval .= "git-testadd: Executing \"cmd\" in .+\\n";
	}
	$retval .= '$/s';

	return $retval;
}

sub cmd {
	my ($cmd, $desc) = @_;

	likecmd($cmd, '/.*/', '/.*/', 0, $desc);
}

sub testcmd {
	my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
	defined($descriptions{$Desc}) &&
		BAIL_OUT("testcmd(): '$Desc' description is used twice");
	$descriptions{$Desc} = 1;
	my $stderr_cmd = '';
	my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
	my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
	my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
	my $retval = 1;

	if (defined($Exp_stderr)) {
		$stderr_cmd = " 2>$TMP_STDERR";
	}
	$retval &= is(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
	my $ret_val = $?;
	if (defined($Exp_stderr)) {
		$retval &= is(file_data($TMP_STDERR),
		              $Exp_stderr, "$Txt (stderr)");
		unlink($TMP_STDERR);
	} else {
		diag("Warning: stderr not defined for '$Txt'");
	}
	$retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

	return $retval;
}

sub likecmd {
	my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
	defined($descriptions{$Desc}) &&
		BAIL_OUT("likecmd(): '$Desc' description is used twice");
	$descriptions{$Desc} = 1;
	my $stderr_cmd = '';
	my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
	my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
	my $TMP_STDERR = "$CMD_BASENAME-stderr.tmp";
	my $retval = 1;

	if (defined($Exp_stderr)) {
		$stderr_cmd = " 2>$TMP_STDERR";
	}
	$retval &= like(`$Cmd$stderr_cmd`, $Exp_stdout, "$Txt (stdout)");
	my $ret_val = $?;
	if (defined($Exp_stderr)) {
		$retval &= like(file_data($TMP_STDERR),
		                $Exp_stderr, "$Txt (stderr)");
		unlink($TMP_STDERR);
	} else {
		diag("Warning: stderr not defined for '$Txt'");
	}
	$retval &= is($ret_val >> 8, $Exp_retval, "$Txt (retval)");

	return $retval;
}

sub file_data {
	# Return file content as a string
	my $File = shift;
	my $Txt;

	open(my $fp, '<', $File) or return undef;
	local $/ = undef;
	$Txt = <$fp>;
	close($fp);
	return $Txt;
}

sub print_version {
	# Print program version
	print("$progname $VERSION\n");
}

sub usage {
	# Send the help message to stdout
	my $Retval = shift;

	if ($Opt{'verbose'}) {
		print("\n");
		print_version();
	}
	print(<<"END");

Usage: $progname [options]

Contains tests for the $CMD_BASENAME(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  -g X, --git X
    Specify alternative git executable to use. Used to execute the tests 
    with different git versions. This can also be set with the 
    TESTADD_GIT environment variable.
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
}

__END__

# This program is free software; you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation; either version 2 of the License, or (at your option) any later 
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with 
# this program.
# If not, see L<http://www.gnu.org/licenses/>.

# vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 :
