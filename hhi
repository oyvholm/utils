#!/usr/bin/perl -w

#=======================================================================
# hhi
# File ID: 9f049aca-5d3b-11df-8f49-90e6ba3022ac
# Html Header Indexer
# Made by Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

use strict;

use Getopt::Std;
our ($opt_a, $opt_h, $opt_l, $opt_n) =
    (     0,      0,      2,      0);
getopts('ahl:n');

my $Debug = 0; # 0 = Standard, 1 = Send debug msgs to stderr

my $last_level = 1;
my $start_level = 2;
my @header_num = qw{0};
my @Data = ();
my @Toc = ();
my %name_used = ();

if ($opt_h) {
    print(<<END);

Syntax: $0 [options] [file [...]]

Parses HTML source and creates section numbers in headers and inserts a 
table of contents in a defined area. Refer to the POD at the end of the 
Perl file for complete info.

Options:

  -a  Include all headers in the table of contents, even those marked 
      with "<!-- nohhitoc -->"
  -h  This help message
  -l  Start indexing at this level number. Default: $start_level
  -n  Don't number headers

END
    exit(0);
}

if ($opt_l =~ /^\d+$/) {
    if ($opt_l < 1) {
        die("$0: Number passed to -l has to be bigger than zero\n");
    } else {
        $start_level = $opt_l;
    }
} else {
    die("$0: -l wants a number\n")
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
                warn("$0: Line $.: Header skip ($last_level to $header_level)\n");
                for (my $Tmp = 0; $Tmp < $header_level-2; $Tmp++) {
                    defined($header_num[$Tmp]) || ($header_num[$Tmp] = "");
                }
            }
            $header_num[$header_level-2]++;
            my $tall_str = join(".", @header_num);
            my $name_str = ($Rest =~ /<!-- hhiname (\S+) -->/i) ? $1 : "h-$tall_str";

            if (defined($name_used{$name_str})) {
                warn("$0: Line $.: \"$name_str\": Section name already used\n");
            }
            $name_used{$name_str} = 1;

            if ($Rest =~ m#^(<a name=".*?">[\d\.]+</a>\s+)(.*?)$#i) {
                $Rest = $2;
            } elsif ($Rest =~ m#^([\d\.]+)\s*(.*?)$#i) {
                $Rest = $2;
            }
            ($tall_str .= ".") if ($header_level == 2);
            if ($opt_n || $Rest =~ /<!-- nohhinum -->/i) {
                $skip_num = 1;
                $_ = "${Pref}<${H}${header_level}${Elem}>$Rest\n";
            } else {
                $_ = "${Pref}<${H}${header_level}${Elem}><a name=\"$name_str\">$tall_str</a> $Rest\n";
            }
            if (!/<!-- nohhitoc -->/i || $opt_a) {
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
        $Found && die("$0: Line $line_num: Missing terminating <!-- /hhitoc -->\n");
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

sub D {
    print(STDERR @_) if $Debug;
}

__END__

# POD {{{

=pod

=head1 NAME

hhi - Html Header Indexer

=head1 SYNOPSIS

hhi [options] [files [..]]

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
    <h2><a name="h-1">1.</a> Subsection #1</h2>
      <h3><a name="h-1.1">1.1</a> Subsubsection #1.1</h3>
        <h4><a name="h-1.1.1">1.1.1</a> Header excluded from the index</h4> <!-- nohhitoc -->
    <h2><a name="h-2">2.</a> Subsection #2</h2>
    <h2><a name="secname">3.</a> Section with specified name</h2> <!-- hhiname secname -->

To avoid creation of names like I<1.2..4>, header levels should not be 
skipped, do not let a E<lt>h4E<gt> follow a E<lt>h2E<gt> without a 
E<lt>h3E<gt> in between.

=head1 OPTIONS

=over 4

=item B<-a>

Include all headers in the contents, even those marked with S<E<lt>!-- 
nohhitoc --E<gt>>.

=item B<-l x>

Start indexing at level x.
Default value is 2, leaving E<lt>h1E<gt> headers untouched.

==item B<-n>

Don’t insert section numbers into headers.

=back

=head1 AUTHOR

Copyleft 2002E<8211> E<216>yvind A. Holm E<lt>sunny@sunbase.orgE<gt>.

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

=cut

# }}}

# vim: ft=perl fdm=marker fdl=0 ts=4 sw=4 sts=4 et fenc=UTF-8 fo+=w2 :
# End of file hhi
