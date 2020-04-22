#!/usr/bin/env perl

#==============================================================================
# mktar.t
# File ID: dd9b31a6-457a-11e8-96de-f74d993421b0
#
# Test suite for mktar(1).
#
# Character set: UTF-8
# ©opyleft 2018– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of file for 
# legal stuff.
#==============================================================================

use strict;
use warnings;

use File::Basename;

BEGIN {
	use Test::More qw{no_plan};
	# use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $CMD_BASENAME = "mktar";
our $CMD = "../$CMD_BASENAME";
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
our $VERSION = '0.0.0';

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
	my $logdir = "logdir.tmp";

	$ENV{'SUUID_LOGDIR'} = $logdir;

	diag(sprintf('========== Executing %s v%s ==========',
	             $progname, $VERSION));

	if ($Opt{'todo'} && !$Opt{'all'}) {
		goto todo_section;
	}

	test_standard_options();

	ok(chdir("mktar-files"), "chdir mktar-files") or
		BAIL_OUT("Cannot chdir");
	$CMD = "../$CMD";

	if (-e $logdir) {
		diag("NOTICE: $logdir exists, deleting it");
		system("rm -rf \"$logdir\"");
	}
	ok(mkdir("$logdir"), "mkdir $logdir");

	test_numeric_owner_option($CMD, $CMD_BASENAME, $logdir);
	test_output_dir_option($CMD, $CMD_BASENAME, $logdir);
	test_prefix_option($CMD, $CMD_BASENAME, $logdir);
	test_random_mac_option($CMD, $CMD_BASENAME, $logdir);
	test_no_uuid_option($CMD, $CMD_BASENAME, $logdir);
	# FIXME: Add more tests, cover all options
	diag("Clean up");
	testcmd("rm -rf \"$logdir\"", "", "", 0,
	        "Delete $logdir/ before exit");

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

sub test_numeric_owner_option {
	my ($CMD, $CMD_BASENAME, $logdir) = @_;

	diag("Test --numeric-owner option");
	SKIP: {
		skip("Running tests as root", 14) unless ($<);

		extract_tar_file("d.tar");
		testcmd("mv d has-numeric", "", "", 0, "mv d has-numeric");
		unlink("has-numeric.tar") if -e "has-numeric.tar";
		likecmd("$CMD -r --numeric-owner has-numeric",
			'/^$/',
			'/^' . join('',
				'.*',
				'mktar: Packing has-numeric\.\.\.\n',
				$v1_templ, '\n',
				'mktar: tar cf has-numeric\.tar ' .
					'--remove-files --force-local ' .
					'--sort=name --sparse ' .
					'--numeric-owner --xattrs ' .
					"--label=$v1_templ " .
					'has-numeric',
				'.*',
				'has-numeric\.tar',
			) . '$/s',
			0,
			"Use --numeric-owner",
		);

		my $uid = $>;
		my $gid = $);
		$gid =~ s/^(\d+)\b.*/$1/;
		likecmd("tar tvf has-numeric.tar",
			'/' . " $uid\\/$gid .+" x 8 . '/s',
			'/^$/',
			0,
			'has-numeric.tar contains numeric UID/GID',
		);

		ok(unlink("has-numeric.tar"), "Delete has-numeric.tar");
	}
}

sub test_output_dir_option {
	my ($CMD, $CMD_BASENAME, $logdir) = @_;
	my $pref = "output-dir";
	my $outd = "outd.tmp";

	diag("Test -o/--output-dir option");
	if (-e $pref) {
		diag("NOTICE: $pref exists, deleting it");
		system("rm -rf $pref")
	}
	extract_tar_file("d.tar");
	testcmd("mv d $pref", "", "", 0, "mv d $pref");
	unlink("$pref.tar") if -e "$pref.tar";
	if (-e $outd) {
		diag("NOTICE: $outd exists, deleting it");
		system("rm -rf $outd")
	}

	for my $p ("--output-dir", "-o") {
		ok(mkdir($outd), "mkdir $outd");
		likecmd("$CMD $p $outd $pref",
			'/^$/',
			'/^' . join('', '\n',
			  "mktar: Packing $pref\\.\\.\\.\\n",
			  $v1_templ, '\n',
			  "mktar: tar cf $outd\\/$pref\\.tar " .
			    '--force-local ' .
			    '--sort=name --sparse ' .
			    "--xattrs --label=$v1_templ $pref\\n" .
			    '.+',
			  "$pref\\.tar\\n",
			) . '$/s',
			0,
			"Use $p",
		);
		ok(-f "$outd/$pref.tar", "$outd/$pref.tar exists");
		ok(unlink("$outd/$pref.tar"), "Delete $outd/$pref.tar");
		testcmd("rm -rf $outd", "", "", 0, "rm -rf $outd after $p");
	}
	testcmd("rm -rf $pref", "", "", 0, "rm -rf $pref");
}

