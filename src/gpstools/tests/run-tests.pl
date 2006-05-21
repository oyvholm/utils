#!/usr/bin/perl -w

#=======================================================================
# $Id$
# [Description]
#
# Character set: UTF-8
# ©opyleft 2006– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

BEGIN {
    push(@INC, "$ENV{'HOME'}/bin/src/gpstools");
    our @version_array;
}

use strict;
use Getopt::Long;
use Test::More qw(no_plan);

use GPSTxml;

$| = 1;

our $Debug = 0;

our %Opt = (
    'debug' => 0,
    'help' => 0,
    'version' => 0,
);

our $progname = $0;
$progname =~ s#^.*/(.*?)$#$1#;

my $rcs_id = '$Id$';
my $id_date = $rcs_id;
$id_date =~ s/^.*?\d+ (\d\d\d\d-.*?\d\d:\d\d:\d\d\S+).*/$1/;

Getopt::Long::Configure("bundling");
GetOptions(
    "debug" => \$Opt{'debug'},
    "help|h" => \$Opt{'help'},
    "version" => \$Opt{'version'},
) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
$Opt{'version'} && print_version();

diag("Check that testing is working");

is(1 + 1 + 1, 3, "One and one and one is three"); # got to be goodlooking ’cause he’s so hard to see

diag("Testing XML routines...");

# txt_to_xml() and xml_to_txt() {{{

is(txt_to_xml("abc"),
    "abc",
    "txt_to_xml(\"abc\")");
is(txt_to_xml("<&>"),
    "&lt;&amp;&gt;",
    "txt_to_xml(\"<&>\")");
is(txt_to_xml("first line\nsecond <\rthird\r\n<&>"),
    "first line\nsecond &lt;\rthird\r\n&lt;&amp;&gt;",
    "txt_to_xml() with multiline string");

is(xml_to_txt("abc"),
    "abc",
    "xml_to_txt(\"abc\")");
is(xml_to_txt("&lt;&amp;&gt;"),
    "<&>",
    "xml_to_txt(\"&lt;&amp;&gt;\")");
is(xml_to_txt("first line\nsecond &lt;\rthird\r\n&lt;&amp;&gt;"),
    "first line\nsecond <\rthird\r\n<&>",
    "xml_to_txt() with multiline string");

# }}}

diag("Testing finished.");

sub print_version {
    # Print program version {{{
    print("$rcs_id\n");
    exit(0);
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    print(<<END);

$rcs_id

Usage: $progname [options] [file [files [...]]]

Contains tests for the gpst(1) program.

Options:

  -h, --help
    Show this help.
  --version
    Print version information.
  --debug
    Print debugging messages.

END
    exit($Retval);
    # }}}
} # usage()

sub D {
    # Print a debugging message {{{
    $Debug || return;
    my @call_info = caller;
    chomp(my $Txt = shift);
    my $File = $call_info[1];
    $File =~ s#\\#/#g;
    $File =~ s#^.*/(.*?)$#$1#;
    print(STDERR "$File:$call_info[2] $$ $Txt\n");
    return("");
    # }}}
} # D()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME



=head1 REVISION

$Id$

=head1 SYNOPSIS

 [options] [file [files [...]]]

=head1 DESCRIPTION



=head1 OPTIONS

=over 4

=item B<-h>, B<--help>

Print a brief help summary.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 BUGS



=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm &lt;sunny@sunbase.org&gt;
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program; if not, write to the Free Software Foundation, Inc., 
59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
# End of file $Id$
