#!/usr/bin/perl -w

#=======================================================================
# $Id$
# Test suite for gpst.
#
# Character set: UTF-8
# ©opyleft 2006– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

BEGIN {
    push(@INC, "$ENV{'HOME'}/bin/src/gpstools");
    our @version_array;
}

use strict;
use Getopt::Long;
use Test::More qw{no_plan};

use GPST;
use GPSTdate;
use GPSTdebug;
use GPSTgeo;
use GPSTxml;

$| = 1;

our $Debug = 0;

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

our %Cmd = (
    'gpsbabel' => '/usr/local/bin/gpsbabel',
);

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
$Opt{'version'} && print_version();

chomp(my $gpx_header = <<END);
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx
  version="1.1"
  creator="gpst - http://svn.sunbase.org/repos/utils/trunk/src/gpstools/"
  xmlns="http://www.topografix.com/GPX/1/1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
>
END
my $stripped_gpx_header = $gpx_header;
$stripped_gpx_header =~ s/^\s*(.*)$/$1/mg;

if ($Opt{'todo'} && !$Opt{'all'}) {
    goto todo_section;
}

diag("Testing conversion routines...");

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

# txt_to_xml() and xml_to_txt() }}}
# postgresql_copy_safe() {{{

is(postgresql_copy_safe(""),
    "",
    "postgresql_copy_safe() with empty string");

is(postgresql_copy_safe("abcæøåÆØÅ"),
    "abcæøåÆØÅ",
    "postgresql_copy_safe(\"abcæøåÆØÅ\")");

is(postgresql_copy_safe("abc\t'\r\n"),
    "abc\\t'\\r\\n",
    "postgresql_copy_safe(\"abc\\t'\\r\\n\")");

is(postgresql_copy_safe("¤%/&gurgle\t325\\wer\ndfv'\r!\"#\n%\twe\r\x00sdf\xFFsadc\n\t\x00sdc\n"),
    "¤%/&gurgle\\t325\\\\wer\\ndfv'\\r!\"#\\n%\\twe\\r\x00sdf\xFFsadc\\n\\t\x00sdc\\n",
    "postgresql_copy_safe() with multiline, nulls and stuff");

# postgresql_copy_safe() }}}

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

# sec_to_string() }}}
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

# sec_to_readable() }}}

diag("Testing geo routines...");

# ddd_to_dms() {{{

is(ddd_to_dms("12.34567"),
    "12\xB020'44.4\"",
    "ddd_to_dms(\"12.34567\")");

is(ddd_to_dms("0"),
    "0\xB000'00.0\"",
    "ddd_to_dms(\"0\")");

is(ddd_to_dms("0.00001"),
    "0\xB000'00.0\"",
    "ddd_to_dms(\"0.00001\") — Precision of DDD with five decimals");

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

# ddd_to_dms() }}}
# dms_to_ddd() {{{
is(dms_to_ddd(),
    0,
    "dms_to_ddd() with no parameters");
is(dms_to_ddd(0, 0, 0),
    0,
    "dms_to_ddd(0, 0, 0)");
is(dms_to_ddd(12, 30, 45),
    12.5125,
    "dms_to_ddd(12, 30, 45)");
is(dms_to_ddd("asd", 0, 0),
    undef,
    "dms_to_ddd() with invalid degrees");
is(dms_to_ddd(0, "asd", 0),
    undef,
    "dms_to_ddd() with invalid minutes");
is(dms_to_ddd(0, 0, "asd"),
    undef,
    "dms_to_ddd() with invalid seconds");
is(dms_to_ddd("", 0, 0),
    0,
    "dms_to_ddd() with empty degree string");
is(dms_to_ddd(0, 0, ""),
    0,
    "dms_to_ddd() with empty second string");
is(dms_to_ddd(-12, 30, 45),
    undef,
    "dms_to_ddd() doesn’t accept negative degrees atm");
is(dms_to_ddd(12, -30, 45),
    undef,
    "dms_to_ddd() doesn’t accept negative minutes atm");
is(dms_to_ddd(12, 30, -45),
    undef,
    "dms_to_ddd() doesn’t accept negative seconds atm");
# Weird behaviour, this scientific notation thing.
is(num_expand(sprintf("%.08f", dms_to_ddd(0, 0, 0.1))),
    "0.00002778",
    "dms_to_ddd(0, 0, 0.1) — Precision of DMS with one decimal");
is(dms_to_ddd(2, 30),
    2.5,
    "dms_to_ddd(2, 30)");
is(dms_to_ddd(4),
    4,
    "dms_to_ddd(4)");
is(dms_to_ddd(4.3),
    4.3,
    "dms_to_ddd(4.3)");
is(dms_to_ddd(120.5, 0.3),
    120.505,
    "dms_to_ddd(120.5, 0.3)");

# dms_to_ddd() }}}

diag("Testing trackpoint()..."); # {{{

my %Dat = ();

is(trackpoint(%Dat),
    undef,
    "trackpoint() receives empty hash");

my %Bck = (
    # {{{
    'format' => 'gpsml',
    'year' => '2003',
    'month' => '06',
    'day' => '13',
    'hour' => '14',
    'min' => '36',
    'sec' => '10',
    'lat' => '59.5214',
    'lon' => '7.392133',
    'ele' => '762',
    'error' => "",
    'type' => 'tp',
    # }}}
);

# trackpoint() (gpsml) {{{
%Dat = %Bck;
is(
    trackpoint(%Dat),
    "<tp> <time>2003-06-13T14:36:10Z</time> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
    "trackpoint() (gpsml)"
);

# trackpoint() (gpsml) }}}
# trackpoint() (gpx) {{{
%Dat = %Bck;
$Dat{'format'} = "gpx";
is(
    trackpoint(%Dat),
    qq{      <trkpt lat="59.5214" lon="7.392133"> <ele>762</ele> <time>2003-06-13T14:36:10Z</time> </trkpt>\n},
    "trackpoint() (gpx)"
);

# trackpoint() (gpx) }}}

# trackpoint(): Various loop tests {{{

for my $Elem (qw{format lat lon type}) {
    my %Dat = %Bck;

    $Dat{"$Elem"} = '2d';
    is(trackpoint(%Dat),
        undef,
        "trackpoint(): {'$Elem'} with invalid value (\"$Dat{$Elem}\") returns undef"
    );

}

for my $Elem (qw{year month day hour min sec}) {
    # Date tests {{{
    my %Dat;

    %Dat = %Bck;
    $Dat{"$Elem"} = '';
    is(trackpoint(%Dat),
        "<tp> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
        "trackpoint(): {'$Elem'} with empty value skips time"
    );

    %Dat = %Bck;
    $Dat{"$Elem"} = '2d';
    is(trackpoint(%Dat),
        "<tp> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
        "trackpoint(): {'$Elem'} with invalid value (\"$Dat{$Elem}\") skips time"
    );

    %Dat = %Bck;
    $Dat{$Elem} = "00000$Dat{$Elem}";
    is(trackpoint(%Dat),
        "<tp> <time>2003-06-13T14:36:10Z</time> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
        "trackpoint(): Strip prefixing zeros from {'$Elem'}"
    );

    %Dat = %Bck;
    $Dat{"$Elem"} = 0-$Dat{$Elem};
    is(trackpoint(%Dat),
        "<tp> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
        "trackpoint(): {'$Elem'} is negative, skip time"
    );

    if ($Elem ne "sec") {
        %Dat = %Bck;
        $Dat{"$Elem"} = "$Dat{$Elem}.00";
        is(trackpoint(%Dat),
            "<tp> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
            "trackpoint(): Decimals in {'$Elem'}, skip time"
        );
    }

    # Date tests }}}
}

%Dat = %Bck;
$Dat{'sec'} = "$Dat{'sec'}.00";
is(trackpoint(%Dat),
    "<tp> <time>2003-06-13T14:36:10Z</time> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
    "trackpoint(): Remove trailing zeros in {'sec'} decimals"
);

for my $Elem (qw{format type error}) {
    my %Dat = %Bck;
    $Dat{$Elem} = undef;
    is(trackpoint(%Dat),
        undef,
        "trackpoint(): Missing {'$Elem'}, return undef"
    );
}

# Various loop tests }}}

# trackpoint() }}}

diag("Testing output from ../gpst");

diag("Read empty input (/dev/null)..."); # {{{
testcmd("../gpst </dev/null", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
</track>
</gpsml>
END
    "",
    "Read from /dev/null",
);

# }}}
testcmd("../gpst -o gpx </dev/null", # {{{
    <<END,
$gpx_header
  <trk>
    <trkseg>
    </trkseg>
  </trk>
</gpx>
END
    "",
    "Output gpx from /dev/null",
);

# }}}
# empty input }}}
diag("Read empty files..."); # {{{
testcmd("echo '<tp> </tp>' | ../gpst", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
</track>
</gpsml>
END
    "",
    "Don’t print empty trackpoints",
);

# }}}
# Read empty files }}}
diag("Testing --chronology option..."); # {{{
testcmd("../gpst --chronology chronology-error.gpsml", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Chronology errors</title>
<tp> <time>2006-05-02T09:46:37Z</time> <lat>60.45369</lat> <lon>5.31559</lon> <ele>95</ele> </tp>
<tp> <time>2006-05-02T09:46:42Z</time> <lat>60.45353</lat> <lon>5.31548</lon> <ele>94</ele> </tp>
<tp> <time>2006-05-02T09:46:46Z</time> <lat>60.45353</lat> <lon>5.31561</lon> <ele>94</ele> </tp>
<break/>
<tp> <time>2006-05-02T09:40:07Z</time> <lat>60.45369</lat> <lon>5.31597</lon> <desc>Out of chronology</desc> </tp>
<break/>
<pause>0:00:37:54</pause>
<tp> <time>2006-05-02T10:18:01Z</time> <lat>60.45418</lat> <lon>5.31517</lon> <ele>92</ele> </tp>
<tp> <time>2006-05-02T10:18:06Z</time> <lat>60.45407</lat> <lon>5.31542</lon> <ele>91</ele> </tp>
<tp> <time>2006-05-02T10:18:09Z</time> <lat>60.45401</lat> <lon>5.31543</lon> <ele>98</ele> </tp>
<tp> <time>2006-05-02T10:18:09Z</time> <lat>60.45401</lat> <lon>5.31543</lon> <ele>98</ele> </tp>
<tp> <time>2006-05-02T10:18:10Z</time> <lat>60.45395</lat> <lon>5.31544</lon> <ele>103</ele> </tp>
<tp> <time>2006-05-02T10:18:11Z</time> <lat>60.45391</lat> <lon>5.31545</lon> <ele>107</ele> </tp>
</track>
</gpsml>
END
    "gpst: chronology-error.gpsml: \"2006-05-02T09:46:46Z\": Next date is 0:00:06:39 in the past (2006-05-02T09:40:07Z)\n" .
    "gpst: chronology-error.gpsml: \"2006-05-02T10:18:09Z\": Duplicated time\n",
    "Check for chronology errors and duplicated times",
);

