#!/usr/bin/perl

#=======================================================================
# finduuid.t
# File ID: 008facd0-f988-11dd-bf3b-000475e441b9
# Test suite for finduuid(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
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

our $Debug = 0;
our $CMD = '../finduuid';

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
our $VERSION = '0.00';

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'debug' => \$Opt{'debug'},
    'help|h' => \$Opt{'help'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

diag(sprintf('========== Executing %s v%s ==========',
    $progname,
    $VERSION));

if ($Opt{'todo'} && !$Opt{'all'}) {
    goto todo_section;
}

=pod

testcmd("$CMD command", # {{{
    <<'END',
[expected stdin]
END
    "",
    "description",
);

# }}}

=cut

diag('Testing -h (--help) option...');
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    'Option -h prints help screen',
);

# }}}
diag('Testing -v (--verbose) option...');
likecmd("$CMD -hv", # {{{
    '/^\n\S+ v\d\.\d\d\n/s',
    '/^$/',
    'Option --version with -h returns version number and help screen',
);

# }}}
diag('Testing --version option...');
likecmd("$CMD --version", # {{{
    '/^\S+ v\d\.\d\d\n/',
    '/^$/',
    'Option --version returns version number',
);

# }}}
testcmd("$CMD </dev/null", # {{{
    "",
    "",
    "Read empty input",
);

# }}}
testcmd("$CMD finduuid-files/std-random", # {{{
    <<END,
2bd76352-88d5-11dd-8848-000475e441b9
END
    "",
    "Find UUID inside random data",
);

# }}}
testcmd("$CMD <finduuid-files/std-random", # {{{
    <<END,
2bd76352-88d5-11dd-8848-000475e441b9
END
    "",
    "Read random data from stdin",
);

# }}}
testcmd("$CMD finduuid-files/compact", # {{{
    <<END,
daa9b45c-88d5-11dd-be73-000475e441b9
c2680b68-144e-4f4e-9c1c-3fbb758a94d2
db3b0506-88d5-11dd-8e5b-000475e441b9
8b592e20-245f-4860-8ebf-0cbd5e2cf072
dbbee448-88d5-11dd-bf1c-000475e441b9
07370456-ea42-4808-bc74-e24602e52172
dc6d9380-88d5-11dd-beb6-000475e441b9
07ac5c92-f413-4fb3-b0c5-fa9d25cac4ff
dd293036-88d5-11dd-84ca-000475e441b9
6396c79f-859a-404b-b285-b71288973b3b
END
    "",
    "Search file with many UUIDs stacked toghether",
);

# }}}
diag("Testing -f (--file) option...");
testcmd("$CMD -f finduuid-files/std-random finduuid-files/textfile", # {{{
    <<END,
finduuid-files/std-random:2bd76352-88d5-11dd-8848-000475e441b9
finduuid-files/textfile:9829c1a8-88d5-11dd-9a24-000475e441b9
finduuid-files/textfile:fd5d1200-88da-11dd-b7cf-000475e441b9
finduuid-files/textfile:9829C1A8-88D5-11DD-9A24-000475E441B9
finduuid-files/textfile:9829C1A8-88D5-11DD-9A24-000475E441B9
finduuid-files/textfile:4e4e8d08-9b38-11df-9954-3793b0cfdf88
finduuid-files/textfile:9829C1A8-88D5-11DD-9A24-000475E441B9
finduuid-files/textfile:fd5d1200-88da-11dd-b7cf-000475e441b9
finduuid-files/textfile:ced8e04e-9b57-11df-9b37-d97f703ed9b7
finduuid-files/textfile:0625e3ca-9b6d-11df-bc5b-f1285fef4db2
finduuid-files/textfile:0629cc60-9b6d-11df-867d-bde64fd0a5c7
finduuid-files/textfile:062c7a0a-9b6d-11df-94d2-638823d95bf3
finduuid-files/textfile:062edbf6-9b6d-11df-9e48-0d35319cdba1
finduuid-files/textfile:0625e3ca-9b6d-11df-bc5b-f1285fef4db2
finduuid-files/textfile:0629cc60-9b6d-11df-867d-bde64fd0a5c7
finduuid-files/textfile:062c7a0a-9b6d-11df-94d2-638823d95bf3
finduuid-files/textfile:062edbf6-9b6d-11df-9e48-0d35319cdba1
END
    "",
    "Option --filenames lists file name",
);

