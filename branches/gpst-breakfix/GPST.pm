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
use GPSTgeo;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(&trackpoint &postgresql_copy_safe);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

our $Spc = " ";

sub trackpoint {
    # Receive a hash and return a trackpoint as a string {{{
    my %Dat = @_;

    defined($Dat{'type'}) || return(undef);
    defined($Dat{'format'}) || return(undef);
    defined($Dat{'error'}) || return(undef);
    defined($Dat{'break'}) || ($Dat{'break'} = 0);

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

    my $Retval = "";

    if ($Dat{'type'} eq "tp") {
        my $err_str = length($Dat{'error'}) ? $Dat{'error'} : "";
        if ($Dat{'format'} eq "gpsml") {
            # {{{
            my $Elem = length($err_str) ? "etp" : "tp";
            my $tp_str = "";
            $Dat{'break'} && ($Retval .= "<break/>\n");
            $tp_str .= join("",
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
            if (length($tp_str)) {
                ($tp_str = sprintf("<%s%s> %s</%s>\n",
                                   $Elem,
                                   length($err_str) ? " err=\"$err_str\"" : "",
                                   $tp_str,
                                   $Elem
                           )
                );
            }
            $Retval .= $tp_str;
            $Dat{'break'} = 0;
            # }}}
        } elsif($Dat{'format'} eq "gpx") {
            # {{{
            my $tp_str = "";
            my $lat_str = length($Dat{'lat'}) ? " lat=\"$Dat{'lat'}\"" : "";
            my $lon_str = length($Dat{'lon'}) ? " lon=\"$Dat{'lon'}\"" : "";
            if ($Dat{'break'}) {
                $tp_str .= "$Spc$Spc$Spc$Spc</trkseg>\n" .
                           "$Spc$Spc$Spc$Spc<trkseg>\n";
            }
            my ($estr_begin, $estr_ext, $estr_end) =
               (         "",        "",        "");
            if (length($err_str)) {
                $estr_begin = "<!-- ";
                $estr_ext = "<extensions>$Spc<error>$err_str</error>$Spc</extensions>$Spc";
                $estr_end = " -->";
            }
            if (length("$lat_str$lon_str$Dat{'ele'}")) {
                $tp_str .=
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
                        $estr_ext,
                    "</trkpt>$estr_end\n"
                );
            }
            $Retval .= $tp_str;
            # }}}
        } elsif($Dat{'format'} eq "clean") {
            $Retval .= "$Dat{'lon'}\t$Dat{'lat'}\t$Dat{'ele'}\n";
        } elsif($Dat{'format'} eq "xgraph") {
            if (length($Dat{'lat'}) && length($Dat{'lon'})) {
                $Retval .= "$Dat{'lon'} $Dat{'lat'}\n";
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
        } elsif ($Dat{'format'} eq "gpstrans") {
            # {{{
            my ($gpt_lat, $gpt_lon) =
               (ddd_to_dms($Dat{'lat'}), ddd_to_dms($Dat{'lon'}));
            if ($print_time) {
                $Retval .= "T\t$Dat{'month'}/$Dat{'day'}/$Dat{'year'} " .
                         "$Dat{'hour'}:$Dat{'min'}:$Dat{'sec'}\t" .
                         "$gpt_lat\t$gpt_lon\n";
            } else {
                $Retval .= "T\t00/00/00 00:00:00\t$gpt_lat\t$gpt_lon\n";
            }
            # }}}
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