# }}}
# --chronology option }}}
diag("Testing --skip-dups option..."); # {{{
testcmd("../gpst -d no_signal.mayko", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<tp> <time>2002-12-22T21:42:24Z</time> <lat>70.6800486</lat> <lon>23.6746151</lon> </tp>
<tp> <time>2002-12-22T21:42:32Z</time> <lat>70.6799322</lat> <lon>23.6740038</lon> </tp>
<tp> <time>2002-12-22T21:42:54Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </tp>
<etp err="dup"> <time>2002-12-22T21:43:51Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<etp err="dup"> <time>2002-12-22T21:43:52Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<etp err="dup"> <time>2002-12-22T21:43:54Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<tp> <time>2002-12-22T21:44:45Z</time> <lat>70.6800774</lat> <lon>23.6757566</lon> </tp>
<tp> <time>2002-12-22T21:44:52Z</time> <lat>70.6801502</lat> <lon>23.6753442</lon> </tp>
<tp> <time>2002-12-22T21:45:04Z</time> <lat>70.6801905</lat> <lon>23.6757542</lon> </tp>
</track>
</gpsml>
END
    "",
    "Remove duplicated positions from gpsml",
);

# }}}
testcmd("../gpst -d -o csv no_signal.mayko", # {{{
    <<END,
2002-12-22T21:42:24Z\t23.6746151\t70.6800486\t\t
2002-12-22T21:42:32Z\t23.6740038\t70.6799322\t\t
2002-12-22T21:42:54Z\t23.6723991\t70.6796266\t\t
2002-12-22T21:44:45Z\t23.6757566\t70.6800774\t\t
2002-12-22T21:44:52Z\t23.6753442\t70.6801502\t\t
2002-12-22T21:45:04Z\t23.6757542\t70.6801905\t\t
END
    "",
    "Remove duplicated positions from csv output format",
);

# }}}
testcmd("../gpst -d -o clean no_signal.mayko", # {{{
    <<END,
23.6746151\t70.6800486\t
23.6740038\t70.6799322\t
23.6723991\t70.6796266\t
23.6757566\t70.6800774\t
23.6753442\t70.6801502\t
23.6757542\t70.6801905\t
END
    "",
    "Remove duplicated positions from clean output format",
);

# }}}
testcmd("../gpst -d -o pgtab no_signal.mayko", # {{{
    <<END,
2002-12-22T21:42:24Z\t(70.6800486,23.6746151)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:42:32Z\t(70.6799322,23.6740038)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:42:54Z\t(70.6796266,23.6723991)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:44:45Z\t(70.6800774,23.6757566)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:44:52Z\t(70.6801502,23.6753442)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:45:04Z\t(70.6801905,23.6757542)\t\\N\t\\N\t\\N\t\\N\t\\N
END
    "",
    "Remove duplicated positions from pgtab output format",
);

# }}}
# --skip-dups option }}}
diag("Testing --epoch option..."); # {{{
testcmd("../gpst -e pause.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>ACTIVE LOG164705</title>
<tp> <time>2006-05-21T16:49:11Z</time> <lat>60.425494</lat> <lon>5.299534</lon> <ele>25.26</ele> </tp>
<tp> <time>2006-05-21T16:49:46Z</time> <lat>60.425464</lat> <lon>5.29961</lon> <ele>24.931</ele> </tp>
<tp> <time>2006-05-21T16:52:04Z</time> <lat>60.425314</lat> <lon>5.299694</lon> <ele>27.975</ele> </tp>
<tp> <time>2006-05-21T16:56:36Z</time> <lat>60.425384</lat> <lon>5.299741</lon> <ele>31.017</ele> </tp>
<tp> <time>2006-05-21T16:56:47Z</time> <lat>60.425339</lat> <lon>5.299958</lon> <ele>30.98</ele> </tp>
<tp> <time>2006-05-21T16:56:56Z</time> <lat>60.425238</lat> <lon>5.29964</lon> <ele>30.538</ele> </tp>
<tp> <time>2006-05-21T16:57:03Z</time> <lat>60.425246</lat> <lon>5.299686</lon> <ele>30.515</ele> </tp>
<tp> <time>2006-05-21T16:59:08Z</time> <lat>60.425345</lat> <lon>5.299773</lon> <ele>31.936</ele> </tp>
<tp> <time>2006-05-21T17:00:54Z</time> <lat>60.425457</lat> <lon>5.299419</lon> <ele>31.794</ele> </tp>
</track>
</gpsml>
END
    "",
    "--epoch is ignored in gpsml output",
);

# }}}
testcmd("../gpst -e -o gpx pause.gpx", # {{{
    <<END,
$gpx_header
  <trk>
    <trkseg>
      <trkpt lat="60.425494" lon="5.299534"> <ele>25.260</ele> <time>2006-05-21T16:49:11Z</time> </trkpt>
      <trkpt lat="60.425464" lon="5.299610"> <ele>24.931</ele> <time>2006-05-21T16:49:46Z</time> </trkpt>
      <trkpt lat="60.425314" lon="5.299694"> <ele>27.975</ele> <time>2006-05-21T16:52:04Z</time> </trkpt>
      <trkpt lat="60.425384" lon="5.299741"> <ele>31.017</ele> <time>2006-05-21T16:56:36Z</time> </trkpt>
      <trkpt lat="60.425339" lon="5.299958"> <ele>30.980</ele> <time>2006-05-21T16:56:47Z</time> </trkpt>
      <trkpt lat="60.425238" lon="5.299640"> <ele>30.538</ele> <time>2006-05-21T16:56:56Z</time> </trkpt>
      <trkpt lat="60.425246" lon="5.299686"> <ele>30.515</ele> <time>2006-05-21T16:57:03Z</time> </trkpt>
      <trkpt lat="60.425345" lon="5.299773"> <ele>31.936</ele> <time>2006-05-21T16:59:08Z</time> </trkpt>
      <trkpt lat="60.425457" lon="5.299419"> <ele>31.794</ele> <time>2006-05-21T17:00:54Z</time> </trkpt>
    </trkseg>
  </trk>
</gpx>
END
    "",
    "--epoch is ignored in gpx output",
);

# }}}
# --epoch option }}}
diag("Testing --fix option..."); # {{{
testcmd("../gpst --fix --chronology chronology-error.gpsml", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Chronology errors</title>
<tp> <time>2006-05-02T09:46:37Z</time> <lat>60.45369</lat> <lon>5.31559</lon> <ele>95</ele> </tp>
<tp> <time>2006-05-02T09:46:42Z</time> <lat>60.45353</lat> <lon>5.31548</lon> <ele>94</ele> </tp>
<tp> <time>2006-05-02T09:46:46Z</time> <lat>60.45353</lat> <lon>5.31561</lon> <ele>94</ele> </tp>
<break/>
<etp err="chrono"> <time>2006-05-02T09:40:07Z</time> <lat>60.45369</lat> <lon>5.31597</lon> <desc>Out of chronology</desc> </etp>
<break/>
<pause>0:00:37:54</pause>
<tp> <time>2006-05-02T10:18:01Z</time> <lat>60.45418</lat> <lon>5.31517</lon> <ele>92</ele> </tp>
<tp> <time>2006-05-02T10:18:06Z</time> <lat>60.45407</lat> <lon>5.31542</lon> <ele>91</ele> </tp>
<tp> <time>2006-05-02T10:18:09Z</time> <lat>60.45401</lat> <lon>5.31543</lon> <ele>98</ele> </tp>
<etp err="duptime"> <time>2006-05-02T10:18:09Z</time> <lat>60.45401</lat> <lon>5.31543</lon> <ele>98</ele> </etp>
<tp> <time>2006-05-02T10:18:10Z</time> <lat>60.45395</lat> <lon>5.31544</lon> <ele>103</ele> </tp>
<tp> <time>2006-05-02T10:18:11Z</time> <lat>60.45391</lat> <lon>5.31545</lon> <ele>107</ele> </tp>
</track>
</gpsml>
END
    "gpst: chronology-error.gpsml: \"2006-05-02T09:46:46Z\": Next date is 0:00:06:39 in the past (2006-05-02T09:40:07Z)\n" .
    "gpst: chronology-error.gpsml: \"2006-05-02T10:18:09Z\": Duplicated time\n",
    "Remove bad timestamps",
);

# }}}
# --fix option }}}
diag("Testing --from-date option..."); # {{{
# --from-date option }}}
diag("Testing --help option..."); # {{{
like(`../gpst -h`, # {{{
    '/Converts between various GPS formats\./',
    "Check -h (--help) option"
);
# }}}
# --help option }}}
diag("Testing --inside option..."); # {{{
testcmd("../gpst --pos1 2.11,2.12 --pos2 3.31,3.32 --inside multitrack-pause.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>track1</title>
<break/>
<title>track2</title>
<tp> <time>2006-01-02T00:00:00Z</time> <lat>2.11</lat> <lon>2.12</lon> </tp>
<tp> <time>2006-01-02T00:00:04Z</time> <lat>2.21</lat> <lon>2.22</lon> </tp>
<tp> <time>2006-01-02T00:00:16Z</time> <lat>2.31</lat> <lon>2.32</lon> </tp>
<tp> <time>2006-01-02T01:00:16Z</time> <lat>2.41</lat> <lon>2.42</lon> </tp>
<break/>
<tp> <time>2006-01-02T01:00:17Z</time> <lat>2.451</lat> <lon>2.452</lon> </tp>
<break/>
<title>track3</title>
<tp> <time>2006-01-03T02:00:20Z</time> <lat>3.11</lat> <lon>3.12</lon> </tp>
<tp> <time>2006-01-03T02:00:21Z</time> <lat>3.21</lat> <lon>3.22</lon> </tp>
<tp> <time>2006-01-03T02:00:22Z</time> <lat>3.31</lat> <lon>3.32</lon> </tp>
</track>
</gpsml>
END
    "",
    "Check --inside option (gpx to gpst)",
);
# }}}

