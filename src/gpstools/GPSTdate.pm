package GPSTdate;

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
    @EXPORT = qw(&sec_to_string &sec_to_readable);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub sec_to_string {
    # Convert seconds since 1970 to "yyyy-mm-dd hh:mm:ss" with optional 
    # separator
    # {{{
    my ($Seconds, $Sep) = @_;
    defined($Sep) || ($Sep = " ");
    my @TA = gmtime($Seconds);
    my($DateString) = sprintf("%04u-%02u-%02u%s%02u:%02u:%02u",
                              $TA[5]+1900, $TA[4]+1, $TA[3], $Sep,
                              $TA[2], $TA[1], $TA[0]);
    return($DateString);
    # }}}
}

sub sec_to_readable {
    # Convert seconds since 1970 to human-readable format (d:hh:mm:ss)
    # {{{
    my $secs = shift;
    my ($Day, $Hour, $Min, $Sec) =
       (   0,     0,    0,    0);

    $Day = int($secs/86400);
    $secs -= $Day * 86400;

    $Hour = int($secs/3600);
    $secs -= $Hour * 3600;

    $Min = int($secs/60);
    $secs -= $Min * 60;

    $Sec = $secs;

    return(sprintf("%u:%02u:%02u:%02u", $Day, $Hour, $Min, $Sec));
    # }}}
}

1;
