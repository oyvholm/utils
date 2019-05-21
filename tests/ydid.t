#!/usr/bin/env perl

#==============================================================================
# ydid.t
# File ID: 53506c76-23d9-11e9-a4b6-4f45262dc9b5
#
# Test suite for ydid(1).
#
# Character set: UTF-8
# ©opyleft 2019– Øyvind A. Holm <sunny@sunbase.org>
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

our $CMD_BASENAME = "ydid";
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
our $VERSION = '0.0.0';

my %deburl = (
	'go1' => "https://www.google.com/url*url=*",
	'tw1' => "https://twitter.com/*/status/*",
	'yt1' => "https://www.youtube.com/watch?v=*",
	'yt2' => "https://youtu.be/*",
	'yt3' => "plain id",
);
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

	diag(sprintf('========== Executing %s v%s ==========',
	             $progname, $VERSION));

	if ($Opt{'todo'} && !$Opt{'all'}) {
		goto todo_section;
	}

	test_standard_options();
	test_executable();
	test_create_url_option();

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

sub test_executable {
	my ($id, $url);
	$id = "su045ytF_z4";

	diag("Executing test_executable()");
	testcmd("$CMD",
	        "",
	        "$CMD_BASENAME: No URL specified\n",
	        1,
	        'No URL specified');
	testcmd("$CMD https://doesntexist.invalid",
	        "",
	        "$CMD_BASENAME: Unknown URL format\n",
	        1,
	        'Unknown URL format');
	diag("Plain id");
	test_yt_url($id, $id, $deburl{'yt3'}, "Plain id");
	testcmd("$CMD " . "a" x 10,
	        "",
	        "$CMD_BASENAME: Unknown URL format\n",
	        1,
	        'Plain id, one character too short');
	testcmd("$CMD " . "a" x 12,
	        "",
	        "$CMD_BASENAME: Unknown URL format\n",
	        1,
	        'Plain id, one character too long');
	testcmd("$CMD aaaaa,aaaaa",
	        "",
	        "$CMD_BASENAME: Invalid Youtube ID\n",
	        1,
	        'Plain id with invalid character');

	for my $p (qw{ https http }) {
		diag("Use $p");
		diag($deburl{'yt1'});

		for my $w ("www.", "") {
			testcmd("$CMD $p://${w}youtube.com/watch?v=",
				"",
				"$CMD_BASENAME: Invalid URL\n",
				1,
				"v= has no id, $p://$w*");

			testcmd("$CMD $p://${w}youtube.com/watch?v=abcde,ghijk",
				"",
				"$CMD_BASENAME: Invalid URL\n",
				1,
				"v= contains invalid character, $p://$w*");
			$url = "$p://${w}youtube.com/watch?v=$id";
			diag($url);
			test_yt_url($id, $url, $deburl{'yt1'}, $url);
			test_yt_url($id, "$url&t=0s", $deburl{'yt1'},
			            "$url&t=0s");
			$url = "$p://${w}youtube.com/watch?t=0s&v=$id";
			diag($url);
			test_yt_url($id, $url, $deburl{'yt1'}, $url);
			test_yt_url($id, "$url&abc=def", $deburl{'yt1'},
			            "$url&abc=def");

			diag($deburl{'yt2'});
			testcmd("$CMD $p://${w}youtu\.be/",
				"",
				"$CMD_BASENAME: Invalid URL\n",
				1,
				"Missing id in $deburl{'yt2'}, $p://$w*");

			testcmd("$CMD $p://${w}youtu\.be/abcde,ghijk",
				"",
				"$CMD_BASENAME: Invalid URL\n",
				1,
				"Invalid character in $deburl{'yt2'}, $p://$w*");

			$url = "$p://${w}youtu.be/$id";
			diag($url);
			test_yt_url($id, $url, $deburl{'yt2'}, $url);
			test_yt_url($id, "$url&t=0s", $deburl{'yt2'}, "$url&t=0s");
		}

		my $twid = "1234567890123456789";
		my $twname = "example";
		for my $w ("www.", "") {
			$url = "$p://${w}twitter.com/$twname/status/$twid";
			test_yt_url($twid, $url, $deburl{'tw1'}, $url);
			test_yt_url($twid, "$url?abc=def", $deburl{'tw1'},
			            "$url?abc=def");
			$url = "$p://${w}twitter.com/$twname/status/";
			testcmd("$CMD $url",
				"",
				"$CMD_BASENAME: Unknown URL format\n",
				1,
				"Missing Twitter ID, $p://$w*");
			$url = "$p://${w}twitter.com/$twname/status/abc";
			testcmd("$CMD $url",
				"",
				"$CMD_BASENAME: Unknown URL format\n",
				1,
				"Non-digit in Twitter ID, $p://$w*");
		}

		# Google URL, gzip + base64:
		# H4sIAAAAAAACAx3OzWrCQBQF4H3fI3dXQxMFFS5l1ISogRiKbbaTyTBj1E4zv
		# +jTmxTO6nDgfNLaP7OO4xDCTCglbnzG1D12+vZpKFrQzGIPAwI3mqEBo5xmHA
		# NvgXX4AYx2qHsKjo7DJXjeYULl+ZiFC5sPfJEcWkFkcxn25lh8iXKzEvVjew2
		# kUNmWnOtNDeMXyokRpSRK8jET5qGcde2/ZmqoZTJKcx+lu6fdZ0rketXPwRmB
		# pPLfNKRs8TyUp6b67Ypd48sf8+6b6u0Fo5rSbeAAAAA=
		my $goid = "ztIEogFr9j4";
		for my $w ("www.", "") {
			my $url = "$p://${w}google.com/url?sa=t" .
			          "&rct=j" .
			          "&q=" .
			          "&esrc=s" .
			          "&source=web" .
			          "&cd=1" .
			          "&cad=rja" .
			          "&uact=8" .
			          "&ved=2ahUKEwic4qe52JbgAhXiqIsKHSgLB9gQyCk" .
			            "wAHoECAUQBQ" .
			          "&url=https%3A%2F%2Fwww.youtube.com%2F" .
			            "watch%3Fv%3DztIEogFr9j4" .
			          "&usg=AOvVaw3c5zJLPXOndHDXvLWs-vXO";
			testcmd("$CMD -vv '$url'",
			        "$goid\n",
			        "$CMD_BASENAME: url = \"$url\"\n" .
			          "$CMD_BASENAME: Found $deburl{'go1'}\n" .
			          "$CMD_BASENAME: url = " .
			            "\"https://www.youtube.com/watch?" .
			            "v=$goid\"\n" .
			          "$CMD_BASENAME: Found $deburl{'yt1'}\n",
			        0,
			        "$p://${w}google.com url to Youtube video");
			my $egoid = $goid;
			$egoid =~ s/g/,/;
			$url =~ s/$goid/$egoid/;
			testcmd("$CMD -vv '$url'",
			        "",
			        "$CMD_BASENAME: url = \"$url\"\n" .
			          "$CMD_BASENAME: Found $deburl{'go1'}\n" .
			          "$CMD_BASENAME: url = " .
			            "\"https://www.youtube.com/watch?" .
			            "v=$egoid\"\n" .
			          "$CMD_BASENAME: Found $deburl{'yt1'}\n" .
			          "$CMD_BASENAME: Invalid URL\n",
			        1,
			        "$p://${w}google.com url has invalid char " .
			          "in id");

			$twid = '1' x 19;
			$url = "$p://${w}google.com/url?sa=t&rct=j&" .
			       "&url=https%3A%2F%2Ftwitter.com%2Fabc%2F" .
			            "status%2F$twid%3Flang%3Den";
			testcmd("$CMD -vv '$url'",
			        "$twid\n",
			        "$CMD_BASENAME: url = \"$url\"\n" .
			          "$CMD_BASENAME: Found $deburl{'go1'}\n" .
			          "$CMD_BASENAME: url = " .
			            "\"https://twitter.com/abc/status/$twid" .
			            "?lang=en\"\n" .
			          "$CMD_BASENAME: Found $deburl{'tw1'}\n",
			        0,
			        "$p://${w}google.com url with twitter url");
		}
	}
}