# --inside option }}}
diag("Testing --undefined option..."); # {{{
# --undefined option }}}
diag("Testing --near option..."); # {{{
# --near option }}}
diag("Testing --output option..."); # {{{
# gpsml (Default)
testcmd("../gpst log.mcsv", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<break/>
<title>ACTIVE LOG 125</title>
<tp> <time>2006-03-04T11:12:30Z</time> <lat>54.96883</lat> <lon>-1.62439</lon> <ele>77</ele> </tp>
<tp> <time>2006-03-04T11:12:47Z</time> <lat>54.96878</lat> <lon>-1.62413</lon> <ele>77</ele> </tp>
<tp> <time>2006-03-04T11:12:55Z</time> <lat>54.96913</lat> <lon>-1.62616</lon> <ele>77</ele> </tp>
<tp> <time>2006-03-04T11:13:04Z</time> <lat>54.96934</lat> <lon>-1.62624</lon> <ele>77.5</ele> </tp>
<tp> <time>2006-03-04T11:13:33Z</time> <lat>54.96934</lat> <lon>-1.62596</lon> <ele>78</ele> </tp>
<tp> <time>2006-03-04T11:13:48Z</time> <lat>54.96931</lat> <lon>-1.62645</lon> <ele>78</ele> </tp>
<tp> <time>2006-03-04T11:14:05Z</time> <lat>54.96918</lat> <lon>-1.62603</lon> <ele>79</ele> </tp>
<tp> <time>2006-03-04T11:14:33Z</time> <lat>54.96901</lat> <lon>-1.62364</lon> <ele>76.1</ele> </tp>
<tp> <time>2006-03-04T11:15:02Z</time> <lat>54.96922</lat> <lon>-1.6254</lon> <ele>76.1</ele> </tp>
<tp> <time>2006-03-04T11:15:27Z</time> <lat>54.96914</lat> <lon>-1.62526</lon> <ele>75.1</ele> </tp>
<tp> <time>2006-03-04T11:15:50Z</time> <lat>54.96911</lat> <lon>-1.62494</lon> <ele>75.1</ele> </tp>
<tp> <time>2006-03-04T11:16:03Z</time> <lat>54.9693</lat> <lon>-1.62489</lon> <ele>75.1</ele> </tp>
<tp> <time>2006-03-04T11:16:19Z</time> <lat>54.96901</lat> <lon>-1.62496</lon> <ele>75.1</ele> </tp>
<tp> <time>2006-03-04T11:16:52Z</time> <lat>54.96871</lat> <lon>-1.62466</lon> <ele>74.6</ele> </tp>
<tp> <time>2006-03-04T11:17:25Z</time> <lat>54.96908</lat> <lon>-1.62488</lon> <ele>72.7</ele> </tp>
<break/>
<title>ACTIVE LOG 126</title>
<tp> <time>2006-03-04T11:18:32Z</time> <lat>54.96904</lat> <lon>-1.62482</lon> <ele>72.7</ele> </tp>
<tp> <time>2006-03-04T11:18:35Z</time> <lat>54.96913</lat> <lon>-1.62499</lon> <ele>71.3</ele> </tp>
<tp> <time>2006-03-04T11:18:38Z</time> <lat>54.96904</lat> <lon>-1.62497</lon> <ele>70.8</ele> </tp>
<tp> <time>2006-03-04T11:18:48Z</time> <lat>54.96913</lat> <lon>-1.62496</lon> <ele>71.8</ele> </tp>
<tp> <time>2006-03-04T11:18:55Z</time> <lat>54.96924</lat> <lon>-1.62501</lon> <ele>72.2</ele> </tp>
<tp> <time>2006-03-04T11:19:11Z</time> <lat>54.9694</lat> <lon>-1.62521</lon> <ele>71.8</ele> </tp>
<tp> <time>2006-03-04T11:19:30Z</time> <lat>54.96916</lat> <lon>-1.62515</lon> <ele>71.3</ele> </tp>
<tp> <time>2006-03-04T11:19:53Z</time> <lat>54.96921</lat> <lon>-1.625</lon> <ele>71.3</ele> </tp>
<tp> <time>2006-03-04T11:20:21Z</time> <lat>54.96801</lat> <lon>-1.62417</lon> <ele>71.8</ele> </tp>
<break/>
<title>ACTIVE LOG 127</title>
<tp> <time>2006-03-04T11:21:16Z</time> <lat>54.96887</lat> <lon>-1.62504</lon> <ele>70.8</ele> </tp>
<tp> <time>2006-03-04T11:21:18Z</time> <lat>54.96898</lat> <lon>-1.62476</lon> <ele>69.8</ele> </tp>
<tp> <time>2006-03-04T11:21:29Z</time> <lat>54.9691</lat> <lon>-1.62475</lon> <ele>69.4</ele> </tp>
<tp> <time>2006-03-04T11:21:46Z</time> <lat>54.96918</lat> <lon>-1.62468</lon> <ele>70.3</ele> </tp>
<tp> <time>2006-03-04T11:22:39Z</time> <lat>54.9692</lat> <lon>-1.62465</lon> <ele>69.4</ele> </tp>
<tp> <time>2006-03-04T11:22:43Z</time> <lat>54.96924</lat> <lon>-1.62462</lon> <ele>71.8</ele> </tp>
<tp> <time>2006-03-04T11:22:45Z</time> <lat>54.96928</lat> <lon>-1.62463</lon> <ele>71.8</ele> </tp>
<tp> <time>2006-03-04T11:23:00Z</time> <lat>54.96945</lat> <lon>-1.62466</lon> <ele>69.4</ele> </tp>
</track>
</gpsml>
END
    "",
    "Read Mapsource TAB-separated format",
);

# }}}
testcmd("../gpst two-digit_year.mcsv", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<break/>
<title>ACTIVE LOG 032</title>
<tp> <time>2006-03-20T20:35:33Z</time> <lat>60.41324</lat> <lon>5.33352</lon> <ele>14</ele> </tp>
<tp> <time>2006-03-20T20:35:38Z</time> <lat>60.38802</lat> <lon>5.33845</lon> <ele>18</ele> </tp>
<tp> <time>2006-03-20T20:35:44Z</time> <lat>60.38709</lat> <lon>5.3379</lon> <ele>19</ele> </tp>
<tp> <time>2006-03-20T20:35:49Z</time> <lat>60.38641</lat> <lon>5.33732</lon> <ele>18</ele> </tp>
<tp> <time>2006-03-20T20:35:54Z</time> <lat>60.38581</lat> <lon>5.33647</lon> <ele>18</ele> </tp>
<tp> <time>2006-03-20T20:36:00Z</time> <lat>60.38516</lat> <lon>5.33528</lon> <ele>15</ele> </tp>
<tp> <time>2006-03-20T20:36:02Z</time> <lat>60.38495</lat> <lon>5.3349</lon> <ele>13</ele> </tp>
</track>
</gpsml>
END
    "",
    "Read Mapsource TAB-separated format with two-digit year",
);

# }}}
testcmd("../gpst log.gpstxt", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<tp> <time>2003-06-13T14:36:09Z</time> <lat>59.521517</lat> <lon>7.391867</lon> <ele>762</ele> </tp>
<tp> <time>2003-06-13T14:36:10Z</time> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>
<tp> <time>2003-06-13T14:36:11Z</time> <lat>59.5213</lat> <lon>7.392417</lon> <ele>761</ele> </tp>
<tp> <time>2003-06-13T14:36:12Z</time> <lat>59.521183</lat> <lon>7.3927</lon> <ele>761</ele> </tp>
<etp err="nosignal"> <time>2003-06-13T14:36:13Z</time> </etp>
<tp> <time>2003-06-13T14:36:15Z</time> <lat>59.52085</lat> <lon>7.393517</lon> <ele>760</ele> </tp>
<tp> <time>2003-06-13T14:36:16Z</time> <lat>59.520733</lat> <lon>7.393783</lon> <ele>760</ele> </tp>
<tp> <time>2003-06-13T14:36:17Z</time> <lat>59.52065</lat> <lon>7.39405</lon> <ele>760</ele> </tp>
<tp> <time>2003-06-13T14:36:18Z</time> <lat>59.520583</lat> <lon>7.394333</lon> <ele>760</ele> </tp>
<tp> <time>2003-06-13T14:36:19Z</time> <lat>59.520533</lat> <lon>7.394633</lon> <ele>759</ele> </tp>
<tp> <time>2003-06-13T14:36:20Z</time> <lat>59.520483</lat> <lon>7.394917</lon> <ele>759</ele> </tp>
<tp> <time>2003-06-13T14:36:21Z</time> <lat>59.520433</lat> <lon>7.395233</lon> <ele>759</ele> </tp>
<etp err="nosignal"> <time>2003-06-13T14:36:22Z</time> </etp>
<tp> <time>2003-06-13T14:36:24Z</time> <lat>59.520283</lat> <lon>7.396233</lon> <ele>758</ele> </tp>
<tp> <time>2003-06-13T14:36:25Z</time> <lat>59.520233</lat> <lon>7.39655</lon> <ele>758</ele> </tp>
<tp> <time>2003-06-13T14:36:26Z</time> <lat>59.520183</lat> <lon>7.396883</lon> <ele>757</ele> </tp>
<tp> <time>2003-06-13T14:36:27Z</time> <lat>59.520133</lat> <lon>7.397217</lon> <ele>757</ele> </tp>
<tp> <time>2003-06-13T14:36:28Z</time> <lat>59.5201</lat> <lon>7.397567</lon> <ele>757</ele> </tp>
</track>
</gpsml>
END
    "",
    "Read Garmin serial text format",
);

# }}}
testcmd("../gpst log.dos.mayko", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<tp> <time>2003-06-15T10:27:45Z</time> <lat>58.1818158</lat> <lon>8.1225077</lon> </tp>
<tp> <time>2003-06-15T10:27:53Z</time> <lat>58.1818712</lat> <lon>8.12532</lon> </tp>
<tp> <time>2003-06-15T10:27:57Z</time> <lat>58.1816347</lat> <lon>8.1266031</lon> </tp>
<tp> <time>2003-06-15T10:28:03Z</time> <lat>58.1812099</lat> <lon>8.1284612</lon> </tp>
<tp> <time>2003-06-15T10:28:06Z</time> <lat>58.1810315</lat> <lon>8.129395</lon> </tp>
<tp> <time>2003-06-15T10:28:10Z</time> <lat>58.1809621</lat> <lon>8.13074</lon> </tp>
</track>
</gpsml>
END
    "",
    "Read DOS-formatted Mayko format",
);

