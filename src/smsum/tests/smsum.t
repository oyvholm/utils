#!/usr/bin/env perl

#==============================================================================
# tests/smsum.t
# File ID: de01b9cc-f943-11dd-9898-0001805bf4b1
#
# Test suite for smsum(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
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

local $| = 1;

our $CMD_BASENAME = "smsum";
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
our $VERSION = '0.1.1';

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
	my $Retval = 0;
	chomp(my $osname = `uname`);

	diag(sprintf('========== Executing %s v%s ==========',
	             $progname, $VERSION));

	if ($Opt{'todo'} && !$Opt{'all'}) {
		goto todo_section;
	}

	test_standard_options();

	testcmd("$CMD files/dir1.tar.gz", # {{{
	    <<END,
31226c9482573c4c323947858616ee174babdeb7-affeeed5dca3c6970e8a8eaf5277be90-3000\tfiles/dir1.tar.gz
END
	    "",
	    0,
	    "Verify files/dir1.tar.gz",
	);

	# }}}
	chdir('files') or die("$progname: files: Cannot chdir(): $!\n");
	likecmd('tar xzf dir1.tar.gz', # {{{
	    '/^$/',
	    '/.*/',
	    0,
	    "Extract dir1.tar.gz",
	);

	# }}}
	if ($osname eq "NetBSD") {
		ok(utime(-29746065, -29746065, "dir1/year_1969"),
		        "tar(1) on NetBSD can't exctract files before 1970, " .
		        "set it manually");
		diag("NOTICE: tar(1) on NetBSD is broken, can't extract " .
		     "files with mtime before 1970. Setting it manually.");
	}
	chdir('..') or die("$progname: ..: Cannot chdir(): $!\n");

	diag("No options specified...");
	testcmd("$CMD files/dir1/*", # {{{
	    <<END,
da39a3ee5e6b4b0d3255bfef95601890afd80709-d41d8cd98f00b204e9800998ecf8427e-0\tfiles/dir1/empty
bd91a93ca0462da03f2665a236d7968b0fd9455d-4a3074b2aae565f8558b7ea707ca48d2-2048\tfiles/dir1/random_2048
1fffb088a74a48447ee612dcab91dacae86570ad-af6888a81369b7a1ecfbaf14791c5552-333\tfiles/dir1/random_333
c70053a7b8f6276ff22181364430e729c7f42c5a-96319d5ea553d5e39fd9c843759d3175-43\tfiles/dir1/textfile
07b8074463668967f6030016d719ef326eb6382d-6dce58e78b13dab939de6eef142b7543-41\tfiles/dir1/year_1969
2113343435a9aadb458d576396d4f960071f8efd-6babaa47123f4f94ae59ed581a65090b-41\tfiles/dir1/year_2038
END
	    "smsum: files/dir1/chmod_0000: Cannot read file\n",
	    1,
	    "Read all files in dir1/",
	);

	# }}}
	testcmd("cat files/dir1/random_2048 | $CMD", # {{{
	<<END,
bd91a93ca0462da03f2665a236d7968b0fd9455d-4a3074b2aae565f8558b7ea707ca48d2-2048
END
	    "",
	    0,
	    "Read data from stdin",
	);

	# }}}
	diag("Testing -m (--with-mtime) option...");
	testcmd("$CMD -m files/dir1/*", # {{{
	    <<END,
da39a3ee5e6b4b0d3255bfef95601890afd80709-d41d8cd98f00b204e9800998ecf8427e-0\tfiles/dir1/empty\t2008-09-22T00:10:24Z
bd91a93ca0462da03f2665a236d7968b0fd9455d-4a3074b2aae565f8558b7ea707ca48d2-2048\tfiles/dir1/random_2048\t2008-09-22T00:18:37Z
1fffb088a74a48447ee612dcab91dacae86570ad-af6888a81369b7a1ecfbaf14791c5552-333\tfiles/dir1/random_333\t2008-09-22T00:10:06Z
c70053a7b8f6276ff22181364430e729c7f42c5a-96319d5ea553d5e39fd9c843759d3175-43\tfiles/dir1/textfile\t2008-09-22T00:09:38Z
07b8074463668967f6030016d719ef326eb6382d-6dce58e78b13dab939de6eef142b7543-41\tfiles/dir1/year_1969\t1969-01-21T17:12:15Z
2113343435a9aadb458d576396d4f960071f8efd-6babaa47123f4f94ae59ed581a65090b-41\tfiles/dir1/year_2038\t2038-01-19T03:14:07Z
END
	    "smsum: files/dir1/chmod_0000: Cannot read file\n",
	    1,
	    "Read files from dir1/ with mtime",
	);

	# }}}
	likecmd("cat files/dir1/random_2048 | $CMD -m", # {{{
	    '/^bd91a93ca0462da03f2665a236d7968b0fd9455d-4a3074b2aae565f8558b7ea707ca48d2-2048\\t-\\t20\\d\\d-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-6]\\dZ\\n$/',
	    '/^$/',
	    0,
	    "Read data from stdin with mtime",
	);

	# }}}

	ok(chmod(0644, "files/dir1/chmod_0000"), "chmod(0644, 'files/dir1/chmod_0000')");
	ok(unlink(glob("files/dir1/*")), 'Delete files in files/dir1/*');
	ok(rmdir("files/dir1"), 'rmdir files/dir1');

	todo_section:
	;

	if ($Opt{'all'} || $Opt{'todo'}) {
		diag('Running TODO tests...');
		TODO: {
			local $TODO = '';
			# Insert TODO tests here.
		}
	}

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
	return;
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

sub create_file {
	# Create new file and fill it with data
	my ($file, $text) = @_;
	my $retval = 0;

	open(my $fp, ">$file") or return 0;
	print($fp $text);
	close($fp);
	$retval = is(file_data($file), $text,
	             "$file was successfully created");

	return $retval; # 0 if error, 1 if ok
}

sub print_version {
	# Print program version
	print("$progname $VERSION\n");
	return;
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

sub msg {
	# Print a status message to stderr based on verbosity level
	my ($verbose_level, $Txt) = @_;

	$verbose_level > $Opt{'verbose'} && return;
	print(STDERR "$progname: $Txt\n");
	return;
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

# vim: set ts=4 sw=4 sts=4 noet fo+=w tw=79 fenc=UTF-8 :
