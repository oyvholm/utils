#!/usr/bin/perl -w

#=======================================================================
# $Id$
# Test suite for gpst-pic(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

BEGIN {
    push(@INC, "$ENV{'HOME'}/bin/src/gpstools");
    our @version_array;
    use Test::More qw{no_plan};
    use_ok(GPST);
    use_ok(GPSTxml);
}

use strict;
use Getopt::Long;

$| = 1;

our $Debug = 0;
our $CMD = "../../gpst-pic";

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

my @cmdline_array = @ARGV;

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

diag(sprintf("========== Executing \"%s%s%s\" ==========",
    $progname,
    scalar(@cmdline_array) ? " " : "",
    join(" ", @cmdline_array)));

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

diag("Checking dependencies...");
likecmd("exifprobe -V", # {{{
    "/Program: 'exifprobe' version [234]/",
    '/^$/',
    "Check that exifprobe(1) is installed",
);

# }}}
diag("Testing --author option...");
testcmd("$CMD -a sunny files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27\t\\N\t\\N\tDSC_4426.JPG\tsunny
END
    "",
    "Read date from DSC_4426.JPG and set --author",
);

# }}}
# diag("Testing --debug option...");
diag("Testing --description option...");
testcmd("$CMD -d 'Skumle til\\stander i Bergen.' files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27\t\\N\tSkumle til\\\\stander i Bergen.\tDSC_4426.JPG\t\\N
END
    "",
    "Read date from DSC_4426.JPG and set --description with backslash",
);

# }}}
diag("Testing -h (--help) option...");
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    "Option -h prints help screen",
);

# }}}
unlike(`$CMD -h`, # {{{
    '/\$Id: /',
    "\"$CMD -h\" - No Id with only -h",
);

# }}}
diag("Testing --output-format option..."); # {{{
# pgtab
testcmd("$CMD -o pgtab files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27\t\\N\t\\N\tDSC_4426.JPG\t\\N
END
    "",
    "Output pgtab format from DSC_4426.JPG",
);

# }}}
# xml
testcmd("$CMD -o xml files/DSC_4426.JPG", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpstpic>
  <img>
    <filename>DSC_4426.JPG</filename>
    <date>2008-09-18T17:02:27</date>
  </img>
</gpstpic>
END
    "",
    "Output XML information for DSC_4426.JPG",
);

# }}}
# Unknown format
testcmd("$CMD -o blurfl files/DSC_4426.JPG", # {{{
    "",
    "gpst-pic: blurfl: Unknown output format\n",
    "Unknown output format specified",
);

# }}}
# }}} --output-format
diag("Testing -T (--timezone) option...");
testcmd("$CMD --timezone +1234 files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27+1234\t\\N\t\\N\tDSC_4426.JPG\t\\N
END
    "",
    "--timezone works",
);

# }}}
testcmd("$CMD -T +0200 files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27+0200\t\\N\t\\N\tDSC_4426.JPG\t\\N
END
    "",
    "Positive time zone",
);

# }}}
testcmd("$CMD -T-0600 files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27-0600\t\\N\t\\N\tDSC_4426.JPG\t\\N
END
    "",
    "Negative time zone",
);

# }}}
testcmd("$CMD -T CET files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27 CET\t\\N\t\\N\tDSC_4426.JPG\t\\N
END
    "",
    "Time zone abbreviation",
);

# }}}
testcmd("$CMD -T Z files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27Z\t\\N\t\\N\tDSC_4426.JPG\t\\N
END
    "",
    "Zulu abbreviation",
);

# }}}
testcmd("$CMD -T erf324 files/DSC_4426.JPG", # {{{
    "",
    "gpst-pic: erf324: Invalid time zone\n",
    "Invalid time zone abbr, contains digits",
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
diag("Various...");
testcmd("$CMD files/DSC_4426.JPG", # {{{
    <<END,
1\t2008-09-18T17:02:27\t\\N\t\\N\tDSC_4426.JPG\t\\N
END
    "",
    "Read date from DSC_4426.JPG, no options",
);

# }}}

todo_section:
;

if ($Opt{'all'} || $Opt{'todo'}) {
    diag("Running TODO tests..."); # {{{

    TODO: {

local $TODO = "";
testcmd("$CMD -o extxml files/DSC_4426.JPG", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpstpic>
  <img>
    <filename>DSC_4426.JPG</filename>
    <crc type="sha1">267e841cb6788c795541e36aea70e2a55d8ec3bb</crc>
    <crc type="md5">19eb5c86f6b3662b57bc94c3ea428372</crc>
    <date type="DateTimeOriginal">2008-03-02T17:51:39Z</date>
    <date type="DateTimeDigitized">2008-03-02T17:51:39Z</date>
    <date type="DateTime">2008-09-18T15:02:27Z</date>
    <exposure>
      <iso>200</iso>
      <speed>0.333333</speed>
      <fnumber>3.5 APEX</fnumber>
      <flash>0</flash>
    </exposure>
    <camera>
      <make>NIKON CORPRORATION</make>
      <model>NIKON D300</model>
      <shuttercount>4610</shuttercount>
    </camera>
  </img>
</gpstpic>
END
    "",
    "Show extended XML information for DSC_4426.JPG",
);

# }}}

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
    my $TMP_STDERR = "gpst-pic-stderr.tmp";

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
    my $TMP_STDERR = "gpst-pic-stderr.tmp";

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

Contains tests for the gpst-pic(1) program.

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

gpst-pic.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the gpst-pic(1) program.

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

gpst(1)

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
# End of file $Id$