# }}}
testcmd("../gpst log.dos.gpstxt", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<tp> <time>2003-01-05T16:47:11Z</time> <lat>66.908167</lat> <lon>15.022983</lon> <ele>11472</ele> </tp>
<tp> <time>2003-01-05T16:47:12Z</time> <lat>66.90625</lat> <lon>15.020667</lon> <ele>11472</ele> </tp>
<tp> <time>2003-01-05T16:47:13Z</time> <lat>66.904317</lat> <lon>15.01835</lon> <ele>11472</ele> </tp>
<tp> <time>2003-01-05T16:47:14Z</time> <lat>66.9024</lat> <lon>15.016017</lon> <ele>11473</ele> </tp>
<tp> <time>2003-01-05T16:47:15Z</time> <lat>66.900483</lat> <lon>15.0137</lon> <ele>11474</ele> </tp>
<tp> <time>2003-01-05T16:47:16Z</time> <lat>66.898567</lat> <lon>15.011383</lon> <ele>11474</ele> </tp>
<tp> <time>2003-01-05T16:47:17Z</time> <lat>66.896633</lat> <lon>15.009067</lon> <ele>11475</ele> </tp>
<tp> <time>2003-01-05T16:47:18Z</time> <lat>66.894717</lat> <lon>15.006733</lon> <ele>11475</ele> </tp>
<tp> <time>2003-01-05T16:47:19Z</time> <lat>66.8928</lat> <lon>15.004417</lon> <ele>11475</ele> </tp>
<tp> <time>2003-01-05T16:47:20Z</time> <lat>66.890867</lat> <lon>15.0021</lon> <ele>11475</ele> </tp>
<tp> <time>2003-01-05T16:47:21Z</time> <lat>66.88895</lat> <lon>14.999783</lon> <ele>11475</ele> </tp>
</track>
</gpsml>
END
    "",
    "Read DOS-formatted Garmin serial text format",
);

# }}}
testcmd("../gpst log.unix.mcsv", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<break/>
<title>ACTIVE LOG 058</title>
<tp> <time>2006-02-21T15:14:25Z</time> <lat>60.36662</lat> <lon>5.24885</lon> <ele>31.9</ele> </tp>
<tp> <time>2006-02-21T15:14:30Z</time> <lat>60.37057</lat> <lon>5.22956</lon> <ele>35.2</ele> </tp>
<tp> <time>2006-02-21T15:14:35Z</time> <lat>60.37019</lat> <lon>5.22817</lon> <ele>39.6</ele> </tp>
<tp> <time>2006-02-21T15:14:36Z</time> <lat>60.37012</lat> <lon>5.2279</lon> <ele>41</ele> </tp>
<tp> <time>2006-02-21T15:14:40Z</time> <lat>60.37009</lat> <lon>5.22682</lon> <ele>47.2</ele> </tp>
<tp> <time>2006-02-21T15:14:42Z</time> <lat>60.37011</lat> <lon>5.22641</lon> <ele>49.2</ele> </tp>
<tp> <time>2006-02-21T15:14:44Z</time> <lat>60.37011</lat> <lon>5.22607</lon> <ele>50.1</ele> </tp>
<tp> <time>2006-02-21T15:14:48Z</time> <lat>60.37002</lat> <lon>5.22568</lon> <ele>51.1</ele> </tp>
<tp> <time>2006-02-21T15:14:51Z</time> <lat>60.3701</lat> <lon>5.22548</lon> <ele>52.5</ele> </tp>
</track>
</gpsml>
END
    "",
    "Read UNIX-formatted Garmin Mapsource TAB-separated format",
);

# }}}
testcmd("../gpst multitrack.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Track 1</title>
<tp> <time>2003-02-11T23:35:39Z</time> <lat>51.4968266</lat> <lon>-0.1448824</lon> </tp>
<tp> <time>2003-02-11T23:35:49Z</time> <lat>51.4968227</lat> <lon>-0.1449938</lon> </tp>
<tp> <time>2003-02-11T23:36:14Z</time> <lat>51.496904</lat> <lon>-0.1453202</lon> </tp>
<break/>
<title>Track 2</title>
<tp> <time>2003-02-11T23:36:16Z</time> <lat>51.4969214</lat> <lon>-0.1453398</lon> </tp>
<tp> <time>2003-02-11T23:36:31Z</time> <lat>51.4969816</lat> <lon>-0.1455514</lon> </tp>
<tp> <time>2003-02-11T23:36:43Z</time> <lat>51.4970224</lat> <lon>-0.1457489</lon> <ele>1000</ele> </tp>
<tp> <time>2003-02-11T23:36:50Z</time> <lat>51.4970452</lat> <lon>-0.1457804</lon> </tp>
<break/>
<title>Track 3</title>
<tp> <time>2003-02-11T23:37:05Z</time> <lat>51.497068</lat> <lon>-0.1458608</lon> </tp>
<tp> <time>2003-02-11T23:37:22Z</time> <lat>51.4971658</lat> <lon>-0.1460047</lon> </tp>
<tp> <time>2003-02-11T23:37:36Z</time> <lat>51.4972469</lat> <lon>-0.1461614</lon> </tp>
<break/>
<title>Track 4</title>
<tp> <time>2003-02-11T23:37:43Z</time> <lat>51.4972731</lat> <lon>-0.1462394</lon> </tp>
<tp> <time>2003-02-11T23:38:04Z</time> <lat>51.4973437</lat> <lon>-0.1463232</lon> </tp>
<tp> <time>2003-02-11T23:38:28Z</time> <lat>51.4973337</lat> <lon>-0.1462949</lon> </tp>
<tp> <time>2003-02-11T23:38:34Z</time> <lat>51.4973218</lat> <lon>-0.1462825</lon> </tp>
<tp> <time>2003-02-11T23:38:35Z</time> <lat>51.4973145</lat> <lon>-0.1462732</lon> </tp>
</track>
</gpsml>
END
    "",
    "Read GPX file with multiple tracks",
);

# }}}
testcmd("../gpst compact.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>All whitespace stripped</title>
<tp> <time>2002-12-30T15:22:04Z</time> <lat>70.660932</lat> <lon>23.7028354</lon> </tp>
<tp> <time>2002-12-30T15:22:06Z</time> <lat>70.6609392</lat> <lon>23.7028468</lon> </tp>
<tp> <time>2002-12-30T15:22:08Z</time> <lat>70.6609429</lat> <lon>23.7028499</lon> </tp>
<tp> <time>2002-12-30T15:22:11Z</time> <lat>70.6609381</lat> <lon>23.702862</lon> </tp>
<tp> <time>2002-12-30T15:22:12Z</time> <lat>70.6609368</lat> <lon>23.7028648</lon> </tp>
<tp> <time>2002-12-30T15:22:13Z</time> <lat>70.6609344</lat> <lon>23.7028652</lon> </tp>
<tp> <time>2002-12-30T15:22:15Z</time> <lat>70.6609349</lat> <lon>23.7028707</lon> </tp>
<tp> <time>2002-12-30T15:22:17Z</time> <lat>70.6609348</lat> <lon>23.7028654</lon> </tp>
<tp> <time>2002-12-30T15:22:19Z</time> <lat>70.6609347</lat> <lon>23.7028599</lon> </tp>
<tp> <time>2002-12-30T15:22:20Z</time> <lat>70.6609348</lat> <lon>23.7028609</lon> </tp>
<tp> <time>2002-12-30T15:22:23Z</time> <lat>70.6609388</lat> <lon>23.7028653</lon> </tp>
<tp> <time>2002-12-30T15:22:25Z</time> <lat>70.6609426</lat> <lon>23.7028732</lon> </tp>
</track>
</gpsml>
END
    "",
    "Read GPX one-liner",
);

# }}}
testcmd("../gpst missing.gpsml", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Missing various elements</title>
<tp> <time>2006-04-30T17:16:59Z</time> </tp>
<tp> <time>2006-04-30T17:17:00Z</time> </tp>
<tp> <time>2006-04-30T17:17:09Z</time> <lat>60.42353</lat> <lon>5.34185</lon> </tp>
<tp> <time>2006-04-30T17:17:11Z</time> <ele>483</ele> </tp>
<tp> <time>2006-04-30T17:17:22Z</time> <ele>485</ele> </tp>
<tp> <lat>60.42347</lat> <lon>5.34212</lon> <ele>486</ele> </tp>
<tp> <ele>484</ele> </tp>
<tp> <ele>486</ele> </tp>
<tp> <desc>Missing everything</desc> </tp>
<tp> <time>2006-04-30T17:18:03Z</time> <ele>490</ele> </tp>
<tp> <time>2006-04-30T17:18:05Z</time> <lat>60.42338</lat> <lon>5.34269</lon> <ele>487</ele> </tp>
</track>
</gpsml>
END
    "",
    "Read gpsml with various data missing",
);

# }}}
testcmd("../gpst different_dateformats.gpsml", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Date format variations</title>
<tp> <time>2006-01-01T00:00:01Z</time> <lat>1</lat> <lon>1</lon> </tp>
<tp> <time>2006-01-01T00:00:02Z</time> <lat>2</lat> <lon>2</lon> </tp>
<tp> <time>2006-01-01T00:00:03Z</time> <lat>3</lat> <lon>3</lon> </tp>
<tp> <time>2006-01-01T00:00:04Z</time> <lat>4</lat> <lon>4</lon> </tp>
</track>
</gpsml>
END
    "",
    "Read different date formats from gpsml file",
);

# }}}
testcmd("../gpst multitrack-pause.gpx", # {{{
    file_data("multitrack-pause.gpsml"),
    "",
    "Should be equal to multitrack-pause.gpsml",
);

# }}}
# gpx
testcmd("../gpst -o gpx no_signal.mayko", # {{{
    <<END,
$gpx_header
  <trk>
    <trkseg>
      <trkpt lat="70.6800486" lon="23.6746151"> <time>2002-12-22T21:42:24Z</time> </trkpt>
      <trkpt lat="70.6799322" lon="23.6740038"> <time>2002-12-22T21:42:32Z</time> </trkpt>
      <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:42:54Z</time> </trkpt>
      <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:43:51Z</time> </trkpt>
      <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:43:52Z</time> </trkpt>
      <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:43:54Z</time> </trkpt>
      <trkpt lat="70.6800774" lon="23.6757566"> <time>2002-12-22T21:44:45Z</time> </trkpt>
      <trkpt lat="70.6801502" lon="23.6753442"> <time>2002-12-22T21:44:52Z</time> </trkpt>
      <trkpt lat="70.6801905" lon="23.6757542"> <time>2002-12-22T21:45:04Z</time> </trkpt>
    </trkseg>
  </trk>
</gpx>
END
    "",
    "Output GPX from Mayko file with duplicates",
);

