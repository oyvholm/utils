#!/usr/bin/perl -w

#=======================================================================
# $Id$
# Test suite for gpst.
#
# Character set: UTF-8
# ©opyleft 2006– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

BEGIN {
    push(@INC, "$ENV{'HOME'}/bin/src/gpstools");
    our @version_array;
}

use strict;
use Getopt::Long;
use Test::More qw(no_plan);

use GPSTdate;
use GPSTdebug;
use GPSTgeo;
use GPSTxml;

$| = 1;

our $Debug = 0;

our %Opt = (
    'debug' => 0,
    'help' => 0,
    'version' => 0,
);

our $progname = $0;
$progname =~ s#^.*/(.*?)$#$1#;

my $rcs_id = '$Id$';
my $id_date = $rcs_id;
$id_date =~ s/^.*?\d+ (\d\d\d\d-.*?\d\d:\d\d:\d\d\S+).*/$1/;

Getopt::Long::Configure("bundling");
GetOptions(
    "debug" => \$Opt{'debug'},
    "help|h" => \$Opt{'help'},
    "version" => \$Opt{'version'},
) || die("$progname: Option error. Use -h for help.\n");

our %Cmd = (
    'gpsbabel' => '/usr/local/bin/gpsbabel',
);

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
$Opt{'version'} && print_version();

diag("Testing XML routines...");

# txt_to_xml() and xml_to_txt() {{{

is(txt_to_xml("abc"),
    "abc",
    "txt_to_xml(\"abc\")");
is(txt_to_xml("<&>"),
    "&lt;&amp;&gt;",
    "txt_to_xml(\"<&>\")");
is(txt_to_xml("first line\nsecond <\rthird\r\n<&>"),
    "first line\nsecond &lt;\rthird\r\n&lt;&amp;&gt;",
    "txt_to_xml() with multiline string");

is(xml_to_txt("abc"),
    "abc",
    "xml_to_txt(\"abc\")");
is(xml_to_txt("&lt;&amp;&gt;"),
    "<&>",
    "xml_to_txt(\"&lt;&amp;&gt;\")");
is(xml_to_txt("first line\nsecond &lt;\rthird\r\n&lt;&amp;&gt;"),
    "first line\nsecond <\rthird\r\n<&>",
    "xml_to_txt() with multiline string");

# }}}

diag("Testing date routines...");

# sec_to_string() {{{

is(sec_to_string(1148220825),
    "2006-05-21 14:13:45",
    "sec_to_string() without separator");
is(sec_to_string(1148220825, "T"),
    "2006-05-21T14:13:45",
    "sec_to_string() with separator");
is(sec_to_string(-5000),
    undef,
    "sec_to_string(-5000) — negative numbers unsupported atm");
is(sec_to_string(""),
    undef,
    "sec_to_string(\"\")");
is(sec_to_string("pH()rtY tW0"),
    undef,
    "sec_to_string() with invalid string");
is(sec_to_string("00000000000000000000001148220825"),
    "2006-05-21 14:13:45",
    "sec_to_string() with a bunch of leading zeros");
is(sec_to_string("1148220825.93"),
    "2006-05-21 14:13:45.93",
    "sec_to_string() with decimals");
is(sec_to_string("000000000000000000000000000001148220825.7312"),
    "2006-05-21 14:13:45.7312",
    "sec_to_string() with decimals and prefixing zeros");
is(sec_to_string("1148220825.93000"),
    "2006-05-21 14:13:45.93",
    "sec_to_string() with decimals and extra trailing zeros");
is(sec_to_string(".863"),
    "1970-01-01 00:00:00.863",
    "sec_to_string() with missing zero before decimal point");

# }}}
# sec_to_readable() {{{

is(sec_to_readable(0),
    "0:00:00:00",
    "sec_to_readable(0)");
is(sec_to_readable("pH()rtY tW0"),
    undef,
    "sec_to_readable() with invalid string");
is(sec_to_readable(86400),
    "1:00:00:00",
    "sec_to_readable(86400)");
