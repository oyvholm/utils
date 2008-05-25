package FLDBpg;

#=======================================================================
# $Id$
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

use strict;
use warnings;

use lib "$ENV{'HOME'}/bin/src/fldb";
use FLDBdebug;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(&safe_sql);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub safe_sql {
    # {{{
    my $Text = shift;
    $Text =~ s/\\/\\\\/g;
    $Text =~ s/'/''/g;
    $Text =~ s/\n/\\n/g;
    $Text =~ s/\r/\\r/g;
    $Text =~ s/\t/\\t/g;
    return($Text);
    # }}}
} # safe_sql()

1;
