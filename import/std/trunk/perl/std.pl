#!/usr/bin/perl -w

#===============================================================
# $Id$
# [Description]
#
# Character set: UTF-8
# License: GNU General Public License
# ©opyleft 2004 Øyvind A. Holm <sunny@sunbase.org>
#===============================================================

use strict;

$| = 1;

use Getopt::Std;
our ($opt_d, $opt_h, $opt_i, $opt_s, $opt_v) = ("", 0, 0, 0, 0);
getopts('h') || die("Option error. Use -h fopr help.");

$opt_h && usage(0);



sub usage {
	# Send the help message to stdout {{{
	my $Retval = shift;
	print(<<END);

Usage:

END
	exit($Retval);
	# }}}
}

__END__

# vim: set fileencoding=UTF-8 filetype=perl foldmethod=marker foldlevel=0 :
# End of file $Id$