# }}}
testcmd("../gpst -o gpx comments.mayko", # {{{
    <<END,
$gpx_header
  <trk>
    <trkseg>
      <trkpt lat="70.6800486" lon="23.6746151"> <time>2002-12-22T21:42:24Z</time> </trkpt>
      <trkpt lat="70.6799322" lon="23.6740038"> <time>2002-12-22T21:42:32Z</time> </trkpt>
      <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:42:54Z</time> </trkpt>
      <!-- <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:43:51Z</time> <extensions> <error>desc</error> </extensions> </trkpt> -->
      <!-- <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:43:52Z</time> <extensions> <error>desc</error> </extensions> </trkpt> -->
      <!-- <trkpt lat="70.6796266" lon="23.6723991"> <time>2002-12-22T21:43:54Z</time> <extensions> <error>desc</error> </extensions> </trkpt> -->
      <trkpt lat="70.6800774" lon="23.6757566"> <time>2002-12-22T21:44:45Z</time> </trkpt>
    </trkseg>
    <trkseg>
      <trkpt lat="70.6801502" lon="23.6753442"> <time>2002-12-22T21:44:52Z</time> </trkpt>
      <trkpt lat="70.6801905" lon="23.6757542"> <time>2002-12-22T21:45:04Z</time> </trkpt>
    </trkseg>
  </trk>
</gpx>
END
    "",
    "Output GPX from Mayko file with commented-out lines",
);

# }}}
testcmd("../gpst -o gpx missing.gpsml", # {{{
    <<END,
$gpx_header
  <trk>
    <trkseg>
      <trkpt lat="60.42353" lon="5.34185"> <time>2006-04-30T17:17:09Z</time> </trkpt>
      <trkpt> <ele>483</ele> <time>2006-04-30T17:17:11Z</time> </trkpt>
      <trkpt> <ele>485</ele> <time>2006-04-30T17:17:22Z</time> </trkpt>
      <trkpt lat="60.42347" lon="5.34212"> <ele>486</ele> </trkpt>
      <trkpt> <ele>484</ele> </trkpt>
      <trkpt> <ele>486</ele> </trkpt>
      <trkpt> <ele>490</ele> <time>2006-04-30T17:18:03Z</time> </trkpt>
      <trkpt lat="60.42338" lon="5.34269"> <ele>487</ele> <time>2006-04-30T17:18:05Z</time> </trkpt>
    </trkseg>
  </trk>
</gpx>
END
    "",
    "Output GPX from gpsml with missing data",
);

# }}}
# xgraph
testcmd("../gpst -o xgraph multitrack.gpx", # {{{
    <<END,
-0.1448824 51.4968266
-0.1449938 51.4968227
-0.1453202 51.4969040
move -0.1453398 51.4969214
-0.1455514 51.4969816
-0.1457489 51.4970224
-0.1457804 51.4970452
move -0.1458608 51.4970680
-0.1460047 51.4971658
-0.1461614 51.4972469
move -0.1462394 51.4972731
-0.1463232 51.4973437
-0.1462949 51.4973337
-0.1462825 51.4973218
-0.1462732 51.4973145
END
    "",
    "Output xgraph format from GPX",
);

# }}}
# pgtab
testcmd("../gpst -o pgtab compact.gpx", # {{{
    <<END,
2002-12-30T15:22:04Z\t(70.6609320,23.7028354)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:06Z\t(70.6609392,23.7028468)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:08Z\t(70.6609429,23.7028499)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:11Z\t(70.6609381,23.7028620)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:12Z\t(70.6609368,23.7028648)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:13Z\t(70.6609344,23.7028652)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:15Z\t(70.6609349,23.7028707)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:17Z\t(70.6609348,23.7028654)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:19Z\t(70.6609347,23.7028599)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:20Z\t(70.6609348,23.7028609)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:23Z\t(70.6609388,23.7028653)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-30T15:22:25Z\t(70.6609426,23.7028732)\t\\N\t\\N\t\\N\t\\N\t\\N
END
    "",
    "Output pgtab from gpx format",
);

# }}}
testcmd("../gpst -o pgtab no_signal.mayko", # {{{
    <<END,
2002-12-22T21:42:24Z\t(70.6800486,23.6746151)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:42:32Z\t(70.6799322,23.6740038)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:42:54Z\t(70.6796266,23.6723991)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:43:51Z\t(70.6796266,23.6723991)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:43:52Z\t(70.6796266,23.6723991)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:43:54Z\t(70.6796266,23.6723991)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:44:45Z\t(70.6800774,23.6757566)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:44:52Z\t(70.6801502,23.6753442)\t\\N\t\\N\t\\N\t\\N\t\\N
2002-12-22T21:45:04Z\t(70.6801905,23.6757542)\t\\N\t\\N\t\\N\t\\N\t\\N
END
    "",
    "Output pgtab from mayko format",
);

# }}}
testcmd("../gpst -o pgtab missing.gpsml", # {{{
    <<END,
2006-04-30T17:17:09Z\t(60.42353,5.34185)\t\\N\t\\N\t\\N\t\\N\t\\N
\\N\t(60.42347,5.34212)\t486\t\\N\t\\N\t\\N\t\\N
2006-04-30T17:18:05Z\t(60.42338,5.34269)\t487\t\\N\t\\N\t\\N\t\\N
END
    "",
    "Output pgtab from missing.gpsml",
);

# }}}
# csv
testcmd("../gpst -o csv log.dos.mayko", # {{{
    <<END,
2003-06-15T10:27:45Z\t8.1225077\t58.1818158\t\t
2003-06-15T10:27:53Z\t8.1253200\t58.1818712\t\t
2003-06-15T10:27:57Z\t8.1266031\t58.1816347\t\t
2003-06-15T10:28:03Z\t8.1284612\t58.1812099\t\t
2003-06-15T10:28:06Z\t8.1293950\t58.1810315\t\t
2003-06-15T10:28:10Z\t8.1307400\t58.1809621\t\t
END
    "",
    "Output csv from DOS-formatted Mayko format",
);

# }}}
# pgwtab
testcmd("../gpst -o pgwtab multitrack.gpx", # {{{
    <<END,
(51.477880000,-0.001470000)\t0-Meridian\t\\N\t\\N\t\\N\t11-FEB-03 15:46\t11-FEB-03 15:46\t\\N\t\\N
(51.532030,-0.177330)\tAbbey Road\t34.492798\t\\N\t\\N\tDet hellige gangfeltet der Beatles valsa over.\t26-FEB-06 17:29:46\t\\N\t\\N
(61.636684,8.312254)\tGaldhøpiggen med ', &, < og >. ☺\t2469.012939\tmountain\t2006-05-08T18:27:59Z\tHer er det &, < og >. ☺\tSchwæra greie\thttp://www.example.org/\tWaypoint
(60.397460000,5.350610000)\tHalfdan Griegs vei\t\\N\t\\N\t\\N\t04-AUG-02 19:42\t04-AUG-02 19:42\t\\N\t\\N
(51.510130000,-0.130410000)\tLeicester Square\t\\N\t\\N\t\\N\t11-FEB-03 18:00\t11-FEB-03 18:00\t\\N\t\\N
(60.968540000,9.285350000)\tLeira camping\t\\N\t\\N\t\\N\t03-OKT-02 21:58\t03-OKT-02 21:58\t\\N\t\\N
END
    "",
    "Test pgwtab format",
);

# }}}
# pgwupd
testcmd("../gpst -o pgwupd multitrack.gpx", # {{{
    <<END,
BEGIN;
    UPDATE logg SET sted = clname(coor) WHERE (point(51.477880000,-0.001470000) <-> coor) < 0.05;
    UPDATE logg SET dist = cldist(coor) WHERE (point(51.477880000,-0.001470000) <-> coor) < 0.05;
COMMIT;
BEGIN;
    UPDATE logg SET sted = clname(coor) WHERE (point(51.532030,-0.177330) <-> coor) < 0.05;
    UPDATE logg SET dist = cldist(coor) WHERE (point(51.532030,-0.177330) <-> coor) < 0.05;
COMMIT;
BEGIN;
    UPDATE logg SET sted = clname(coor) WHERE (point(61.636684,8.312254) <-> coor) < 0.05;
    UPDATE logg SET dist = cldist(coor) WHERE (point(61.636684,8.312254) <-> coor) < 0.05;
COMMIT;
BEGIN;
    UPDATE logg SET sted = clname(coor) WHERE (point(60.397460000,5.350610000) <-> coor) < 0.05;
    UPDATE logg SET dist = cldist(coor) WHERE (point(60.397460000,5.350610000) <-> coor) < 0.05;
COMMIT;
BEGIN;
    UPDATE logg SET sted = clname(coor) WHERE (point(51.510130000,-0.130410000) <-> coor) < 0.05;
    UPDATE logg SET dist = cldist(coor) WHERE (point(51.510130000,-0.130410000) <-> coor) < 0.05;
COMMIT;
BEGIN;
    UPDATE logg SET sted = clname(coor) WHERE (point(60.968540000,9.285350000) <-> coor) < 0.05;
    UPDATE logg SET dist = cldist(coor) WHERE (point(60.968540000,9.285350000) <-> coor) < 0.05;
COMMIT;
END
    "",
    "Test pgwupd format",
);

# }}}
# clean
testcmd("../gpst -t -o clean pause.gpx", # {{{
    <<END,
5.299534\t60.425494\t25.260
5.299610\t60.425464\t24.931

5.299694\t60.425314\t27.975

5.299741\t60.425384\t31.017
5.299958\t60.425339\t30.980
5.299640\t60.425238\t30.538
5.299686\t60.425246\t30.515

5.299773\t60.425345\t31.936
5.299419\t60.425457\t31.794
END
    "",
    "Output clean format with time breaks",
);
# }}}
# gpstrans
# poscount
# ps (Unfinished)
# svg (Unfinished)
# ygraph
# --output option }}}
diag("Testing --outside option..."); # {{{
testcmd("../gpst --pos1 2.11,2.12 --pos2 3.31,3.32 --outside multitrack-pause.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>track1</title>
<tp> <time>2006-01-01T00:00:00Z</time> <lat>1.11</lat> <lon>1.12</lon> </tp>
<tp> <time>2006-01-01T00:00:01Z</time> <lat>1.21</lat> <lon>1.22</lon> </tp>
<tp> <time>2006-01-01T00:00:02Z</time> <lat>1.31</lat> <lon>1.32</lon> </tp>
<break/>
<title>track2</title>
<break/>
<title>track3</title>
<break/>
<tp> <time>2006-01-03T02:00:23Z</time> <lat>3.41</lat> <lon>3.42</lon> </tp>
<tp> <time>2006-01-03T02:00:24Z</time> <lat>3.51</lat> <lon>3.52</lon> </tp>
<tp> <time>2006-01-03T02:00:25Z</time> <lat>3.61</lat> <lon>3.62</lon> </tp>
<tp> <time>2006-01-03T02:00:26Z</time> <lat>3.71</lat> <lon>3.72</lon> </tp>
<tp> <time>2006-01-03T02:00:27Z</time> <lat>3.81</lat> <lon>3.82</lon> </tp>
</track>
</gpsml>
END
    "",
    "Check --outside option (gpx to gpst)",
);

