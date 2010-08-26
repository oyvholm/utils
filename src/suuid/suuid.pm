#!/usr/bin/perl -w

#=======================================================================
# suuid.pm
# File ID: e851e5da-afa6-11df-952d-d714dff0e0e7
#
# Character set: UTF-8
# ©opyleft 2010– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;
use bigint;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    @ISA = qw(Exporter);
    @EXPORT = qw(&uuid_time &suuid_xml);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub uuid_time {
    # {{{
    my $uuid = shift;
    my $Retval = "";
    if (open(UtFP, "uuid -d $uuid 2>/dev/null |")) {
        while (my $Curr = <UtFP>) {
            if ($Curr =~ /time:\s+(\d\d\d\d-\d\d-\d\d) (\d\d:\d\d:\d\d\.\d{6})\.(\d) UTC/) {
                $Retval = "${1}T$2${3}Z";
                last;
            }
        }
        close(UtFP);
    } else {
        warn("$main::progname: Cannot open uuid -d pipe: $!\n");
    }
    return($Retval);
    # }}}
} # uuid_time()

sub uuid_time2 {
    # {{{
    my $uuid = shift;
    my $Retval = "";
    my $Lh = "[0-9a-fA-F]"; # FIXME: Should be global
    my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}"; # FIXME: Should be global
    ($uuid =~ /^$v1_templ$/) || return("");
    my $hex_string = uuid_hex_date($uuid);
    my $val = hex($hex_string);
    my $nano = sprintf("%07u", $val % 10_000_000);
    my $t = ($val / 10_000_000) - 12_219_292_800;
    my @TA = gmtime($t);
    $Retval = sprintf("%04u-%02u-%02uT%02u:%02u:%02u.%sZ",
        $TA[5]+1900, $TA[4]+1, $TA[3],
        $TA[2], $TA[1], $TA[0], $nano);
    return($Retval);
    # }}}
} # uuid_time2()

sub uuid_hex_date {
    # {{{
    my $uuid = shift;
    my $time_low = lc(substr($uuid, 0, 8));
    my $time_mid = lc(substr($uuid, 9, 4));
    my $time_hi = lc(substr($uuid, 15, 3));
    # CO: Notes {{{
    # 2639d59e-fa20-11dd-8aa6-000475e441b9
    # 012345678901234567890123456789012345
    # 000000000011111111112222222222333333
    #
    # 2639d59e 0-3 time_low (0-7)
    # -
    # fa20 4-5 time_mid (9-12)
    # -
    # 11dd 6-7 time_hi_and_version (15-17)
    # -
    # 8a  8 clock_seq_hi_and_reserved (19-20)
    # a6  9 clock_seq_low (21-22)
    # -
    # 000475e441b9 10-15 node (24-35)
    # }}}
    my $Retval = "$time_hi$time_mid$time_low";
    # D("uuid_hex_date('$uuid') returns '$Retval'");
    return($Retval);
    # }}}
} # uuid_hex_date()

sub suuid_xml {
    # {{{
    my ($Str, $skip_conv) = @_;
    defined($skip_conv) || ($skip_conv = 0);
    if (!$skip_conv) {
        $Str =~ s/&/&amp;/gs;
        $Str =~ s/</&lt;/gs;
        $Str =~ s/>/&gt;/gs;
        $Str =~ s/\\/\\\\/gs;
        $Str =~ s/\n/\\n/gs;
        $Str =~ s/\r/\\r/gs;
        $Str =~ s/\t/\\t/gs;
    }
    return($Str);
    # }}}
} # suuid_xml()

1;

__END__

# Plain Old Documentation (POD) {{{

=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation, either version 3 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program.
If not, see L<http://www.gnu.org/licenses/>.

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