is(sec_to_readable(86400*1000),
    "1000:00:00:00",
    "sec_to_readable(86400*1000)");
is(sec_to_readable(86400+7200+180+4),
    "1:02:03:04",
    "sec_to_readable(86400+7200+180+4)");
is(sec_to_readable("3.14"),
    "0:00:00:03.14",
    "sec_to_readable(\"3.14\")");
is(sec_to_readable("-124"),
    undef,
    "sec_to_readable() rejects negative numbers");
is(sec_to_readable("-2.34"),
    undef,
    "sec_to_readable() rejects negative decimal");
is(sec_to_readable(".87"),
    "0:00:00:00.87",
    "sec_to_readable(), missing zero before decimal point");
is(sec_to_readable(""),
    "0:00:00:00",
    "sec_to_readable() with empty string");

# }}}

diag("Testing geo routines...");

# ddd_to_dms() {{{

is(ddd_to_dms("12.34567"),
    "12\xB020'44.4\"",
    "ddd_to_dms(\"12.34567\")");

is(ddd_to_dms("0"),
    "0\xB000'00.0\"",
    "ddd_to_dms(\"0\")");

is(ddd_to_dms(""),
    "0\xB000'00.0\"",
    "ddd_to_dms(\"\")");

is(ddd_to_dms("pH()rtY tW0"),
    undef,
    "ddd_to_dms(\"pH()rtY tW0\")");

is(ddd_to_dms("-12.34567"),
    "-12\xB020'44.4\"",
    "ddd_to_dms(\"-12.34567\")");

is(ddd_to_dms("0.34567"),
    "0\xB020'44.4\"",
    "ddd_to_dms(\"0.34567\")");

is(ddd_to_dms(".34567"),
    "0\xB020'44.4\"",
    "ddd_to_dms(\".34567\")");

is(ddd_to_dms("-.34567"),
    "-0\xB020'44.4\"",
    "ddd_to_dms(\"-.34567\")");

is(ddd_to_dms("-0.34567"),
    "-0\xB020'44.4\"",
    "ddd_to_dms(\"-0.34567\")");

is(ddd_to_dms("180"),
    "180\xB000'00.0\"",
    "ddd_to_dms(\"180\")");

is(ddd_to_dms("-180"),
    "-180\xB000'00.0\"",
    "ddd_to_dms(\"-180\")");

is(ddd_to_dms("-1"),
    "-1\xB000'00.0\"",
    "ddd_to_dms(\"-1\")");

is(ddd_to_dms("2-3"),
    undef,
    "ddd_to_dms(\"2-3\")");

# }}}
# list_nearest_waypoints() {{{

like(list_nearest_waypoints(60.42541, 5.29959, 3),
    qr/^\(.*,.*,.*\)$/,
    "list_nearest_waypoints()");

# }}}

diag("Testing output from ../gpst");

like(`../gpst --version`, # {{{
    qr/^(\$Id: .*? \$\n)+$/s,
    "gpst --version");

# }}}
is(`../gpst </dev/null`, # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
</track>
</gpsml>
END
    "gpst </dev/null");

# }}}
is(`../gpst -o gpx </dev/null`, # {{{
    <<END,
<?xml version="1.0" standalone="no"?>
<gpx>
  <trk>
    <trkseg>
    </trkseg>
  </trk>
</gpx>
END
    "gpst -o gpx </dev/null");