# }}}
# --outside option }}}
diag("Testing --pos1 and --pos2 options..."); # {{{
# --pos1 and --pos2 options }}}
diag("Testing --require option..."); # {{{
testcmd("../gpst -re multitrack.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Track 1</title>
<break/>
<title>Track 2</title>
<tp> <time>2003-02-11T23:36:43Z</time> <lat>51.4970224</lat> <lon>-0.1457489</lon> <ele>1000</ele> </tp>
<break/>
<title>Track 3</title>
<break/>
<title>Track 4</title>
</track>
</gpsml>
END
    "",
    "Require elevation from GPX data",
);
# }}}
testcmd("../gpst tracks.gpsman", # {{{
    <<END,
END
    "",
    "Output gpsml format from gpsman",
);

# }}}
testcmd("../gpst -o gpx -R lat=7,lon=7,ele=2 tracks.gpsman", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx
  version="1.1"
  creator="gpst - http://svn.sunbase.org/repos/utils/trunk/src/gpstools/"
  xmlns="http://www.topografix.com/GPX/1/1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
>
  <trk>
    <title>ACTIVE LOG</title>
    <trkseg>
      <trkpt lat="60.2891111" lon="5.2276111"> <ele>54.45</ele> <time>2003-12-01T04:21:09Z</time> </trkpt>
      <trkpt lat="60.2885833" lon="5.2261667"> <ele>54.45</ele> <time>2003-12-01T04:21:26Z</time> </trkpt>
    </trkseg>
    <trkseg>
      <trkpt lat="52.1221667" lon="14.0295278"> <ele>1494.99</ele> <time>2003-12-01T09:27:21Z</time> </trkpt>
    </trkseg>
    <trkseg>
      <trkpt lat="52.0858889" lon="14.0401389"> <ele>1494.99</ele> <time>2003-12-01T09:27:42Z</time> </trkpt>
      <trkpt lat="52.0842778" lon="14.0406667"> <ele>1494.03</ele> <time>2003-12-01T09:27:43Z</time> </trkpt>
    </trkseg>
    <trkseg>
      <trkpt lat="50.0858333" lon="14.4290833"> <ele>183.27</ele> <time>2003-12-01T21:26:07Z</time> </trkpt>
      <trkpt lat="50.0859722" lon="14.4291111"> <ele>184.71</ele> <time>2003-12-01T21:26:31Z</time> </trkpt>
    </trkseg>
    <trkseg>
      <trkpt lat="50.092" lon="14.43625"> <ele>180.38</ele> <time>2003-12-01T21:47:30Z</time> </trkpt>
      <trkpt lat="50.092" lon="14.43625"> <ele>181.35</ele> <time>2003-12-01T21:47:47Z</time> </trkpt>
      <trkpt lat="50.092" lon="14.4362222"> <ele>182.31</ele> <time>2003-12-01T21:47:53Z</time> </trkpt>
    </trkseg>
  </trk>
</gpx>
END
    "",
    "Output GPX format from gpsman",
);
# }}}
testcmd("../gpst -re one_ele.dos.gpsml", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Only one point has elevation</title>
<tp> <time>2006-05-21T16:52:04Z</time> <lat>60.425314</lat> <lon>5.299694</lon> <ele>27.975</ele> </tp>
</track>
</gpsml>
END
    "",
    "Require elevation from gpsml",
);

# }}}

TODO: {
    local $TODO = "Shall lat/lon be cleared if one is missing?";
    testcmd("../gpst -re missing.gpsml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Missing various elements</title>
<tp> <time>2006-04-30T17:17:11Z</time> <ele>483</ele> </tp>
<tp> <time>2006-04-30T17:17:22Z</time> <ele>485</ele> </tp>
<tp> <lat>60.42347</lat> <lon>5.34212</lon> <ele>486</ele> </tp>
<tp> <ele>484</ele> </tp>
<tp> <ele>486</ele> </tp>
<tp> <time>2006-04-30T17:18:03Z</time> <ele>490</ele> </tp>
<tp> <time>2006-04-30T17:18:05Z</time> <lat>60.42338</lat> <lon>5.34269</lon> <ele>487</ele> </tp>
</track>
</gpsml>
END
        "",
        "Require elevation",
    );

    # }}}
    testcmd("../gpst -rt missing.gpsml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Missing various elements</title>
<tp> <time>2006-04-30T17:16:59Z</time> </tp>
<tp> <time>2006-04-30T17:17:00Z</time> </tp>
<tp> <time>2006-04-30T17:17:09Z</time> <lat>60.42353</lat> <lon>5.34185</lon> </tp>
<tp> <time>2006-04-30T17:17:11Z</time> <ele>483</ele> </tp>
<tp> <time>2006-04-30T17:17:22Z</time> <ele>485</ele> </tp>
<tp> <time>2006-04-30T17:18:03Z</time> <ele>490</ele> </tp>
<tp> <time>2006-04-30T17:18:05Z</time> <lat>60.42338</lat> <lon>5.34269</lon> <ele>487</ele> </tp>
</track>
</gpsml>
END
        "",
        "Require time",
    );

    # }}}
    testcmd("../gpst -rp missing.gpsml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Missing various elements</title>
<tp> <time>2006-04-30T17:17:09Z</time> <lat>60.42353</lat> <lon>5.34185</lon> </tp>
<tp> <lat>60.42347</lat> <lon>5.34212</lon> <ele>486</ele> </tp>
<tp> <time>2006-04-30T17:18:05Z</time> <lat>60.42338</lat> <lon>5.34269</lon> <ele>487</ele> </tp>
</track>
</gpsml>
END
        "",
        "Require position",
    );

    # }}}
    testcmd("../gpst -ret missing.gpsml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Missing various elements</title>
<tp> <time>2006-04-30T17:17:11Z</time> <ele>483</ele> </tp>
<tp> <time>2006-04-30T17:17:22Z</time> <ele>485</ele> </tp>
<tp> <time>2006-04-30T17:18:03Z</time> <ele>490</ele> </tp>
<tp> <time>2006-04-30T17:18:05Z</time> <lat>60.42338</lat> <lon>5.34269</lon> <ele>487</ele> </tp>
</track>
</gpsml>
END
        "",
        "Require elevation and time",
    );

    # }}}
    testcmd("../gpst -retp missing.gpsml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Missing various elements</title>
<tp> <time>2006-04-30T17:18:05Z</time> <lat>60.42338</lat> <lon>5.34269</lon> <ele>487</ele> </tp>
</track>
</gpsml>
END
        "",
        "Require elevation, time and position",
    );

    # }}}
    testcmd("../gpst -rep missing.gpsml", # {{{
        <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Missing various elements</title>
<tp> <lat>60.42347</lat> <lon>5.34212</lon> <ele>486</ele> </tp>
<tp> <time>2006-04-30T17:18:05Z</time> <lat>60.42338</lat> <lon>5.34269</lon> <ele>487</ele> </tp>
</track>
</gpsml>
END
        "",
        "Require elevation and position",
    );

    # }}}
}
# --require option }}}
diag("Testing --round option..."); # {{{
testcmd("../gpst -R lat=4,lon=5,ele=1 pause.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>ACTIVE LOG164705</title>
<tp> <time>2006-05-21T16:49:11Z</time> <lat>60.4255</lat> <lon>5.29953</lon> <ele>25.3</ele> </tp>
<tp> <time>2006-05-21T16:49:46Z</time> <lat>60.4255</lat> <lon>5.29961</lon> <ele>24.9</ele> </tp>
<tp> <time>2006-05-21T16:52:04Z</time> <lat>60.4253</lat> <lon>5.29969</lon> <ele>28</ele> </tp>
<tp> <time>2006-05-21T16:56:36Z</time> <lat>60.4254</lat> <lon>5.29974</lon> <ele>31</ele> </tp>
<tp> <time>2006-05-21T16:56:47Z</time> <lat>60.4253</lat> <lon>5.29996</lon> <ele>31</ele> </tp>
<tp> <time>2006-05-21T16:56:56Z</time> <lat>60.4252</lat> <lon>5.29964</lon> <ele>30.5</ele> </tp>
<tp> <time>2006-05-21T16:57:03Z</time> <lat>60.4252</lat> <lon>5.29969</lon> <ele>30.5</ele> </tp>
<tp> <time>2006-05-21T16:59:08Z</time> <lat>60.4253</lat> <lon>5.29977</lon> <ele>31.9</ele> </tp>
<tp> <time>2006-05-21T17:00:54Z</time> <lat>60.4255</lat> <lon>5.29942</lon> <ele>31.8</ele> </tp>
</track>
</gpsml>
END
    "",
    "--round works with lat, lon, ele from gpx",
);

# }}}
# --round option }}}
diag("Testing --short-date option..."); # {{{
# --short-date option }}}
diag("Testing --save-to-file option..."); # {{{
# --save-to-file option }}}
diag("Testing --create-breaks option..."); # {{{
testcmd("../gpst -t pause.gpx", # {{{
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
    "",
    "Output gpsml with <pause> elements from GPX files",
);

# }}}
testcmd("../gpst -t multitrack-pause.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>track1</title>
<tp> <time>2006-01-01T00:00:00Z</time> <lat>1.11</lat> <lon>1.12</lon> </tp>
<tp> <time>2006-01-01T00:00:01Z</time> <lat>1.21</lat> <lon>1.22</lon> </tp>
<tp> <time>2006-01-01T00:00:02Z</time> <lat>1.31</lat> <lon>1.32</lon> </tp>
<break/>
<title>track2</title>
<pause>0:23:59:58</pause>
<tp> <time>2006-01-02T00:00:00Z</time> <lat>2.11</lat> <lon>2.12</lon> </tp>
<tp> <time>2006-01-02T00:00:04Z</time> <lat>2.21</lat> <lon>2.22</lon> </tp>
<tp> <time>2006-01-02T00:00:16Z</time> <lat>2.31</lat> <lon>2.32</lon> </tp>
<pause>0:01:00:00</pause>
<tp> <time>2006-01-02T01:00:16Z</time> <lat>2.41</lat> <lon>2.42</lon> </tp>
<break/>
<tp> <time>2006-01-02T01:00:17Z</time> <lat>2.451</lat> <lon>2.452</lon> </tp>
<break/>
<title>track3</title>
<pause>1:01:00:03</pause>
<tp> <time>2006-01-03T02:00:20Z</time> <lat>3.11</lat> <lon>3.12</lon> </tp>
<tp> <time>2006-01-03T02:00:21Z</time> <lat>3.21</lat> <lon>3.22</lon> </tp>
<tp> <time>2006-01-03T02:00:22Z</time> <lat>3.31</lat> <lon>3.32</lon> </tp>
<break/>
<tp> <time>2006-01-03T02:00:23Z</time> <lat>3.41</lat> <lon>3.42</lon> </tp>
<tp> <time>2006-01-03T02:00:24Z</time> <lat>3.51</lat> <lon>3.52</lon> </tp>
<tp> <time>2006-01-03T02:00:25Z</time> <lat>3.61</lat> <lon>3.62</lon> </tp>
<tp> <time>2006-01-03T02:00:26Z</time> <lat>3.71</lat> <lon>3.72</lon> </tp>
<tp> <time>2006-01-03T02:00:27Z</time> <lat>3.81</lat> <lon>3.82</lon> </tp>
</track>
</gpsml>
END
    "",
    "Insert <pause> between gpx tracks",
);

