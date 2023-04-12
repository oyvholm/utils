#!/usr/bin/env perl

#==============================================================================
# ga.t
# File ID: c4726d6a-bf17-11eb-9d68-4f45262dc9b5
#
# Test suite for ga(1).
#
# Character set: UTF-8
# ©opyleft 2021– Øyvind A. Holm <sunny@sunbase.org>
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

our $CMDB = "ga";

our $CMD = "../$CMDB";

my $Lh = "[0-9a-fA-F]";
my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";

our %Opt = (

	'all' => 0,
	'git' => 'git',
	'git-annex' => 'git-annex',
	'help' => 0,
	'quiet' => 0,
	'todo' => 0,
	'verbose' => 0,
	'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.0.0'; # Not used here, $CMD decides

my %descriptions = ();

Getopt::Long::Configure('bundling');
GetOptions(

	'all|a' => \$Opt{'all'},
	'git-annex=s' => \$Opt{'git-annex'},
	'git=s' => \$Opt{'git'},
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

my $GIT = $Opt{'git'};
my $GIT_ANNEX = $Opt{'git-annex'};
my $exec_version = `$CMD --version`;
my $is_root = $< ? 0 : 1;

exit(main());

sub main {
	my $Retval = 0;

	diag('========== BEGIN version info ==========');
	diag($exec_version);
	diag('=========== END version info ===========');

	if ($Opt{'todo'} && !$Opt{'all'}) {
		goto todo_section;
	}

	test_standard_options();
	if (`$GIT_ANNEX version 2>/dev/null` !~ /^git-annex version/) {
		diag("git-annex is not installed here, skipping tests");
		return 0;
	}
	test_executable();

	diag('========== BEGIN version info ==========');
	diag($exec_version);
	diag('=========== END version info ===========');

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

	diag('Testing --version option...');
	likecmd("$CMD --version",
	        '/^\S+ \d+\.\d+\.\d+/',
	        '/^$/',
	        0,
	        'Option --version returns version number');

	return;
}

sub test_executable {
	my $Tmptop = "tmp-$CMDB-t-$$-" . substr(rand, 2, 8);

	ok(mkdir($Tmptop), "mkdir [Tmptop]");
	safe_chdir($Tmptop, "chdir [Tmptop]");

	chomp($ENV{'HOME'} = `pwd`);
	like($ENV{'HOME'}, "/$Tmptop\$/",
	     "HOME environment variable contains [Tmptop]");
	testcmd("$GIT config --global user.name 'Suttleif Fisen'", "", "", 0,
	        "$GIT config --global user.name 'Suttleif Fisen'");
	testcmd("$GIT config --global user.email suttleif\@example.com",
	        "", "", 0,
	        "$GIT config --global user.email suttleif\@example.com");
	testcmd("$GIT config --global init.defaultbranch master", "", "", 0,
	        "$GIT config --global init.defaultbranch master");
	testcmd("$GIT config --global annex.backend SHA256", "", "", 0,
	        "$GIT config --global annex.backend SHA256");
	ok(-f ".gitconfig", ".gitconfig exists");

	my $suuid_logdir = "$ENV{'HOME'}/suuid_logdir";
	$ENV{'SUUID_LOGDIR'} = $suuid_logdir;
	like($ENV{'SUUID_LOGDIR'}, "/suuid_logdir\$/",
	     'SUUID_LOGDIR environment variable contains "suuid_logdir"');
	ok(mkdir($suuid_logdir), "mkdir suuid_logdir");

	test_init_command();
	my $suuid_file = glob("$suuid_logdir/*.xml");
	like($suuid_file, '/.*\.xml$/', 'suuid file found by glob()');
	test_chk_command();
	test_copnum_command();

	diag("Clean up");
	ok(unlink($suuid_file), 'Delete suuid file');
	ok(rmdir($suuid_logdir), 'Delete suuid_logdir');
	delete_dir(".cache");
	delete_dir(".ssh");
	ok(unlink(".gitconfig"), "Delete .gitconfig");
	safe_chdir("..");
	ok(rmdir($Tmptop), "rmdir [Tmptop]");

	return;
}

sub test_init_command {
	diag("init");
	init_annex("t_init");
	safe_chdir("t_init");
	ok(-d ".git/annex", ".git/annex directory exists");
	like(`$GIT config --get annex.uuid`, "/^$v1_templ\\n/",
	     "UUID is version 1");
	safe_chdir("..");
	delete_dir("t_init");

	return;
}

sub test_chk_command {
	init_annex('t_chk');
	safe_chdir('t_chk');

	create_file('okfile', "This is file 1.\n");
	ga_add('okfile', 'Add okfile in t_chk/');
	git_commit('Add okfile', 'Commit okfile in t_chk/');
	testcmd("$CMD chk okfile",
	        "okfile ok\n",
	        "",
	        0,
	        "Check okfile");

	create_file('with space.txt', "File with space in filname.\n");
	ga_add('"with space.txt"', 'Add "with space.txt" in t_chk/');
	git_commit('Add file with space in filename',
	           'Commit "with space.txt" in t_chk/');
	testcmd("$CMD chk 'with space.txt'",
	        "with space.txt ok\n",
	        "",
	        0,
	        'Check "with space.txt"');

	create_file('errfile', "File with frrors.\n");
	ga_add('errfile', 'Add errfile in t_chk/');
	git_commit('Add errfile', 'Commit errfile in t_chk/');
	my $errkey = 'SHA256-s18--db1f5def94d1ace370d322ebb5bb8ee84b3f2ea7eb7445c8b8143fe1c9455c96';
	my $errobjdir = ".git/annex/objects/pJ/gJ/$errkey";
	my $errobjfile = "$errobjdir/$errkey";
	testcmd("chmod +w -R \"$errobjdir\"", "", "", 0,
	        "Make [errobjdir] writable");
	create_file($errobjfile, "File with errors.\n",
	            "Overwrite [errobjfile] with different data");
	testcmd("$CMD chk errfile",
	        "errfile fail\n",
	        "",
	        1,
	        "Check errfile");

	SKIP: {
		skip("Running tests as root", 14) if ($is_root);

		create_file('unrfile', "Unreadable file.\n");
		ga_add('unrfile', 'Add unrfile in t_chk/');
		git_commit('Add unrfile', 'Commit unrfile in t_chk/');
		my $unrkey = 'SHA256-s17--93bd33a38896168b87271a6ee3ffacbed5b2b6c32b07dd784eb1e9be2e8c9c1a';
		my $unrobjdir = ".git/annex/objects/64/5V/$unrkey";
		my $unrobjfile = "$unrobjdir/$unrkey";
		testcmd("chmod +w -R \"$unrobjdir\"", "", "", 0,
		        "Make [unrobjdir] writable");
		ok(chmod(0000, $unrobjfile),
		   'Remove all permissions from [unrobjfile]');
		testcmd("$CMD chk unrfile",
		        "",
		        "$CMDB: unrfile: File is not readable by you\n",
		        1,
		        "Check unrfile when it's not readable");
	}

	testcmd("$CMD chk nonexistent",
	        "",
	        "$CMDB: nonexistent: File not found\n",
	        1,
	        "Check nonexistent");

	testcmd("$CMD chk ''",
	        "",
	        "$CMDB: : File not found\n",
	        1,
	        "Check empty filename");

	ok(mkdir('directory'), 'mkdir directory');
	testcmd("$CMD chk directory",
	        "",
	        "$CMDB: directory: Is a directory\n",
	        0,
	        "File is a directory");

	ok(symlink('directory', 'dirlink'), 'Create symlink to directory');
	testcmd("$CMD chk dirlink",
	        "",
	        "$CMDB: dirlink: Is a symlink to a directory\n",
	        0,
	        "File is a symlink to a directory");

	create_file('not-here', "This file is not here.\n");
	ga_add('not-here', 'Add not-here in t_chk/');
	git_commit('Add not-here', 'Commit not-here in t_chk/');
	ga_drop('not-here', 'Drop not-here');
	testcmd("$CMD chk not-here",
	        "",
	        "$CMDB: not-here: File not present here\n",
	        0,
	        "Check not-here");

	create_file('regfile', "Regular file.\n");
	testcmd("$CMD chk regfile",
	        "",
	        "$CMDB: regfile: Not a symbolic link\n",
	        0,
	        "Check regfile");

	ok(symlink('regfile', 'regfilelink'), 'Create regfilelink');
	testcmd("$CMD chk regfilelink",
	        "",
	        "$CMDB: regfilelink: SHA256 key not found in symlink\n",
	        0,
	        "Check regfilelink");

	ok(symlink('brokendest', 'brokenlink'), 'Create brokenlink');
	testcmd("$CMD chk brokenlink",
	        "",
	        "$CMDB: brokenlink: Broken symlink\n",
	        0,
	        "Check brokenlink");

	testcmd("$CMD chk *",
	        ""
	        . "errfile fail\n"
	        . "okfile ok\n"
	        . "with space.txt ok\n",
	        ""
	        . "$CMDB: brokenlink: Broken symlink\n"
	        . "$CMDB: directory: Is a directory\n"
	        . "$CMDB: dirlink: Is a symlink to a directory\n"
	        . "$CMDB: not-here: File not present here\n"
	        . "$CMDB: regfile: Not a symbolic link\n"
	        . "$CMDB: regfilelink: SHA256 key not found in symlink\n"
	        . ($is_root ? ""
	                    : "$CMDB: unrfile: File is not readable by you\n"),
	        1,
	        'Test all files');

	safe_chdir('..');
	delete_dir('t_chk');

	return;
}

sub test_copnum_command {
	diag("copnum");
	init_annex("t_copnum");
	safe_chdir("t_copnum");
	testcmd("$CMD copnum", "1\n", "", 0, "copnum is 1 by default");
	testcmd("$GIT_ANNEX numcopies 3",
	        "numcopies 3 ok\n"
	        . "(recording state in git...)\n",
	        "",
	        0,
	        "Set numcopies to 3");
	testcmd("$CMD copnum", "3\n", "", 0, "copnum is 3");
	safe_chdir("..");
	delete_dir("t_copnum");

	return;
}

sub delete_dir {
	my $dir = shift;

	SKIP: {
		skip("delete_dir(): $dir doesn't exist", 6) unless (-d $dir);
		testcmd("chmod +w -R \"$dir\"", "", "", 0,
		        "Make everything in $dir/ writable");
		testcmd("rm -rf \"$dir\"", "", "", 0,
		        "Delete $dir/");
	}

	return;
}

sub ga_add {
	my ($file, $desc) = @_;

	if (!defined($desc) || !length($desc)) {
		$desc = "ga add $file";
	}

	likecmd("$CMD add $file",
	        '/^add .*ok\n/s',
	        '/^$/',
	        0,
	        $desc);

	return;
}

sub ga_drop {
	my ($file, $desc) = @_;

	if (!defined($desc) || !length($desc)) {
		$desc = "ga add $file";
	}

	ok(-e $file, "$file exists");
	likecmd("$CMD drop --force $file",
	        '/^drop .* ok\n/',
	        '/^$/',
	        0,
	        $desc);

	return;
}

sub git_commit {
	my ($logmsg, $desc) = @_;

	if (!defined($logmsg) || !length($logmsg)) {
		BAIL_OUT('git_commit(): $logmsg not defined');
	}

	likecmd("$GIT commit -m \"$logmsg\"",
	        '/'
	        . '.*'
	        . quotemeta($logmsg)
	        . '.*'
	        . '/',
	        '/^$/',
	        0,
	        $desc);

	return;
}

sub git_init {
	my $dir = shift;

	ok(!-e $dir, "git_init(): $dir doesn't exist")
	|| BAIL_OUT("git_init(): $dir already exists, aborting");
	likecmd("$GIT init \"$dir\"", '/.*/', '/^$/', 0, "$GIT init \"$dir\"");

	return;
}

sub init_annex {
	my $dir = shift;

	git_init($dir);
	safe_chdir($dir);
	likecmd("$CMD init",
	        '/^'
	        . 'init \S+:.*\/'
	        . $dir
	        . " .*" # New versions print "(scanning for unlocked files...)"
	        . 'ok\n'
	        . '.*'
	        . '/s',
	        "/^$v1_templ\\n\$/",
	        0,
	        "ga init in $dir");
	likecmd("$CMD info",
	        "/$v1_templ -- "
	        . '\S+:.*\/' . $dir . ' \[here\]\n'
	        . '/',
	        '/Have disabled git annex pre-commit/',
	        0,
	        "ga info in $dir");
	safe_chdir("..");

	return;
}

sub safe_chdir {
	my ($dir, $desc) = @_;
	defined($desc) || ($desc = '');

	ok(chdir($dir), length($desc) ? $desc : "chdir $dir")
	|| BAIL_OUT("$progname: Can't chdir to $dir, aborting");
	if ($dir eq "..") {
		$CMD =~ s!^\.\./!!
		|| BAIL_OUT('safe_chdir(): $dir is "..",'
		            . ' but $CMD doesn\'t start with "../"');
	} else {
		$CMD = "../$CMD";
	}

	return;
}

sub testcmd {
	my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
	defined($descriptions{$Desc})
	&& BAIL_OUT("testcmd(): '$Desc' description is used twice");
	$descriptions{$Desc} = 1;
	my $stderr_cmd = '';
	my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
	my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
	my $TMP_STDERR = "$CMDB-stderr.tmp";
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
	defined($descriptions{$Desc})
	&& BAIL_OUT("likecmd(): '$Desc' description is used twice");
	$descriptions{$Desc} = 1;
	my $stderr_cmd = '';
	my $cmd_outp_str = $Opt{'verbose'} >= 1 ? "\"$Cmd\" - " : '';
	my $Txt = join('', $cmd_outp_str, defined($Desc) ? $Desc : '');
	my $TMP_STDERR = "$CMDB-stderr.tmp";
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
	my ($file, $text, $desc) = @_;
	my $retval = 0;

	if (!defined($desc) || !length($desc)) {
		$desc = "$file was successfully created";
	}

	open(my $fp, ">", $file) or return 0;
	print($fp $text);
	close($fp);
	$retval = is(file_data($file), $text, $desc);

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

Contains tests for the $CMDB(1) program.

Options:

  -a, --all
    Run all tests, also TODOs.
  --git PATH
    Specify path to alternative git(1) executable.
  --git-annex PATH
    Specify path to alternative git-annex(1) executable.
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
