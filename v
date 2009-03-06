#!/usr/bin/perl -w

#=======================================================================
# $Id$
# File ID: 797f5e70-fa63-11dd-9838-000475e441b9
# Kaller opp Vim og logger sessionen med suuid.
#
# Character set: UTF-8
# ©opyleft 2009– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

BEGIN {
    our @version_array;
}

use strict;
use Getopt::Long;

$| = 1;

our $Debug = 0;

our %Opt = (

    'comment' => "",
    'debug' => 0,
    'help' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;

my $rcs_id = '$Id$';
my $id_date = $rcs_id;
$id_date =~ s/^.*?\d+ (\d\d\d\d-.*?\d\d:\d\d:\d\d\S+).*/$1/;

push(@main::version_array, $rcs_id);

Getopt::Long::Configure("bundling");
GetOptions(

    "comment|c=s" => \$Opt{'comment'},
    "debug" => \$Opt{'debug'},
    "help|h" => \$Opt{'help'},
    "verbose|v+" => \$Opt{'verbose'},
    "version" => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

my $Lh = "[0-9a-fA-F]";
my $v1_templ = "$Lh\{8}-$Lh\{4}-1$Lh\{3}-$Lh\{4}-$Lh\{12}";

my $comm_str = "";
if (length($Opt{'comment'})) {
    $comm_str = sprintf(" <comment>%s</comment>", $Opt{'comment'});
}
my @Fancy = ();
my @Files = ();
my %smsum = ();
for my $curr_arg (@ARGV) {
    if (-r $curr_arg) {
        chomp(my $file_id = `finduuid "$curr_arg" | head -1`);
        chomp($smsum{"o.$curr_arg"} = `smsum <"$curr_arg"`);
        push(@Files, $curr_arg);
        push(@Fancy,
            "<file> " .
                "<name>$curr_arg</name> " .
                (length($file_id) ? "<fileid>$file_id</fileid> " : "") .
                "<smsum>" . $smsum{"o.$curr_arg"} . "</smsum> " .
            "</file>"
        );
    } else {
        push(@Fancy, $curr_arg);
    }
}
my $cmd_str = suuid_xml(join(" ", @Fancy), 1);
chomp(my $uuid=`suuid --raw -t c_v_begin -w eo -c '<c_v w="begin"> $cmd_str$comm_str </c_v>'`);
if (!defined($uuid) || $uuid !~ /^$v1_templ$/) {
    die("$progname: suuid error\n");
}
defined($ENV{'SESS_UUID'}) || ($ENV{'SESS_UUID'} = "");
$ENV{'SESS_UUID'} .= "$uuid,";
system("vim", @ARGV);
$ENV{'SESS_UUID'} =~ s/$uuid,//;
my $change_str = "";
for my $Curr (@Files) {
    chomp($smsum{"n.$Curr"} = `smsum <"$Curr"`);
    if ($smsum{"o.$Curr"} ne $smsum{"n.$Curr"}) {
        chomp(my $file_id = `finduuid "$Curr" | head -1`);
        $change_str .= sprintf(
            " <file>" .
                " <name>%s</name>" .
                "%s" . # File ID, the first UUID in the file
                " <old>%s</old>" .
                " <new>%s</new>" .
            " </file>",
            suuid_xml($Curr),
            length($file_id) ? " <fileid>$file_id</fileid>" : "",
            $smsum{"o.$Curr"}, $smsum{"n.$Curr"},
        );
    }
}

if (length($change_str)) {
    $change_str = " <changed>$change_str </changed>";
}
system("suuid --raw -t c_v_end -c '<c_v w=\"end\"> <finished>$uuid</finished>$change_str </c_v>'");
$ENV{'SESS_UUID'} =~ s/$uuid,//;

sub suuid_xml {
    # {{{
    my ($Str, $skip_xml) = @_;
    defined($skip_xml) || ($skip_xml = 0);
    if (!$skip_xml) {
        $Str =~ s/&/&amp;/gs;
        $Str =~ s/</&lt;/gs;
        $Str =~ s/>/&gt;/gs;
    }
    $Str =~ s/\\/\\\\/gs;
    $Str =~ s/\n/\\n/gs;
    $Str =~ s/\r/\\r/gs;
    $Str =~ s/\t/\\t/gs;
    return($Str);
    # }}}
} # suuid_xml()

sub print_version {
    # Print program version {{{
    for (@main::version_array) {
        print("$_\n");
    }
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<END);

Usage: $progname [options] [file [files [...]]]

Options:

  -c X, --comment X
    Session comment.
  -h, --help
    Show this help.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.
  --debug
    Print debugging messages.

END
    exit($Retval);
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
    # }}}
} # msg()

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

=item B<-v>, B<--verbose>

Increase level of verbosity. Can be repeated.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 BUGS



=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
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