sub test_prefix_option {
	my ($CMD, $CMD_BASENAME, $logdir) = @_;

	extract_tar_file("d.tar");
	for my $p ("-P", "--prefix") {
		likecmd("$CMD $p tmp d",
		        '/^$/',
		        '/mktar: tar cf tmp\.d\.tar ' .
		            '--force-local --sort=name --sparse --xattrs ' .
		            "--label=$v1_templ " .
		            'd\\n/s',
		        0,
		        "Use \"tmp\" prefix with $p");
		ok(-f "tmp.d.tar", "tmp.d.tar exists");
		testcmd("tar df tmp.d.tar", "", "", 0,
		        "Contents of the tar file is identical to d/ " .
		        "after $p");
		ok(unlink("tmp.d.tar"), "Delete tmp.d.tar");
	}
	testcmd("rm -rf d", "", "", 0, "Delete d/ after -P/--prefix");
}

sub test_random_mac_option {
	my ($CMD, $CMD_BASENAME, $logdir) = @_;

	diag("Test -m/--random-mac option");
	extract_tar_file("d.tar");
	testcmd("mv d use-random-mac", "", "", 0, "mv d use-random-mac");
	unlink("use-random-mac.tar") if -e "use-random-mac.tar";
	likecmd("$CMD -rf --random-mac use-random-mac",
		'/^$/',
		'/^' . join('',
			'\n',
			'mktar: Packing use-random-mac\.\.\.\n',
			$v1_templ, '\n',
			'mktar: tar cf use-random-mac\.tar ' .
				'--remove-files --force-local ' .
				'--sort=name --sparse ' .
				'--xattrs ' .
				"--label=$v1_templ " .
				'use-random-mac',
			'.*',
			'use-random-mac\.tar',
		) . '$/s',
		0,
		"Use --random-mac",
	);
	ok(unlink("use-random-mac.tar"), "Delete use-random-mac.tar");
}

sub test_no_uuid_option {
	my ($CMD, $CMD_BASENAME, $logdir) = @_;

	diag("Test --no-uuid option");
	extract_tar_file("d.tar");
	testcmd("mv d no-uuid", "", "", 0, "mv d no-uuid");
	unlink("no-uuid.tar") if -e "no-uuid.tar";
	likecmd("$CMD -r --no-uuid no-uuid",
		'/^$/',
		'/^' . join('',
			'\n',
			'mktar: Packing no-uuid\.\.\.\n',
			'mktar: tar cf no-uuid\.tar ' .
				'--remove-files --force-local ' .
				'--sort=name --sparse ' .
				'--xattrs no-uuid',
			'.*',
			'no-uuid\.tar',
		) . '$/s',
		0,
		"Use --no-uuid",
	);
	testcmd("tar tf no-uuid.tar",
		join("\n",
			"no-uuid/",
			"no-uuid/brokenlink.txt",
			"no-uuid/d/",
			"no-uuid/d/subfile.txt",
			"no-uuid/emptydir/",
			"no-uuid/file.txt",
			"no-uuid/sublink.txt",
			"no-uuid/symlink.txt",
			"",
		),
		"",
		0,
		"no-uuid.tar doesn't contain UUID label",
	);
	ok(unlink("no-uuid.tar"), "Delete no-uuid.tar");
}

sub extract_tar_file {
	my $file = shift;

	testcmd("tar xf \"$file\"", "", "", 0, "Extract $file");
	undef $descriptions{"Extract $file"};
	my $base = basename($file, ".tar");
	ok(-d $base, "$base/ exists and is a directory");
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

# vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 :
