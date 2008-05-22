package FLDButf;

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
    @EXPORT = qw(&valid_utf8 &widechar &latin1_to_utf8);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub valid_utf8 {
    # {{{
    my $Text = shift;
    $Text =~ s/([\xFC-\xFD][\x80-\xBF][\x80-\xBF][\x80-\xBF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xF8-\xFB][\x80-\xBF][\x80-\xBF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xF0-\xF7][\x80-\xBF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xE0-\xEF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xC0-\xDF][\x80-\xBF])//g;
    return($Text =~ /[\x80-\xFF]/ ? 0 : 1);
    # }}}
} # valid_utf8()

sub widechar {
    # {{{
    my $Val = shift;
    if ($Val < 0x80) {
        return sprintf("%c", $Val);
    } elsif ($Val < 0x800) {
        return sprintf("%c%c", 0xC0 | ($Val >> 6),
                               0x80 | ($Val & 0x3F));
    } elsif ($Val < 0x10000) {
        return sprintf("%c%c%c", 0xE0 |  ($Val >> 12),
                                 0x80 | (($Val >>  6) & 0x3F),
                                 0x80 |  ($Val        & 0x3F));
    } elsif ($Val < 0x200000) {
        return sprintf("%c%c%c%c", 0xF0 |  ($Val >> 18),
                                   0x80 | (($Val >> 12) & 0x3F),
                                   0x80 | (($Val >>  6) & 0x3F),
                                   0x80 |  ($Val        & 0x3F));
    } elsif ($Val < 0x4000000) {
        return sprintf("%c%c%c%c%c", 0xF8 |  ($Val >> 24),
                                     0x80 | (($Val >> 18) & 0x3F),
                                     0x80 | (($Val >> 12) & 0x3F),
                                     0x80 | (($Val >>  6) & 0x3F),
                                     0x80 | ( $Val        & 0x3F));
    } elsif ($Val < 0x80000000) {
        return sprintf("%c%c%c%c%c%c", 0xFC |  ($Val >> 30),
                                       0x80 | (($Val >> 24) & 0x3F),
                                       0x80 | (($Val >> 18) & 0x3F),
                                       0x80 | (($Val >> 12) & 0x3F),
                                       0x80 | (($Val >>  6) & 0x3F),
                                       0x80 | ( $Val        & 0x3F));
    } else {
        return widechar(0xFFFD);
    }
    # }}}
} # widechar()

sub latin1_to_utf8 {
    # {{{
    my $Text = shift;
    D("latin1_to_utf8()");
    $Text =~ s/([\x80-\xFF])/widechar(ord($1))/ge;
    return($Text);
    # }}}
} # latin1_to_utf8()

1;