# }}}
testcmd("../gpst -t multitrack-pause.gpsml", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>track1</title>
<tp> <time>2006-01-01T00:00:00Z</time> <lat>1.11</lat> <lon>1.12</lon> </tp>
<tp> <time>2006-01-01T00:00:01Z</time> <lat>1.21</lat> <lon>1.22</lon> </tp>
<tp> <time>2006-01-01T00:00:02Z</time> <lat>1.31</lat> <lon>1.32</lon> </tp>
<break/>
<title>track2</title>
<pause>0:23:59:58</pause>
<tp> <time>2006-01-02T00:00:00Z</time> <lat>2.11</lat> <lon>2.12</lon> </tp>
<tp> <time>2006-01-02T00:00:04Z</time> <lat>2.21</lat> <lon>2.22</lon> </tp>
<tp> <time>2006-01-02T00:00:16Z</time> <lat>2.31</lat> <lon>2.32</lon> </tp>
<pause>0:01:00:00</pause>
<tp> <time>2006-01-02T01:00:16Z</time> <lat>2.41</lat> <lon>2.42</lon> </tp>
<break/>
<tp> <time>2006-01-02T01:00:17Z</time> <lat>2.451</lat> <lon>2.452</lon> </tp>
<break/>
<title>track3</title>
<pause>1:01:00:03</pause>
<tp> <time>2006-01-03T02:00:20Z</time> <lat>3.11</lat> <lon>3.12</lon> </tp>
<tp> <time>2006-01-03T02:00:21Z</time> <lat>3.21</lat> <lon>3.22</lon> </tp>
<tp> <time>2006-01-03T02:00:22Z</time> <lat>3.31</lat> <lon>3.32</lon> </tp>
<break/>
<tp> <time>2006-01-03T02:00:23Z</time> <lat>3.41</lat> <lon>3.42</lon> </tp>
<tp> <time>2006-01-03T02:00:24Z</time> <lat>3.51</lat> <lon>3.52</lon> </tp>
<tp> <time>2006-01-03T02:00:25Z</time> <lat>3.61</lat> <lon>3.62</lon> </tp>
<tp> <time>2006-01-03T02:00:26Z</time> <lat>3.71</lat> <lon>3.72</lon> </tp>
<tp> <time>2006-01-03T02:00:27Z</time> <lat>3.81</lat> <lon>3.82</lon> </tp>
</track>
</gpsml>
END
    "",
    "Insert <pause> between gpsml titles",
);

# }}}
# --create-breaks option }}}
diag("Testing --comment-out-dups option..."); # {{{
testcmd("../gpst -u no_signal.mayko >nosignal.tmp", # {{{
    "",
    "",
    "Redirect stdout",
);

# }}}
testcmd("../gpst nosignal.tmp", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<tp> <time>2002-12-22T21:42:24Z</time> <lat>70.6800486</lat> <lon>23.6746151</lon> </tp>
<tp> <time>2002-12-22T21:42:32Z</time> <lat>70.6799322</lat> <lon>23.6740038</lon> </tp>
<tp> <time>2002-12-22T21:42:54Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </tp>
<desc>20021222T214351-20021222T214354: CO: No signal \x7B\x7B\x7B</desc>
<etp err="desc"> <time>2002-12-22T21:43:51Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<etp err="desc"> <time>2002-12-22T21:43:52Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<etp err="desc"> <time>2002-12-22T21:43:54Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<desc>20021222T214351-20021222T214354: CO: No signal \x7D\x7D\x7D</desc>
<break/>
<tp> <time>2002-12-22T21:44:45Z</time> <lat>70.6800774</lat> <lon>23.6757566</lon> </tp>
<tp> <time>2002-12-22T21:44:52Z</time> <lat>70.6801502</lat> <lon>23.6753442</lon> </tp>
<tp> <time>2002-12-22T21:45:04Z</time> <lat>70.6801905</lat> <lon>23.6757542</lon> </tp>
</track>
</gpsml>
END
    "",
    "Read output from 'gpst -u *.mayko'",
);

# }}}
unlink("nosignal.tmp") || warn("nosignal.tmp: Cannot delete file: $!\n");
testcmd("../gpst -u no_signal.mayko", # {{{
    <<END,
xmaplog 1.0 Mon Dec 23 02:00:50 2002
1 70.6800486 23.6746151 57.4 0 12/22/2002 21:42:24
1 70.6799322 23.6740038 6.3 0 12/22/2002 21:42:32
1 70.6796266 23.6723991 6.0 0 12/22/2002 21:42:54
# 20021222T214351-20021222T214354: CO: No signal \x7B\x7B\x7B
# 1 70.6796266 23.6723991 0.0 0 12/22/2002 21:43:51
# 1 70.6796266 23.6723991 0.0 0 12/22/2002 21:43:52
# 1 70.6796266 23.6723991 0.0 0 12/22/2002 21:43:54
# 20021222T214351-20021222T214354: CO: No signal \x7D\x7D\x7D
# move
1 70.6800774 23.6757566 5.1 0 12/22/2002 21:44:45
1 70.6801502 23.6753442 4.8 0 12/22/2002 21:44:52
1 70.6801905 23.6757542 2.5 0 12/22/2002 21:45:04
END
    "",
    "Read Mayko format with no signal, output old Mayko format",
);

# }}}
# --comment-out-dups option }}}
diag("Testing --verbose option..."); # {{{
# --verbose option }}}
diag("Testing --version option..."); # {{{
like(`../gpst --version`, # {{{
    qr/^(\$Id: .*? \$\n)+$/s,
    '"../gpst --version" - The --version option outputs Id strings',
);

# }}}
# --version option }}}
diag("Testing --strip-whitespace option..."); # {{{
testcmd("../gpst -w -o gpx pause.gpx", # {{{
    <<END,
$stripped_gpx_header
<trk>
<trkseg>
<trkpt lat="60.425494" lon="5.299534"><ele>25.260</ele><time>2006-05-21T16:49:11Z</time></trkpt>
<trkpt lat="60.425464" lon="5.299610"><ele>24.931</ele><time>2006-05-21T16:49:46Z</time></trkpt>
<trkpt lat="60.425314" lon="5.299694"><ele>27.975</ele><time>2006-05-21T16:52:04Z</time></trkpt>
<trkpt lat="60.425384" lon="5.299741"><ele>31.017</ele><time>2006-05-21T16:56:36Z</time></trkpt>
<trkpt lat="60.425339" lon="5.299958"><ele>30.980</ele><time>2006-05-21T16:56:47Z</time></trkpt>
<trkpt lat="60.425238" lon="5.299640"><ele>30.538</ele><time>2006-05-21T16:56:56Z</time></trkpt>
<trkpt lat="60.425246" lon="5.299686"><ele>30.515</ele><time>2006-05-21T16:57:03Z</time></trkpt>
<trkpt lat="60.425345" lon="5.299773"><ele>31.936</ele><time>2006-05-21T16:59:08Z</time></trkpt>
<trkpt lat="60.425457" lon="5.299419"><ele>31.794</ele><time>2006-05-21T17:00:54Z</time></trkpt>
</trkseg>
</trk>
</gpx>
END
    "",
    "Strip whitespace from GPX output",
);

    # }}}
testcmd("../gpst -o gpx -w comments.mayko", # {{{
    <<END,
$stripped_gpx_header
<trk>
<trkseg>
<trkpt lat="70.6800486" lon="23.6746151"><time>2002-12-22T21:42:24Z</time></trkpt>
<trkpt lat="70.6799322" lon="23.6740038"><time>2002-12-22T21:42:32Z</time></trkpt>
<trkpt lat="70.6796266" lon="23.6723991"><time>2002-12-22T21:42:54Z</time></trkpt>
<!-- <trkpt lat="70.6796266" lon="23.6723991"><time>2002-12-22T21:43:51Z</time><extensions><error>desc</error></extensions></trkpt> -->
<!-- <trkpt lat="70.6796266" lon="23.6723991"><time>2002-12-22T21:43:52Z</time><extensions><error>desc</error></extensions></trkpt> -->
<!-- <trkpt lat="70.6796266" lon="23.6723991"><time>2002-12-22T21:43:54Z</time><extensions><error>desc</error></extensions></trkpt> -->
<trkpt lat="70.6800774" lon="23.6757566"><time>2002-12-22T21:44:45Z</time></trkpt>
</trkseg>
<trkseg>
<trkpt lat="70.6801502" lon="23.6753442"><time>2002-12-22T21:44:52Z</time></trkpt>
<trkpt lat="70.6801905" lon="23.6757542"><time>2002-12-22T21:45:04Z</time></trkpt>
</trkseg>
</trk>
</gpx>
END
    "",
    "Output whitespace-stripped GPX from Mayko file with commented-out lines",
);

# }}}
# --strip-whitespace option }}}
diag("Testing --double-y-scale option..."); # {{{
testcmd("../gpst -y -o clean pause.gpx", # {{{
    <<END,
5.299534\t120.850988\t25.260
5.299610\t120.850928\t24.931
5.299694\t120.850628\t27.975
5.299741\t120.850768\t31.017
5.299958\t120.850678\t30.980
5.299640\t120.850476\t30.538
5.299686\t120.850492\t30.515
5.299773\t120.85069\t31.936
5.299419\t120.850914\t31.794
END
    "",
    "Double y scale, clean output from gpx format",
);

# }}}
testcmd("../gpst -y -o clean log.dos.mayko", # {{{
    <<END,
8.1225077\t116.3636316\t
8.1253200\t116.3637424\t
8.1266031\t116.3632694\t
8.1284612\t116.3624198\t
8.1293950\t116.362063\t
8.1307400\t116.3619242\t
END
    "",
    "Double y scale, clean output from mayko format",
);

