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