# }}}
testcmd("$CMD -f <finduuid-files/std-random", # {{{
    <<END,
-:2bd76352-88d5-11dd-8848-000475e441b9
END
    "",
    "List file name when reading from stdin",
);

# }}}
diag("Testing -l (--line) option...");
testcmd("$CMD -l finduuid-files/textfile", # {{{
    <<END,
4 dfv dsf 9829c1a8-88d5-11dd-9a24-000475e441b9
6 fd5d1200-88da-11dd-b7cf-000475e441b9
8 once more 9829C1A8-88D5-11DD-9A24-000475E441B9
9 yet another one 9829C1A8-88D5-11DD-9A24-000475E441B9
10 unique + dup 4e4e8d08-9b38-11df-9954-3793b0cfdf88 9829C1A8-88D5-11DD-9A24-000475E441B9
11 dup + unique fd5d1200-88da-11dd-b7cf-000475e441b9 ced8e04e-9b57-11df-9b37-d97f703ed9b7
12 four uniques 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
13 four dups 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
END
    "",
    "Print whole line with UUID",
);

# }}}
testcmd("$CMD -l <finduuid-files/textfile", # {{{
    <<END,
4 dfv dsf 9829c1a8-88d5-11dd-9a24-000475e441b9
6 fd5d1200-88da-11dd-b7cf-000475e441b9
8 once more 9829C1A8-88D5-11DD-9A24-000475E441B9
9 yet another one 9829C1A8-88D5-11DD-9A24-000475E441B9
10 unique + dup 4e4e8d08-9b38-11df-9954-3793b0cfdf88 9829C1A8-88D5-11DD-9A24-000475E441B9
11 dup + unique fd5d1200-88da-11dd-b7cf-000475e441b9 ced8e04e-9b57-11df-9b37-d97f703ed9b7
12 four uniques 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
13 four dups 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
END
    "",
    "Read from stdin and print whole line with UUID",
);

# }}}
testcmd("$CMD -lf finduuid-files/textfile finduuid-files/text2", # {{{
    <<END,
finduuid-files/textfile:4 dfv dsf 9829c1a8-88d5-11dd-9a24-000475e441b9
finduuid-files/textfile:6 fd5d1200-88da-11dd-b7cf-000475e441b9
finduuid-files/textfile:8 once more 9829C1A8-88D5-11DD-9A24-000475E441B9
finduuid-files/textfile:9 yet another one 9829C1A8-88D5-11DD-9A24-000475E441B9
finduuid-files/textfile:10 unique + dup 4e4e8d08-9b38-11df-9954-3793b0cfdf88 9829C1A8-88D5-11DD-9A24-000475E441B9
finduuid-files/textfile:11 dup + unique fd5d1200-88da-11dd-b7cf-000475e441b9 ced8e04e-9b57-11df-9b37-d97f703ed9b7
finduuid-files/textfile:12 four uniques 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
finduuid-files/textfile:13 four dups 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
finduuid-files/text2:here 08CCB59A-88E1-11DD-A80C-000475E441B9blabla
END
    "",
    "Print filename and whole line with UUID",
);

# }}}
testcmd("$CMD -l finduuid-files/compact", # {{{
    <<END,
daa9b45c-88d5-11dd-be73-000475e441b9c2680b68-144e-4f4e-9c1c-3fbb758a94d2db3b0506-88d5-11dd-8e5b-000475e441b98b592e20-245f-4860-8ebf-0cbd5e2cf072dbbee448-88d5-11dd-bf1c-000475e441b907370456-ea42-4808-bc74-e24602e52172dc6d9380-88d5-11dd-beb6-000475e441b907ac5c92-f413-4fb3-b0c5-fa9d25cac4ffdd293036-88d5-11dd-84ca-000475e441b96396c79f-859a-404b-b285-b71288973b3b
END
    "",
    "Print whole line containg many UUIDs",
);

