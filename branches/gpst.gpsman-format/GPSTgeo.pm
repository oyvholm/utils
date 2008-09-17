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

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(&list_nearest_waypoints &ddd_to_dms &dms_to_ddd);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub list_nearest_waypoints {
    # {{{
    my ($Lat, $Lon, $Count) = @_;

    # FIXME: Hardcoding
    my $waypoint_file = "/home/sunny/gps/waypoints.gpx";

    # FIXME: Incredible unfinished and kludgy.
    if (open(WaypFP, "$main::Cmd{'gpsbabel'} -i gpx -f $waypoint_file " .
                     "-x radius,lat=$Lat,lon=$Lon,distance=1000 " .
                     "-o gpx -F - |")
    ) {
        my $Str = join("", <WaypFP>);
        $Str =~ s{
            ^.*?<wpt\s.*?>.*?<name>(.+?)</name>.*?</wpt>.*?
             .*?<wpt\s.*?>.*?<name>(.+?)</name>.*?</wpt>.*?
             .*?<wpt\s.*?>.*?<name>(.+?)</name>.*?</wpt>.*$
        }{
            "($1, $2, $3)";
        }sex;
        return($Str);
    } else {
        die("$main::progname: Cannot open $main::Cmd{'gpsbabel'} pipe: $!\n");
    }
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

sub dms_to_ddd {
    # {{{
    my ($Deg, $Min, $Sec) = @_;

    defined($Deg) || ($Deg = 0);
    defined($Min) || ($Min = 0);
    defined($Sec) || ($Sec = 0);

    length($Deg) || ($Deg = 0);
    length($Min) || ($Min = 0);
    length($Sec) || ($Sec = 0);

    if ("$Deg$Min$Sec" =~ /[^\d\.]/) {
        return(undef);
    }
    my $Retval = 1.0 * sprintf("%f", $Deg + 1.0*$Min/60 + 1.0*$Sec/3600);
    return($Retval);
    # }}}
}

1;
