#!/usr/bin/perl -w

#=======================================================================
# $Id$
# Test suite for smsum(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

BEGIN {
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    our @version_array;
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use strict;
use Getopt::Long;

$| = 1;

our $Debug = 0;
our $CMD = "../smsum";

our %Opt = (
    'all' => 0,
    'debug' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,
);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;

my $rcs_id = '$Id$';
my $id_date = $rcs_id;
$id_date =~ s/^.*?\d+ (\d\d\d\d-.*?\d\d:\d\d:\d\d\S+).*/$1/;

push(@main::version_array, $rcs_id);

Getopt::Long::Configure("bundling");
GetOptions(
    "all|a" => \$Opt{'all'},
    "debug" => \$Opt{'debug'},
    "help|h" => \$Opt{'help'},
    "todo|t" => \$Opt{'todo'},
    "verbose|v+" => \$Opt{'verbose'},
    "version" => \$Opt{'version'},
) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

if ($Opt{'todo'} && !$Opt{'all'}) {
    goto todo_section;
}

=pod

testcmd("$CMD command", # {{{
    <<END,
[expected stdin]
END
    "",
    "description",
);

# }}}

=cut

diag("Testing -h (--help) option...");
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    "Option -h prints help screen",
);

# }}}
unlike(`$CMD -h`, # {{{
    '/\$Id: /',
    "No Id with only -h",
);

# }}}
diag("Testing -v (--verbose) option...");
likecmd("$CMD -hv", # {{{
    '/\$Id: .*? \$.*  Show this help\./s',
    '/^$/',
    "Option --version with -h returns Id string and help screen",
);

# }}}
diag("Testing --version option...");
likecmd("$CMD --version", # {{{
    '/\$Id: .*? \$/',
    '/^$/',
    "Option --version returns Id string",
);

# }}}

testcmd("$CMD files/dir1.tar.gz", # {{{
    <<END,
31226c9482573c4c323947858616ee174babdeb7-affeeed5dca3c6970e8a8eaf5277be90-3000\tfiles/dir1.tar.gz
END
    "",
    "Verify files/dir1.tar.gz",
);

# }}}
system("cd files && tar xzf dir1.tar.gz 2>/dev/null");

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
    "Read all files in dir1/",
);

# }}}
testcmd("cat files/dir1/random_2048 | $CMD", # {{{
    <<END,
bd91a93ca0462da03f2665a236d7968b0fd9455d-4a3074b2aae565f8558b7ea707ca48d2-2048
END
    "",
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
    "Read files from dir1/ with mtime",
);

# }}}
likecmd("cat files/dir1/random_2048 | $CMD -m", # {{{
    '/^bd91a93ca0462da03f2665a236d7968b0fd9455d-4a3074b2aae565f8558b7ea707ca48d2-2048\\t-\\t20\\d\\d-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-6]\\dZ\\n$/',
    '/^$/',
    "Read data from stdin with mtime",
);

# }}}

chmod(0644, "files/dir1/chmod_0000") || warn("$progname: files/dir1/chmod_0000: Cannot chmod to 0644: $!\n");
unlink(glob("files/dir1/*")) || warn("$progname: Cannot unlink() files in files/dir1/*: $!\n");
rmdir("files/dir1") || warn("$progname: files/dir1: Cannot rmdir(): $!\n");

todo_section:
;

if ($Opt{'all'} || $Opt{'todo'}) {
    diag("Running TODO tests..."); # {{{

    TODO: {

local $TODO = "";
# Insert TODO tests here.

    }
    # TODO tests }}}
}

diag("Testing finished.");

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Desc) = @_;
    my $stderr_cmd = "";
    my $deb_str = $Opt{'debug'} ? " --debug" : "";
    my $Txt = join("",
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ""
    );
    my $TMP_STDERR = "smsum-stderr.tmp";

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, $Exp_stdout, $Txt);
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    # }}}
}

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Desc) = @_;
    my $stderr_cmd = "";
    my $deb_str = $Opt{'debug'} ? " --debug" : "";
    my $Txt = join("",
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ""
    );
    my $TMP_STDERR = "smsum-stderr.tmp";

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", $Txt);
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            like(file_data($TMP_STDERR), "$Exp_stderr", "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    # }}}
}

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;
    if (open(FP, "<", $File)) {
        $Txt = join("", <FP>);
        close(FP);
        return($Txt);
    } else {
        return undef;
    }
    # }}}
}

sub print_version {
    # Print program version {{{
    for (@main::version_array) {
        print("$_\n");
    }
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<END);

Usage: $progname [options] [file [files [...]]]

Contains tests for the smsum(1) program.

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
  --debug
    Print debugging messages.

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
    # }}}
} # msg()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 REVISION

$Id$

=head1 SYNOPSIS

smsum.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the smsum(1) program.

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

=item B<--debug>

Print debugging messages.

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
with this program; if not, write to the Free Software Foundation, Inc., 
59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
# End of file $Id$
