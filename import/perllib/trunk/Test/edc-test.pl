#!/usr/bin/perl

# $Id: edc-test.pl,v 1.1 1999/04/08 15:03:19 sunny Exp $

require "tritech/tricgi.pm";

$Str = '(;<>*|&$!#()[]{}:\'"lsdkjvnklsdjvfn';

# print  "Før  : $Str\n";
# printf("Etter: %s\n", &tricgi::escape_dangerous_chars($Str));

while (<>) {
	chomp;
	printf("%s\n", &tricgi::escape_dangerous_chars($_));
}
