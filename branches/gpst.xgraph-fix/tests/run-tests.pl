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
use Test::More qw{no_plan};

use GPST;
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

testcmd("../gpst -o xgraph multitrack.gpx", # {{{
    <<END,
-0.1448208 51.4968987
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
);

# }}}

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
testcmd("../gpst </dev/null", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
</track>
</gpsml>
END
);

# }}}
testcmd("../gpst -o gpx </dev/null", # {{{
    <<END,
<?xml version="1.0" standalone="no"?>
<gpx>
  <trk>
    <trkseg>
    </trkseg>
  </trk>
</gpx>
END
);

# }}}
testcmd("../gpst --fix --chronology chronology-error.gpsml 2>chronofix.tmp", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>\$Id: chronology-error.gpsml 1774 2006-05-20 02:48:39Z sunny \$</title>
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
<tp> <time>2006-05-02T10:18:10Z</time> <lat>60.45395</lat> <lon>5.31544</lon> <ele>103</ele> </tp>
<tp> <time>2006-05-02T10:18:11Z</time> <lat>60.45391</lat> <lon>5.31545</lon> <ele>107</ele> </tp>
</track>
</gpsml>
END
);

# }}}
is(file_data("chronofix.tmp"), # {{{
    "gpst: \"2006-05-02T09:46:46Z\": Next date is 0:00:06:39 in the past (2006-05-02T09:40:07Z)\n",
    "Warning from --chronology --fix");
unlink("chronofix.tmp") || warn("chronofix.tmp: Cannot delete file: $!\n");

# }}}
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
);

# }}}
testcmd("../gpst -o gpx no_signal.mayko", # {{{
    <<END,
<?xml version="1.0" standalone="no"?>
<gpx>
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
);

# }}}
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
);

# }}}
testcmd("../gpst --round lat=4,lon=5,ele=1 pause.gpx", # {{{
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
);

# }}}
testcmd("../gpst -u no_signal.mayko >nosignal.tmp",
    "",
    ); # {{{

if (1) {
    local $TODO = "Use the default output format, this Mayko thing is obsolete.";
    is(file_data("nosignal.tmp"),
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
        "gpst -u no_signal.mayko");
}

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
);
unlink("nosignal.tmp") || warn("nosignal.tmp: Cannot delete file: $!\n");

# }}}
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
);

# }}}
testcmd("../gpst multitrack.gpx", # {{{
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
<title>Track 1</title>
<tp> <time>2003-02-11T23:35:29Z</time> <lat>51.4968987</lat> <lon>-0.1448208</lon> </tp>
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
);

# }}}
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
);

    # }}}
testcmd("../gpst -w -o gpx pause.gpx", # {{{
    <<END,
<?xml version="1.0" standalone="no"?>
<gpx>
<trk>
<trkseg>
<trkpt lat="60.425494" lon="5.299534"><time>2006-05-21T16:49:11Z</time><ele>25.260</ele></trkpt>
<trkpt lat="60.425464" lon="5.299610"><time>2006-05-21T16:49:46Z</time><ele>24.931</ele></trkpt>
<trkpt lat="60.425314" lon="5.299694"><time>2006-05-21T16:52:04Z</time><ele>27.975</ele></trkpt>
<trkpt lat="60.425384" lon="5.299741"><time>2006-05-21T16:56:36Z</time><ele>31.017</ele></trkpt>
<trkpt lat="60.425339" lon="5.299958"><time>2006-05-21T16:56:47Z</time><ele>30.980</ele></trkpt>
<trkpt lat="60.425238" lon="5.299640"><time>2006-05-21T16:56:56Z</time><ele>30.538</ele></trkpt>
<trkpt lat="60.425246" lon="5.299686"><time>2006-05-21T16:57:03Z</time><ele>30.515</ele></trkpt>
<trkpt lat="60.425345" lon="5.299773"><time>2006-05-21T16:59:08Z</time><ele>31.936</ele></trkpt>
<trkpt lat="60.425457" lon="5.299419"><time>2006-05-21T17:00:54Z</time><ele>31.794</ele></trkpt>
</trkseg>
</trk>
</gpx>
END
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
    );

    # }}}
}

testcmd("../gpst -o gpx missing.gpsml", # {{{
    <<END,
<?xml version="1.0" standalone="no"?>
<gpx>
  <trk>
    <trkseg>
      <trkpt lat="60.42353" lon="5.34185"> <time>2006-04-30T17:17:09Z</time> </trkpt>
      <trkpt> <time>2006-04-30T17:17:11Z</time> <ele>483</ele> </trkpt>
      <trkpt> <time>2006-04-30T17:17:22Z</time> <ele>485</ele> </trkpt>
      <trkpt lat="60.42347" lon="5.34212"> <ele>486</ele> </trkpt>
      <trkpt> <ele>484</ele> </trkpt>
      <trkpt> <ele>486</ele> </trkpt>
      <trkpt> <time>2006-04-30T17:18:03Z</time> <ele>490</ele> </trkpt>
      <trkpt lat="60.42338" lon="5.34269"> <time>2006-04-30T17:18:05Z</time> <ele>487</ele> </trkpt>
    </trkseg>
  </trk>
</gpx>
END
    );

# }}}

my %Dat = ();

is(trackpoint(%Dat), # {{{
    undef,
    "trackpoint() receives empty hash");

# }}}

%Dat = (
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

is(trackpoint(%Dat), # {{{

    "<tp> <time>2003-06-13T14:36:10Z</time> <lat>59.5214</lat> <lon>7.392133</lon> <ele>762</ele> </tp>\n",
  "trackpoint(%Dat)");

is(`echo '<tp> </tp>' | ../gpst`,
    <<END,
<?xml version="1.0" encoding="UTF-8"?>
<gpsml>
<track>
</track>
</gpsml>
END
    "Don’t print empty trackpoints");

# }}}

diag("Testing finished.");

sub testcmd {
    # {{{
    my ($Cmd, $Exp) = @_;

    is(`$Cmd`, $Exp, $Cmd);
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