# }}}
is(`../gpst --fix --chronology chronology-error.gpsml 2>chronofix.tmp`, # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>\$Id: chronology-error.gpsml 1774 2006-05-20 02:48:39Z sunny \$</title>
<tp> <time>2006-05-02T09:46:37Z</time> <lat>60.45369</lat> <lon>5.31559</lon> <ele>95</ele> </tp>
<tp> <time>2006-05-02T09:46:42Z</time> <lat>60.45353</lat> <lon>5.31548</lon> <ele>94</ele> </tp>
<tp> <time>2006-05-02T09:46:46Z</time> <lat>60.45353</lat> <lon>5.31561</lon> <ele>94</ele> </tp>
<break/>
<etp> <time>2006-05-02T09:40:07Z</time> <lat>60.45369</lat> <lon>5.31597</lon> <desc>Out of chronology</desc> </etp>
<break/>
<pause>0:00:37:54</pause>
<tp> <time>2006-05-02T10:18:01Z</time> <lat>60.45418</lat> <lon>5.31517</lon> <ele>92</ele> </tp>
<tp> <time>2006-05-02T10:18:06Z</time> <lat>60.45407</lat> <lon>5.31542</lon> <ele>91</ele> </tp>
<tp> <time>2006-05-02T10:18:09Z</time> <lat>60.45401</lat> <lon>5.31543</lon> <ele>98</ele> </tp>
<tp> <time>2006-05-02T10:18:10Z</time> <lat>60.45395</lat> <lon>5.31544</lon> <ele>103</ele> </tp>
<tp> <time>2006-05-02T10:18:11Z</time> <lat>60.45391</lat> <lon>5.31545</lon> <ele>107</ele> </tp>
</track>
</gpsml>
END
    "gpst --fix --chronology chronology-error.gpsml");

# }}}
is(file_data("chronofix.tmp"), # {{{
    "gpst: \"2006-05-02T09:46:46Z\": Next date is 0:00:06:39 in the past (2006-05-02T09:40:07Z)\n",
    "Warning from --chronology --fix");
unlink("chronofix.tmp") || warn("chronofix.tmp: Cannot delete file: $!\n");

# }}}
is(`../gpst -t pause.gpx`, # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>ACTIVE LOG164705</title>
<tp> <time>2006-05-21T16:49:11Z</time> <lat>60.425494</lat> <lon>5.299534</lon> <ele>25.26</ele> </tp>
<tp> <time>2006-05-21T16:49:46Z</time> <lat>60.425464</lat> <lon>5.29961</lon> <ele>24.931</ele> </tp>
<pause>0:00:02:18</pause>
<tp> <time>2006-05-21T16:52:04Z</time> <lat>60.425314</lat> <lon>5.299694</lon> <ele>27.975</ele> </tp>
<pause>0:00:04:32</pause>
<tp> <time>2006-05-21T16:56:36Z</time> <lat>60.425384</lat> <lon>5.299741</lon> <ele>31.017</ele> </tp>
<tp> <time>2006-05-21T16:56:47Z</time> <lat>60.425339</lat> <lon>5.299958</lon> <ele>30.98</ele> </tp>
<tp> <time>2006-05-21T16:56:56Z</time> <lat>60.425238</lat> <lon>5.29964</lon> <ele>30.538</ele> </tp>
<tp> <time>2006-05-21T16:57:03Z</time> <lat>60.425246</lat> <lon>5.299686</lon> <ele>30.515</ele> </tp>
<pause>0:00:02:05</pause>
<tp> <time>2006-05-21T16:59:08Z</time> <lat>60.425345</lat> <lon>5.299773</lon> <ele>31.936</ele> </tp>
<tp> <time>2006-05-21T17:00:54Z</time> <lat>60.425457</lat> <lon>5.299419</lon> <ele>31.794</ele> </tp>
</track>
</gpsml>
END
    "gpst -t pause.gpx");

# }}}

diag("Testing finished.");

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
    print("$rcs_id\n");
    exit(0);
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    print(<<END);

$rcs_id

Usage: $progname [options] [file [files [...]]]

Contains tests for the gpst(1) program.

Options:

  -h, --help
    Show this help.
  --version
    Print version information.
  --debug
    Print debugging messages.

END
    exit($Retval);
    # }}}
} # usage()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME



=head1 REVISION

$Id$

=head1 SYNOPSIS

 [options] [file [files [...]]]

=head1 DESCRIPTION



=head1 OPTIONS

=over 4

=item B<-h>, B<--help>

Print a brief help summary.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 BUGS



=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm &lt;sunny@sunbase.org&gt;
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
