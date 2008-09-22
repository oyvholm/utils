package FLDBsum;

#=======================================================================
# $Id$
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

use strict;
use warnings;
use Digest::MD5;
use Digest::SHA1;
use Digest::CRC;

use lib "$ENV{'HOME'}/bin/src/fldb";
use FLDBdebug;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(&checksum);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub checksum {
    # {{{
    my ($Filename, $use_crc32) = @_;
    my $Retval = "";
    my %Sum = ();
    my $endtime;
    local *FP;

    D("checksum(\"$Filename\"");
    if (open(FP, "<", "$Filename")) {
        my $sha1 = Digest::SHA1->new;
        my $md5 = Digest::MD5->new;
        my $crc32 = Digest::CRC->new(type => "crc32");
        while (my $Curr = <FP>) {
            $sha1->add($Curr);
            $md5->add($Curr);
            $crc32->add($Curr) if $use_crc32;
        }
        $Sum{'sha1'} = $sha1->hexdigest;
        $Sum{'md5'} = $md5->hexdigest;
        $use_crc32 && ($Sum{'crc32'} = sprintf("%08x", $crc32->digest));
    } else {
        %Sum = ();
    }
    D("checksum() returnerer " . scalar(%Sum) . " elementer");
    return(%Sum);
    # }}}
} # checksum()

1;
