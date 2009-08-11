package GPSTxml;

#=======================================================================
# $Id$
# File ID: 7065d156-fafa-11dd-a242-000475e441b9
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
    @EXPORT = qw(&txt_to_xml &xml_to_txt);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub txt_to_xml {
    # Convert plain text to XML {{{
    my $Txt = shift;
    $Txt =~ s/&/&amp;/gs;
    $Txt =~ s/</&lt;/gs;
    $Txt =~ s/>/&gt;/gs;
    return($Txt);
    # }}}
}

sub xml_to_txt {
    # Convert XML data to plain text {{{
    my $Txt = shift;
    $Txt =~ s/&lt;/</gs;
    $Txt =~ s/&gt;/>/gs;
    $Txt =~ s/&amp;/&/gs;
    $Txt =~ s/&quot;/"/gs;
    $Txt =~ s/&apos;/'/gs;
    return($Txt);
    # }}}
}

1;
