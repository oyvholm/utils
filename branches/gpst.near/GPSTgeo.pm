package GPSTgeo;

#=======================================================================
# $Id$
#
# Character set: UTF-8
# ©opyleft 2002– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

use strict;
use warnings;

use GPSTdebug;

use Geo::Distance;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(
        $wpt_elems
        &list_nearest_waypoints &ddd_to_dms &distance
    );
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;
our $wpt_elems = "ele|time|magvar|geoidheight|name|cmt|desc|src|link|sym|" .
                 "type|fix|sat|hdop|vdop|pdop|ageofdgpsdata|dgpsid|" .
                 "extensions";

# FIXME: Hardcoding
my $waypoint_file = "$ENV{HOME}/bin/src/gpstools/tests/waypoints.gpx";
my @orig_waypoints = load_waypoints($waypoint_file);

sub list_nearest_waypoints {
    # {{{
    my ($Lat, $Lon, $Count) = @_;
    my $Retval = "";
    my @Waypoints = @orig_waypoints;

    D("list_nearest_waypoints('$Lat', '$Lon', '$Count')");

    for my $i (0 .. $#Waypoints) {
        $Waypoints[$i]{'distance'} = distance(
            $Lat, $Lon,
            $Waypoints[$i]{'lat'},
            $Waypoints[$i]{'lon'}
        );
        if ($main::Debug) {
            my $dstr = "$i is { ";
            for my $role (keys %{ $Waypoints[$i] }) {
                $dstr .= "$role=\"$Waypoints[$i]{$role}\" ";
            }
            D($dstr . "}");
        }
    }

    # my @Sorted = sort { $Waypoints[$b]{distance} } <=> $Waypoints[$a]{distance} } keys @Waypoints;
    my @Sorted = sort_waypoints("distance", "+", \@Waypoints);

    if ($main::Debug) {
        for my $i (0 .. $#Waypoints) {
            my $dstr = "sorted $i is { ";
            for my $role (keys %{ $Sorted[$i] }) {
                $dstr .= "$role=\"$Sorted[$i]{$role}\" ";
            }
            D($dstr . "}");
        }
    }

    for my $i2 (0 .. $Count - 1) {
        my $pos = $i2 + 1;
        $Retval .= "<near pos=\"$pos\"> <name>$Sorted[$i2]{'name'}</name> <distance>$Sorted[$i2]{'distance'}</distance> </near>";
    }
    return($Retval);
    # }}}
}

sub distance {
    # Return distance between two positions. {{{
    my ($Lat1, $Lon1, $Lat2, $Lon2, $Unit) = @_;
    defined($Unit) || ($Unit = "metre");
    my  $Retval = "";

    my $geo = new Geo::Distance;
    $Retval = $geo->distance($Unit, $Lat1, $Lon1 => $Lat2, $Lon2);
    return($Retval);
    # }}}
}

sub load_waypoints {
    # {{{
    my $File = shift;
    my @Retval = ();

    D("Opening $File for read");
    if (open(WaypFP, "<", $File)) {
        my $Data = join("", <WaypFP>);
        # D("Data = '$Data'");
        close(WayFP);
        @Retval = parse_waypoints($Data);
    } else {
        $main::Opt{'verbose'} && warn("$File: Cannot open file for read\n");
        @Retval = undef;
    }
    D("load_waypoints('$File') returns '" . join("|", @Retval) . "'");
    return @Retval;
    # }}}
}

sub parse_waypoints {
    # {{{
    my $Data = shift;
    my @Retval = ();
    # D("parse_waypoints('$Data')");
    $Data =~
    s{
        <wpt\b(.*?)\blat="(.+?)".+?\blon="(.+?)".*?>(.*?)</wpt>
    }{
        my ($Lat, $Lon, $el_wpt) =
           (1.0 * $2, 1.0 * $3, $4);
        my $wpt = {};
        $wpt->{'lat'} = $Lat;
        $wpt->{'lon'} = $Lon;
        D("parse: Lat = '$Lat', Lon = '$Lon'");
        $el_wpt =~
        s{
            <($wpt_elems)\b.*?>(.*?)</($wpt_elems)>
        }{
            my $Elem = $1;
            $wpt->{$Elem} = $2;
            "";
        }gsex;
        push(@Retval, $wpt);
        D("push Retval '$wpt'");
        "";
    }gsex;
    D("parse_waypoints() returns '" . join("|", @Retval) . "'");
    return(@Retval);
    # }}}
}

sub sort_waypoints {
    # FIXME: Unfinished. {{{
    my ($Key, $Dir) = (shift, shift);
    my @Retval = @_;
    return(@Retval);
    # }}}
}

sub ddd_to_dms {
    # Convert floating-point degrees into D°M'S.S" (ISO-8859-1). 
    # Necessary for import into GPSman. Based on toDMS() from 
    # gpstrans-0.39 to ensure compatibility.
    # {{{
    my $ddd = shift;
    my $Neg = 0;
    my ($Hour, $Min, $Sec) =
       (    0,    0,    0);
    my $Retval = "";

    ($ddd =~ /^\-?(\d*)(\.\d+)?$/) || return(undef);
    length($ddd) || ($ddd = 0);

    if ($ddd < 0.0) {
        $ddd = 0 - $ddd;
        $Neg = 1;
    }
    $Hour = int($ddd);
    $ddd = ($ddd - $Hour) * 60.0;
    $Min = int($ddd);
    $Sec = ($ddd - $Min) * 60.0;

    if ($Sec > 59.5) {
        $Sec = 0.0;
        $Min += 1.0;
    }
    if ($Min > 59.5) {
        $Min = 0.0;
        $Hour += 1.0;
    }
    $Retval = sprintf("%s%.0f\xB0%02.0f'%04.1f\"",
                      $Neg
                        ? "-"
                        : "",
                      $Hour, $Min, $Sec);
    return $Retval;
    # }}}
}

1;
