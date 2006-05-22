#!/usr/bin/perl -w

#=======================================================================
# $Id$
# [Description]
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

diag("Check that testing is working");

is(1 + 1 + 1, 3, "One and one and one is three"); # got to be goodlooking ’cause he’s so hard to see

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

diag("Testing finished.");

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
