#!/usr/bin/perl

#=======================================================================
# hhi
# File ID: 9f049aca-5d3b-11df-8f49-90e6ba3022ac
# Html Header Indexer
#
# Character set: UTF-8
# ©opyleft STDyearDTS– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;
use Getopt::Long;

local $| = 1;

our $Debug = 0;

our %Opt = (

    'all' => 0,
    'debug' => 0,
    'help' => 0,
    'no-number' => 0,
    'startlevel' => 2,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.00';

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'help'},
    'debug' => \$Opt{'debug'},
    'help|h' => \$Opt{'help'},
    'no-number|n' => \$Opt{'no-number'},
    'startlevel|l=i' => "",
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

my $last_level = 1;
my $start_level = 2;
my @header_num = qw{0};
my @Data = ();
my @Toc = ();
my %name_used = ();

if ($Opt{'startlevel'} =~ /^\d+$/) {
    if ($Opt{'startlevel'} < 1) {
        die("$progname: Number passed to -l has to be bigger than zero\n");
    } else {
        $start_level = $Opt{'startlevel'};
    }
} else {
    die("$progname: -l wants a number\n")
}

while (<>) {
    # {{{
    my $orig_line = $_;
    if (!/ nohhi /i && /^(.*)<(h)(\d+)(.*?)>(.*)$/i) {
        # Header found {{{
        my ($Pref, $H, $header_level, $Elem, $Rest) = ($1, $2, $3, $4, $5);
        if ($header_level >= $start_level) {
            my $skip_num = 0;
            splice(@header_num, $header_level-1) if ($header_level < $last_level);
            if ($header_level - $last_level > 1) {
                warn("$progname: Line $.: Header skip ($last_level to $header_level)\n");
                for (my $Tmp = 0; $Tmp < $header_level-2; $Tmp++) {
                    defined($header_num[$Tmp]) || ($header_num[$Tmp] = "");
                }
            }
            $header_num[$header_level-2]++;
            my $tall_str = join(".", @header_num);
            my $name_str = ($Rest =~ /<!-- hhiname (\S+) -->/i) ? $1 : "h-$tall_str";

            if (defined($name_used{$name_str})) {
                warn("$progname: Line $.: \"$name_str\": Section name already used\n");
            }
            $name_used{$name_str} = 1;

            if ($Rest =~ m#^(<a (name|id)=".*?">[\d\.]+</a>\s+)(.*?)$#i) {
                $Rest = $3;
            } elsif ($Rest =~ m#^([\d\.]+)\s*(.*?)$#i) {
                $Rest = $2;
            }
            ($tall_str .= ".") if ($header_level == 2);
            if ($Opt{'no-number'} || $Rest =~ /<!-- nohhinum -->/i) {
                $skip_num = 1;
                $_ = "${Pref}<${H}${header_level}${Elem}>$Rest\n";
            } else {
                $_ = "${Pref}<${H}${header_level}${Elem}><a id=\"$name_str\">$tall_str</a> $Rest\n";
            }
            if (!/<!-- nohhitoc -->/i || $Opt{'all'}) {
                push(@Toc, $skip_num ? "<${H}${header_level}${Elem}>$Rest"
                                     : "<${H}${header_level}${Elem}><b><a href=\"#$name_str\">$tall_str</a></b> $Rest");
            }
            $last_level = $header_level;
        }
        push(@Data, "$_");
        # }}}
    } elsif (/<!-- hhitoc -->/i) {
        # Contents area found, skip everything until a "<!-- /hhitoc 
        # -->" is found
        # {{{
        my $Found = 1;
        my $line_num = $.;
        push(@Data, "$_");
        while (<>) {
            if (m#<!-- /hhitoc -->#i) {
                push(@Data, "$_");
                $Found = 0;
                last;
            }
        }
        $Found && die("$progname: Line $line_num: Missing terminating <!-- /hhitoc -->\n");
        # }}}
    } else {
        push(@Data, "$_");
    }
    # }}}
}