# }}}
diag("Testing -u (--unique) option...");
testcmd("$CMD --unique -l finduuid-files/textfile", # {{{
    <<END,
4 dfv dsf 9829c1a8-88d5-11dd-9a24-000475e441b9
6 fd5d1200-88da-11dd-b7cf-000475e441b9
10 unique + dup 4e4e8d08-9b38-11df-9954-3793b0cfdf88 9829C1A8-88D5-11DD-9A24-000475E441B9
11 dup + unique fd5d1200-88da-11dd-b7cf-000475e441b9 ced8e04e-9b57-11df-9b37-d97f703ed9b7
12 four uniques 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
END
    "",
    "Print whole line with only one UUID + --unique works",
);

# }}}
testcmd("$CMD -u -l <finduuid-files/textfile", # {{{
    <<END,
4 dfv dsf 9829c1a8-88d5-11dd-9a24-000475e441b9
6 fd5d1200-88da-11dd-b7cf-000475e441b9
10 unique + dup 4e4e8d08-9b38-11df-9954-3793b0cfdf88 9829C1A8-88D5-11DD-9A24-000475E441B9
11 dup + unique fd5d1200-88da-11dd-b7cf-000475e441b9 ced8e04e-9b57-11df-9b37-d97f703ed9b7
12 four uniques 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
END
    "",
    "Read from stdin and print unique uuids",
);

# }}}
testcmd("$CMD -u -lf finduuid-files/textfile finduuid-files/text2", # {{{
    <<END,
finduuid-files/textfile:4 dfv dsf 9829c1a8-88d5-11dd-9a24-000475e441b9
finduuid-files/textfile:6 fd5d1200-88da-11dd-b7cf-000475e441b9
finduuid-files/textfile:10 unique + dup 4e4e8d08-9b38-11df-9954-3793b0cfdf88 9829C1A8-88D5-11DD-9A24-000475E441B9
finduuid-files/textfile:11 dup + unique fd5d1200-88da-11dd-b7cf-000475e441b9 ced8e04e-9b57-11df-9b37-d97f703ed9b7
finduuid-files/textfile:12 four uniques 0625e3ca-9b6d-11df-bc5b-f1285fef4db2 0629cc60-9b6d-11df-867d-bde64fd0a5c7 062c7a0a-9b6d-11df-94d2-638823d95bf3 062edbf6-9b6d-11df-9e48-0d35319cdba1
finduuid-files/text2:here 08CCB59A-88E1-11DD-A80C-000475E441B9blabla
END
    "",
    "Print filename and whole line with unique uuids",
);

# }}}
testcmd("$CMD -u finduuid-files/textfile finduuid-files/text2", # {{{
    <<END,
9829c1a8-88d5-11dd-9a24-000475e441b9
fd5d1200-88da-11dd-b7cf-000475e441b9
4e4e8d08-9b38-11df-9954-3793b0cfdf88
ced8e04e-9b57-11df-9b37-d97f703ed9b7
0625e3ca-9b6d-11df-bc5b-f1285fef4db2
0629cc60-9b6d-11df-867d-bde64fd0a5c7
062c7a0a-9b6d-11df-94d2-638823d95bf3
062edbf6-9b6d-11df-9e48-0d35319cdba1
08CCB59A-88E1-11DD-A80C-000475E441B9
END
    "",
    "Several files, -u only",
);

# }}}

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

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'finduuid-stderr.tmp';

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
    return;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'finduuid-stderr.tmp';

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

Contains tests for the finduuid(1) program.

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
    return;
    # }}}
} # msg()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 SYNOPSIS

finduuid.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the finduuid(1) program.

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

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation, either version 3 of the License, or (at your 
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
