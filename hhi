#!/usr/bin/perl

#===============================================
# $Id: hhi,v 1.3 2002/04/15 04:06:11 sunny Exp $
# Html Header Indexer
# Made by Oyvind A. Holm <sunny@sunbase.org>
#===============================================

use strict;

my $last_level = 0;
my @header_num = qw{0};

while (<>) {
	chomp();
	if (m!^(.*)<(h)(\d+)(.*?)>(.*)!i) {
		my ($Pref, $H, $header_level, $Elem, $Rest) = ($1, $2, $3, $4, $5);
		if ($header_level > 1) {
			splice(@header_num, $header_level-1) if ($header_level < $last_level);
			$header_num[$header_level-2]++;
			my $tall_str = join(".", @header_num);
			$Rest =~ s/^([\d\s\.]+)(.*)/$2/;
			($tall_str .= ".") if ($header_level == 2);
			$_ = "${Pref}<${H}${header_level}${Elem}>$tall_str $Rest";
			$last_level = $header_level;
		}
	}
	print("$_\n");
}
