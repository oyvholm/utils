#!/usr/bin/perl -w

#===============================================
# $Id: hhi,v 1.5 2003/02/14 13:01:05 sunny Exp $
# Html Header Indexer
# Made by Oyvind A. Holm <sunny@sunbase.org>
# License: GNU GPL
#===============================================

use strict;

my $last_level = 1;
my @header_num = qw{0};
my @Data = ();
my @Toc = ();
my %name_used = ();

while (<>) {
	if (!m#<!-- nohhi -->#i && m#^(.*)<(h)(\d+)(.*?)>(.*)$#i) {
		my ($Pref, $H, $header_level, $Elem, $Rest) = ($1, $2, $3, $4, $5);
		if ($header_level > 1) {
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
			$_ = "${Pref}<${H}${header_level}${Elem}><a name=\"$name_str\">$tall_str</a> $Rest\n";
			push(@Toc, "<${H}${header_level}${Elem}><b><a href=\"#$name_str\">$tall_str</a></b> $Rest") unless (/<!-- nohhitoc -->/i);
			$last_level = $header_level;
		}
		push(@Data, "$_");
	} elsif (/<!-- hhitoc -->/i) {
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
	} else {
		push(@Data, "$_");
	}
}

for my $Line (@Data) {
	if ($Line =~ /^(\s*)(<!-- hhitoc -->)(.*)$/i) {
		my ($Indent, $HT, $End) = ($1, $2, $3);
		print("$Line$Indent<ul>\n");
		my $Old = 0;
		my ($Cnt, $Txt) = (0, "");
		for (@Toc) {
			if (/<h(\d+).*?>(.*)<\/h\d+>/i) {
				($Cnt, $Txt) = ($1, $2);
				my $Diff = $Cnt-$Old;
				if ($Old && $Diff > 0) {
					for (my $T = $Diff; $T; $T--) {
						print("$Indent<ul>\n");
					}
				} elsif ($Old && $Diff < 0) {
					print("$Indent</li>\n");
					for (my $T = $Diff; $T; $T++) {
						print("$Indent</ul>\n$Indent</li>\n");
					}
				} elsif ($Old) {
					print("$Indent</li>\n");
				}
				print("$Indent<li>$Txt\n");
				$Old = $Cnt;
			}
		}
		for (; $Cnt > 1; $Cnt--) {
			print("$Indent</li>\n");
			print("$Indent</ul>\n");
		}
	} else {
		print("$Line");
	}
}

__END__

=pod

=head1 NAME

hhi - Html Header Indexer

=head1 REVISION

$Id: hhi,v 1.5 2003/02/14 13:01:05 sunny Exp $

=head1 SYNOPSIS

hhi [files [..]]

=head1 DESCRIPTION

The hhi(1) command (re)numbers the headers of HTML source and is able to create a table of contents in a defined area.
Lines containing C<E<lt>!-- nohhi --E<gt>> will be ignored and lines containg C<E<lt>!-- nohhitoc --E<gt>> will be numbered, but not included in the index.
An optional table of contents will be included between the lines

  <!-- hhitoc -->
  <!-- /hhitoc -->

Any text between those two lines will be replaced.

Every header will be have an index number inserted into the beginning of the header title, e.g.:

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

To avoid creation of names like I<1.2..4>, header levels should not be skipped, do not let a E<lt>h4E<gt> follow a E<lt>h2E<gt> without a E<lt>h3E<gt> in between.

=head1 BUGS

No command line options is provided (yet), all info is thought of being contained in the HTML source.
This is mostly because of maintaining compatibility with older Perl compilers.
The source is untested on Perl versions prior to 5.6.1, any incompatibilities should be reported to the author.

=head1 AUTHOR

Made by Oyvind A. Holm E<lt>sunny@sunbase.orgE<gt>.

=head1 LICENCE

GNU General Public License.

=cut

# End of file $Id: hhi,v 1.5 2003/02/14 13:01:05 sunny Exp $