sub test_create_url_option {
	my $id = "ztIEogFr9j4";
	my $google_url = "https://google.com/url?sa=t" .
		  "&rct=j" .
		  "&url=https%3A%2F%2Fwww.youtube.com%2F" .
		    "watch%3Fv%3D$id" .
		  "&q=";
	my $url_yt1 = "https://www.youtube.com/watch?v=$id";
	my $url_yt2 = "https://youtu.be/$id";

	for my $o ("-c", "--create-url") {
		test_c_url($o, $url_yt1, $url_yt1, $id, $deburl{'yt1'});
		test_c_url($o, $url_yt2, $url_yt1, $id, $deburl{'yt2'});
		test_c_url($o, $id, $url_yt1, $id, $deburl{'yt3'});
		test_c_url($o, $google_url, $url_yt1, $id, $deburl{'go1'});

		my $eid = $id;
		$eid =~ s/g/,/;
		my $gurl = $google_url;
		$gurl =~ s/$id/$eid/;
		testcmd("$CMD -vv $o '$gurl'",
		        "",
		        "$CMD_BASENAME: url = \"$gurl\"\n" .
		          "$CMD_BASENAME: Found $deburl{'go1'}\n" .
		          "$CMD_BASENAME: url = " .
		            "\"https://www.youtube.com/watch?" .
		            "v=$eid\"\n" .
		          "$CMD_BASENAME: Found $deburl{'yt1'}\n" .
		          "$CMD_BASENAME: Invalid URL\n",
		        1,
		        "Invalid char in google url, $o");

		for my $p ("https", "http") {
			for my $w ("www.", "") {
				my $id = "1234567890";
				my $user = "example";
				my $genurl = "https://twitter.com/$user/" .
				             "status/$id";
				my $url = "$p://${w}twitter.com/$user/" .
				          "status/$id";

				for (1, 2) {
					test_c_url($o, $url, $genurl, $id,
					           $deburl{'tw1'});
					$url .= "?abc=def&jada=masa";
				}
			}
		}
	}
}

sub test_c_url {
	my ($o, $arg, $url, $id, $deburl) = @_;
	my $debtxt = "$CMD_BASENAME: url = \"$arg\"\n" .
	             "$CMD_BASENAME: Found $deburl\n";

	if ($deburl eq $deburl{'go1'}) {
		$debtxt .= "ydid: url = \"https://www.youtube.com/" .
		             "watch?v=$id\"\n" .
		           "ydid: Found $deburl{'yt1'}\n";
	}

	testcmd("$CMD -vv $o '$arg'", "$url\n", $debtxt, 0, "$o '$arg'");
}

sub test_yt_url {
	my ($id, $url, $deburl, $desc) = @_;

	testcmd("$CMD -vv '$url'",
	        "$id\n",
	        "$CMD_BASENAME: url = \"$url\"\n" .
	        "$CMD_BASENAME: Found $deburl\n",
	        0,
	        $desc);
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
