#!/usr/bin/perl -wT
#
# Reference implementation for the geohashing algorithm described in xkcd #426
# See http://wiki.xkcd.com/ProjectRainbow/Main_Page
#
# Dan Boger (zigdon@gmail.com)
# 2008-05-21

use strict;
use Digest::MD5 qw/md5_hex/;
use Date::Manip;
use Getopt::Std;

my %opts;
getopts('e', \%opts);

# get the date from the commandline, or assume it's today's date
my $date = shift || "";
$date ||= 'today';
my $datestring = UnixDate( ParseDate($date), "%Y-%m-%d" );

die "Usage: $0 [-e] <date> [DJI opening]"
  unless $datestring and $datestring =~ /^\d\d\d\d-\d\d-\d\d$/;

# get the DJIA from the commandline, or try to retrieve it from google
my $djia = shift;
unless ($djia) {
    $djia = &download_djia($date, $opts{e});
}

print "Date: $datestring, DJIA: $djia\n";

# calculate the MD5 of the combined date and DJIA
my $md5 = md5_hex("$datestring-$djia");
print "MD5($datestring-$djia): $md5\n";

# split into two
my ( $md5x, $md5y ) = ( substr( $md5, 0, 16 ), substr( $md5, 16, 16 ) );
print "Split: $md5x, $md5y\n";

# transform into a fraction
my ( $fx, $fy ) = ( 0, 0 );
while ( length $md5x or length $md5y ) {
    my $d = substr( $md5x, -1, 1, "" );
    $fx += hex $d;
    $fx /= 16;

    $d = substr( $md5y, -1, 1, "" );
    $fy += hex $d;
    $fy /= 16;
}
printf "Fractions: %0.16f, %0.16f\n", $fx, $fy;

sub download_djia {
    my $date = shift;
    my $use_30w_rule = shift;

    if ($use_30w_rule) {
       print "Adjusting for 30W\n";
       $date = DateCalc(ParseDate($datestring), "-1 day");
    }

    my $datestring = UnixDate( ParseDate($date), "%Y-%m-%d" );
    my $djia;

    require LWP::Simple;
    import LWP::Simple 'get';
    require HTML::TreeBuilder;

    my $URL =
'http://finance.google.com/finance/historical?cid=983582&startdate=%s&enddate=%s';
    $URL = sprintf( $URL,
        UnixDate( DateCalc( $date, "- 7 days" ), "%b+%d,+%Y" ),
        UnixDate( $date, "%b+%d,+%Y" ) );
    print "Downloading DJIA from google: $URL\n";
    my $page = get($URL);
    die "Failed to get DJIA from google!" unless $page;
    my $tree = HTML::TreeBuilder->new_from_content($page)
      or die "Failed to parse google DJIA page!";

    my $data = $tree->look_down( id => "prices" ) or die "No data div: $!";
    foreach my $td ( $data->look_down( class => "firstcol" ) ) {
        next if $td->as_text eq 'Date';
        my @date = localtime;
        $djia = $td->right->as_text;
        $djia =~ s/,//g;
        print "DJIA opening for $datestring is $djia\n";
        last;
    }

    $tree->delete;

    die "Failed to retrieve DJIA from google!" unless $djia;

    return $djia;
}
