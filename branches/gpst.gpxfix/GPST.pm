package GPST;

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

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(&trackpoint &postgresql_copy_safe @wpt_elems);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

our @wpt_elems = (
    # Position info
    "ele", "time", "magvar", "geoidheight",
    # Description info
    "name", "cmt", "desc", "src", "link", "sym", "type",
    # Accuracy info
    "fix", "sat", "hdop", "vdop", "pdop",
    "ageofdgpsdata", "dgpsid",
    # Extensions
    "extensions"
);

our $Spc = " ";

sub trackpoint {
    # Receive a hash and return a trackpoint as a string {{{
    my %Dat = @_;

    defined($Dat{'what'}) || return(undef);
    defined($Dat{'format'}) || return(undef);
    defined($Dat{'error'}) || return(undef);

    defined($Dat{'year'}) || ($Dat{'year'} = 0);
    defined($Dat{'month'}) || ($Dat{'month'} = 0);
    defined($Dat{'day'}) || ($Dat{'day'} = 0);
    defined($Dat{'hour'}) || ($Dat{'hour'} = "");
    defined($Dat{'min'}) || ($Dat{'min'} = "");
    defined($Dat{'sec'}) || ($Dat{'sec'} = "");
    my $print_time = (
        !$Dat{'year'} ||
        !$Dat{'month'} ||
        !$Dat{'day'} ||
        !length($Dat{'hour'}) ||
        !length($Dat{'min'}) ||
        !length($Dat{'sec'})
    ) ? 0 : 1;

    if (
        ("$Dat{'year'}$Dat{'month'}$Dat{'day'}$Dat{'hour'}$Dat{'min'}" =~
        /[^\d]/) || ($Dat{'sec'} =~ /[^\d\.]/)
    ) {
        ($print_time = 0);
    }
    "$Dat{'lat'}$Dat{'lon'}" =~ /[^\d\.\-\+]/ && return(undef);

    defined($Dat{'lat'}) || ($Dat{'lat'} = "");
    defined($Dat{'lon'}) || ($Dat{'lon'} = "");
    defined($Dat{'ele'}) || ($Dat{'ele'} = "");
    defined($Dat{'desc'}) || ($Dat{'desc'} = "");
    defined($Dat{'extensions'}) || ($Dat{'extensions'} = "");

    my $Retval = "";

    if ($Dat{'what'} eq "tp") {
        my $err_str = length($Dat{'error'}) ? $Dat{'error'} : "";
        if ($Dat{'format'} eq "gpsml") {
            # {{{
            my $Elem = length($err_str) ? "etp" : "tp";
            $Retval .= join("",
                    $print_time
                        ? sprintf("<time>%04u-%02u-%02uT" .
                                  "%02u:%02u:%02gZ</time> ",
                                   $Dat{'year'}, $Dat{'month'}, $Dat{'day'},
                                   $Dat{'hour'}, $Dat{'min'}, $Dat{'sec'}*1.0
                          )
                        : "",
                    (length($Dat{'lat'}))
                        ? "<lat>" . $Dat{'lat'}*1.0 . "</lat> "
                        : "",
                    (length($Dat{'lon'}))
                        ? "<lon>" . $Dat{'lon'}*1.0 . "</lon> "
                        : "",
                    (length($Dat{'ele'}))
                        ? "<ele>" . $Dat{'ele'}*1.0 . "</ele> "
                        : "",
                    (length($Dat{'desc'}))
                        ? sprintf("<desc>%s</desc> ",
                                  $Dat{'desc'})
                        : ""
            );
            length($Retval) &&
                ($Retval = sprintf("<%s%s> %s</%s>\n",
                                   $Elem,
                                   length($err_str) ? " err=\"$err_str\"" : "",
                                   $Retval,
                                   $Elem)
            );
            # }}}
        } elsif($Dat{'format'} eq "gpx") {
            # {{{
            my $lat_str = length($Dat{'lat'}) ? " lat=\"$Dat{'lat'}\"" : "";
            my $lon_str = length($Dat{'lon'}) ? " lon=\"$Dat{'lon'}\"" : "";
            my ($estr_begin, $estr_ext, $estr_end) =
               (         "",        "",        "");
            if (length($err_str)) {
                $estr_begin = "<!-- ";
                $Dat{'extensions'} .= "<error>$err_str</error>";
                $estr_end = " -->";
            }
            if (length("$lat_str$lon_str$Dat{'ele'}")) {
                $Retval .=
                join("",
                    "$Spc$Spc$Spc$Spc$Spc$Spc",
                    $estr_begin,
                    "<trkpt$lat_str$lon_str>",
                    "$Spc",
                    length($Dat{'ele'})
                        ? "<ele>$Dat{'ele'}</ele>$Spc"
                        : "",
                    $print_time
                        ? "<time>" .
                          "$Dat{'year'}-$Dat{'month'}-$Dat{'day'}T" .
                          "$Dat{'hour'}:$Dat{'min'}:$Dat{'sec'}Z" .
                          "</time>$Spc"
                        : "",
                    length($Dat{'extensions'})
                        ? "<extensions>" .
                          $Spc .
                          $Dat{'extensions'} .
                          $Spc .
                          "</extensions>$Spc"
                        : "",
                    $estr_ext,
                    "</trkpt>$estr_end\n"
                );
            }
            # }}}
        } elsif($Dat{'format'} eq "xgraph") {
            if (length($Dat{'lat'}) && length($Dat{'lon'})) {
                $Retval .= "$Dat{'lon'}\t$Dat{'lat'}";
            }
        } elsif ($Dat{'format'} eq "pgtab") {
            $Retval .= join("\t",
                $Dat{'year'}
                    ? "$Dat{'year'}-$Dat{'month'}-$Dat{'day'}T" .
                      "$Dat{'hour'}:$Dat{'min'}:$Dat{'sec'}Z"
                    : '\N', # date
                (length($Dat{'lat'}) && length($Dat{'lon'}))
                    ? "($Dat{'lat'},$Dat{'lon'})"
                    : '\N', # coor
                length($Dat{'ele'}) ? $Dat{'ele'} : '\N', # ele
                '\N', # sted
                '\N', # dist
                '\N', # description
                '\N' # avst
            ) . "\n";
        } else {
            $Retval = undef;
        }
    } else {
        $Retval = undef;
    }
    return $Retval;
    # }}}
}

sub postgresql_copy_safe {
    # {{{
    my $Str = shift;
    $Str =~ s/\\/\\\\/gs;
    $Str =~ s/\n/\\n/gs;
    $Str =~ s/\r/\\r/gs;
    $Str =~ s/\t/\\t/gs;
    return($Str);
    # }}}
}

1;