# }}}
# --double-y-scale option }}}
diag("Testing --debug option..."); # {{{
# --debug option }}}
diag("Strip error from Mayko format..."); # {{{

testcmd("../gpst -o csv date_error.mayko", # {{{
    <<END,
2003-06-13T09:12:36Z\t5.5794667\t60.4280897\t\t
2003-06-13T09:12:38Z\t5.5802255\t60.4281867\t\t
2003-06-13T09:12:41Z\t5.5813636\t60.4283320\t\t
2003-06-13T09:12:42Z\t5.5817430\t60.4283806\t\t
END
    "",
    "Strip error from mayko format in csv output",
);

# }}}
testcmd("../gpst -o clean date_error.mayko", # {{{
    <<END,
5.5794667\t60.4280897\t
5.5802255\t60.4281867\t
5.5813636\t60.4283320\t
5.5817430\t60.4283806\t
END
    "",
    "Strip error from mayko format in clean output",
);

# }}}
testcmd("../gpst -o gpsml date_error.mayko", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<tp> <time>2003-06-13T09:12:36Z</time> <lat>60.4280897</lat> <lon>5.5794667</lon> </tp>
<tp> <time>2003-06-13T09:12:38Z</time> <lat>60.4281867</lat> <lon>5.5802255</lon> </tp>
<etp err="error"> <time>2037-06-25T17:19:22Z</time> <lat>103.4034054</lat> <lon>129.7271053</lon> </etp>
<tp> <time>2003-06-13T09:12:41Z</time> <lat>60.428332</lat> <lon>5.5813636</lon> </tp>
<tp> <time>2003-06-13T09:12:42Z</time> <lat>60.4283806</lat> <lon>5.581743</lon> </tp>
</track>
</gpsml>
END
    "",
    "Strip error from mayko format in gpsml output",
);

# }}}
testcmd("../gpst -o gpx date_error.mayko", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx
  version="1.1"
  creator="gpst - http://svn.sunbase.org/repos/utils/trunk/src/gpstools/"
  xmlns="http://www.topografix.com/GPX/1/1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
>
  <trk>
    <trkseg>
      <trkpt lat="60.4280897" lon="5.5794667"> <time>2003-06-13T09:12:36Z</time> </trkpt>
      <trkpt lat="60.4281867" lon="5.5802255"> <time>2003-06-13T09:12:38Z</time> </trkpt>
      <!-- <trkpt lat="103.4034054" lon="129.7271053"> <time>2037-06-25T17:19:22Z</time> <extensions> <error>error</error> </extensions> </trkpt> -->
      <trkpt lat="60.4283320" lon="5.5813636"> <time>2003-06-13T09:12:41Z</time> </trkpt>
      <trkpt lat="60.4283806" lon="5.5817430"> <time>2003-06-13T09:12:42Z</time> </trkpt>
    </trkseg>
  </trk>
</gpx>
END
    "",
    "Strip error from mayko format in gpx output",
);

# }}}
testcmd("../gpst -o gpstrans date_error.mayko", # {{{
    <<END,
Format: DMS  UTC Offset:   0.00 hrs  Datum[100]: WGS 84
T\t06/13/2003 09:12:36\t60\xB025'41.1"\t5\xB034'46.1"
T\t06/13/2003 09:12:38\t60\xB025'41.5"\t5\xB034'48.8"
T\t06/13/2003 09:12:41\t60\xB025'42.0"\t5\xB034'52.9"
T\t06/13/2003 09:12:42\t60\xB025'42.2"\t5\xB034'54.3"
END
    "",
    "Strip error from mayko format in gpstrans output",
);

# }}}
testcmd("../gpst -o pgtab date_error.mayko", # {{{
    <<END,
2003-06-13T09:12:36Z\t(60.4280897,5.5794667)\t\\N\t\\N\t\\N\t\\N\t\\N
2003-06-13T09:12:38Z\t(60.4281867,5.5802255)\t\\N\t\\N\t\\N\t\\N\t\\N
2003-06-13T09:12:41Z\t(60.4283320,5.5813636)\t\\N\t\\N\t\\N\t\\N\t\\N
2003-06-13T09:12:42Z\t(60.4283806,5.5817430)\t\\N\t\\N\t\\N\t\\N\t\\N
END
    "",
    "Strip error from mayko format in pgtab output",
);

# }}}
testcmd("../gpst -o poscount date_error.mayko", # {{{
    <<END,
5.5802255\t60.4281867\t1
5.5817430\t60.4283806\t1
5.5813636\t60.4283320\t1
5.5794667\t60.4280897\t1
END
    "",
    "Strip error from mayko format in poscount output",
);

# }}}
testcmd("../gpst -o xgraph date_error.mayko", # {{{
    <<END,
5.5794667 60.4280897
5.5802255 60.4281867
5.5813636 60.4283320
5.5817430 60.4283806
END
    "",
    "Strip error from mayko format in xgraph output",
);

# }}}
testcmd("../gpst -o ygraph date_error.mayko", # {{{
    <<END,
"Time = 0.0
5.5794667 60.4280897

"Time = 2.0
5.5802255 60.4281867

"Time = 5.0
5.5813636 60.4283320

"Time = 6.0
5.5817430 60.4283806

END
    "",
    "Strip error from mayko format in ygraph output",
);

# }}}

# Strip error from Mayko format }}}

todo_section:
;

if ($Opt{'all'} || $Opt{'todo'}) {
    diag("Running TODO tests..."); # {{{

    TODO: {
        local $TODO = "Remove extra \\n in the beginning";
        testcmd("../gpst -o csv multitrack.gpx", # {{{
            <<END,
2003-02-11T23:35:39Z\t-0.1448824\t51.4968266\t\t
2003-02-11T23:35:49Z\t-0.1449938\t51.4968227\t\t
2003-02-11T23:36:14Z\t-0.1453202\t51.4969040\t\t
\t\t\t\t
2003-02-11T23:36:16Z\t-0.1453398\t51.4969214\t\t
2003-02-11T23:36:31Z\t-0.1455514\t51.4969816\t\t
2003-02-11T23:36:43Z\t-0.1457489\t51.4970224\t1000\t
2003-02-11T23:36:50Z\t-0.1457804\t51.4970452\t\t
\t\t\t\t
2003-02-11T23:37:05Z\t-0.1458608\t51.4970680\t\t
2003-02-11T23:37:22Z\t-0.1460047\t51.4971658\t\t
2003-02-11T23:37:36Z\t-0.1461614\t51.4972469\t\t
\t\t\t\t
2003-02-11T23:37:43Z\t-0.1462394\t51.4972731\t\t
2003-02-11T23:38:04Z\t-0.1463232\t51.4973437\t\t
2003-02-11T23:38:28Z\t-0.1462949\t51.4973337\t\t
2003-02-11T23:38:34Z\t-0.1462825\t51.4973218\t\t
2003-02-11T23:38:35Z\t-0.1462732\t51.4973145\t\t
END
            "",
            "Output csv format from gpx",
        );

        # }}}
        testcmd("../gpst -o csv pause.gpx", # {{{
            <<END,
2006-05-21 16:49:11\t5.299534\t60.425494\t25.260\t
2006-05-21 16:49:46\t5.299610\t60.425464\t24.931\t
2006-05-21 16:52:04\t5.299694\t60.425314\t27.975\t
2006-05-21 16:56:36\t5.299741\t60.425384\t31.017\t
2006-05-21 16:56:47\t5.299958\t60.425339\t30.980\t
2006-05-21 16:56:56\t5.299640\t60.425238\t30.538\t
2006-05-21 16:57:03\t5.299686\t60.425246\t30.515\t
2006-05-21 16:59:08\t5.299773\t60.425345\t31.936\t
2006-05-21 17:00:54\t5.299419\t60.425457\t31.794\t
END
            "",
            "csv format from gpx",
        );

        # }}}
        testcmd("../gpst -e -o csv pause.gpx", # {{{
            <<END,
1148230151\t5.299534\t60.425494\t25.260\t
1148230186\t5.299610\t60.425464\t24.931\t
1148230324\t5.299694\t60.425314\t27.975\t
1148230596\t5.299741\t60.425384\t31.017\t
1148230607\t5.299958\t60.425339\t30.980\t
1148230616\t5.299640\t60.425238\t30.538\t
1148230623\t5.299686\t60.425246\t30.515\t
1148230748\t5.299773\t60.425345\t31.936\t
1148230854\t5.299419\t60.425457\t31.794\t
END
            "",
            "csv format with epoch seconds from gpx",
        );

        # }}}
        $TODO = "Use gpsml, this Mayko thing is obsolete.";
        testcmd("../gpst -u no_signal.mayko", # {{{
            <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<tp> <time>2002-12-22T21:42:24Z</time> <lat>70.6800486</lat> <lon>23.6746151</lon> </tp>
<tp> <time>2002-12-22T21:42:32Z</time> <lat>70.6799322</lat> <lon>23.6740038</lon> </tp>
<tp> <time>2002-12-22T21:42:54Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </tp>
<desc>20021222T214351-20021222T214354: CO: No signal \x7B\x7B\x7B</desc>
<etp err="nosignal"> <time>2002-12-22T21:43:51Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<etp err="nosignal"> <time>2002-12-22T21:43:52Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<etp err="nosignal"> <time>2002-12-22T21:43:54Z</time> <lat>70.6796266</lat> <lon>23.6723991</lon> </etp>
<desc>20021222T214351-20021222T214354: CO: No signal \x7D\x7D\x7D</desc>
<break/>
<tp> <time>2002-12-22T21:44:45Z</time> <lat>70.6800774</lat> <lon>23.6757566</lon> </tp>
<tp> <time>2002-12-22T21:44:52Z</time> <lat>70.6801502</lat> <lon>23.6753442</lon> </tp>
<tp> <time>2002-12-22T21:45:04Z</time> <lat>70.6801905</lat> <lon>23.6757542</lon> </tp>
</track>
</gpsml>
END
            "",
            "Output gpsml from the -u option",
        );
        # }}}
        $TODO = "Tweak output";
        testcmd("../gpst -o gpx multitrack-pause.gpsml", # {{{
            file_data("multitrack-pause.gpx"),
            "",
            "Should be equal to multitrack-pause.gpx",
        );

        # }}}
        $TODO = 'Fix it.';
        # list_nearest_waypoints() {{{

        like(list_nearest_waypoints(60.42541, 5.29959, 3),
            qr/^\(.*,.*,.*\)$/,
            "list_nearest_waypoints()"
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
    my $TMP_STDERR = "gpst-stderr.tmp";

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

run-tests.pl [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the gpst(1) program.

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