for my $Line (@Data) {
    # Send everything to stdout with optional contents inserted {{{
    if ($Line =~ /^(\s*)(<!-- hhitoc -->)(.*)$/i) {
        my ($Indent, $HT, $End) = ($1, $2, $3);
        print("$Line$Indent<ul>\n$Indent<!-- \x7B\x7B\x7B -->\n");
        my $Old = 0;
        my ($Cnt, $Txt) = (0, "");
        my $Ex = "\t";
        for (@Toc) {
            # {{{
            if (/<h(\d+).*?>(.*)<\/h\d+>/i) {
                ($Cnt, $Txt) = ($1, $2);
                my $Diff = $Cnt-$Old;
                $Ex = ""; # "\t" x $Cnt; # FIXME: Temporary disabled until it works
                if ($Old && $Diff > 0) {
                    for (my $T = $Diff; $T; $T--) {
                        print("$Indent$Ex<ul>\n");
                    }
                } elsif ($Old && $Diff < 0) {
                    print("$Indent$Ex</li>\n");
                    for (my $T = $Diff; $T; $T++) {
                        print("$Indent$Ex</ul>\n$Indent$Ex</li>\n");
                    }
                } elsif ($Old) {
                    print("$Indent$Ex</li>\n");
                }
                print("$Indent$Ex<li><span>$Txt</span>\n");
                $Old = $Cnt;
            }
            # }}}
        }
        for (; $Cnt > 1; $Cnt--) {
            D("Cnt = \"$Cnt\"\n");
            print("$Indent$Ex</li>\n");
            ($Cnt == 2) && print("$Indent<!-- \x7D\x7D\x7D -->\n");
            print("$Indent$Ex</ul>\n");
        }
    } else {
        print("$Line");
    }
    # }}}
}

sub print_version {
    # Print program version {{{
    print("$progname v$VERSION\n");
    return;
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<"END");

Usage: $progname [options] [file [files [...]]]

Parses HTML source and creates section numbers in headers and inserts a 
table of contents in a defined area. Refer to the POD at the end of the 
Perl file for complete info.

Options:

  -a, --all
    Include all headers in the table of contents, even those marked with 
    "<!-- nohhitoc -->"
  -h, --help
    Show this help.
  -l, --startlevel
    Start indexing at this level number. Default: 2.
  -n, --no-number
    Don't number headers
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
    return;
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
    return('');
    # }}}
} # D()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

hhi - Html Header Indexer

=head1 SYNOPSIS

hhi [options] [file [files [...]]]

=head1 DESCRIPTION

The hhi(1) command (re)numbers the headers of HTML source and is able to 
create a table of contents in a defined area.
Lines containing C<E<lt>!-- nohhi --E<gt>> will be ignored and lines 
containg C<E<lt>!-- nohhitoc --E<gt>> will be numbered, but not included 
in the index.
An optional table of contents will be included between the lines

  <!-- hhitoc -->
  <!-- /hhitoc -->

Any text between those two lines will be replaced.

Every header will be have an index number inserted into the beginning of 
the header title, e.g.:

  <h1>Header of document</h1>
    <h2>Table of contents</h2> <!-- nohhi -->
    <!-- hhitoc -->
    <!-- /hhitoc -->
    <h2>Subsection #1</h2>
      <h3>Subsubsection #1.1</h3>
        <h4>Header excluded from the index</h4> <!-- nohhitoc -->
    <h2>Subsection #2</h2>
    <h2>Section with specified name</h2> <!-- hhiname secname -->

will be changed to

  <h1>Header of document</h1>
    <h2>Table of contents</h2> <!-- nohhi -->
    <!-- hhitoc -->
    <ul>
    <li><b><a href="#h-1">1.</a></b> Subsection #1
    <ul>
    <li><b><a href="#h-1.1">1.1</a></b> Subsubsection #1.1
    </li>
    </ul>
    </li>
    <li><b><a href="#h-2">2.</a></b> Subsection #2
    </li>
    <li><b><a href="#secname">3.</a></b> Section with specified name
    </li>
    </ul>
    <!-- /hhitoc -->
    <h2><a id="h-1">1.</a> Subsection #1</h2>
      <h3><a id="h-1.1">1.1</a> Subsubsection #1.1</h3>
        <h4><a id="h-1.1.1">1.1.1</a> Header excluded from the index</h4> <!-- nohhitoc -->
    <h2><a id="h-2">2.</a> Subsection #2</h2>
    <h2><a id="secname">3.</a> Section with specified name</h2> <!-- hhiname secname -->

To avoid creation of names like I<1.2..4>, header levels should not be 
skipped, do not let a E<lt>h4E<gt> follow a E<lt>h2E<gt> without a 
E<lt>h3E<gt> in between.

=head1 OPTIONS

=over 4

=item B<-a>, B<--all>

Include all headers in the contents, even those marked with S<E<lt>!-- 
nohhitoc --E<gt>>.

=item B<-l x>, B<--startlevel x>

Start indexing at level x.
Default value is 2, leaving E<lt>h1E<gt> headers untouched.

==item B<-n>, B<--no-number>

Don’t insert section numbers into headers.

=back

=head1 BUGS



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
