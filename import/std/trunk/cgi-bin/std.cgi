#!/usr/bin/perl -w

#=========================================================
# Standardoppsett til index.cgi
# $Id: std.cgi,v 1.1 2001/04/15 16:20:05 sunny Exp $
# (C)opyright 2001 Øyvind A. Holm <sunny256@mail.com>
#=========================================================

require 5.003;

BEGIN {
	$main::Debug = 0; # Skriver masse debuggingsinfo til $debug_file
	$main::Utv = (-e "utv.mrk") ? 1 : 0;
	$main::SunMask = (-e "/grimme.mrk" ? 1 : 0);
	$main::utv_str = $main::Utv ? " (utv)" : "";
	$main::writable_dir = $main::Utv ? "/home/badata/wrt/utv-basnakk" : "/home/badata/wrt/basnakk";
	$suncgi::Border = 0;
	if ($main::Utv) {
		unshift(@INC, qw{/home/badata/Utv/perllib /home/badata/Utv/basnakk});
	} else {
		unshift(@INC, qw{/home/badata/Stable/perllib /home/badata/Stable/basnakk});
	}
}

use strict;
use Fcntl ':flock';

use suncgi;

$| = 1;

# Ting som suncgi.pm vil ha:
$Url = $main::Utv ? "http://194.248.216.19/skatt/utv/" : "http://194.248.216.19/skatt/";
$debug_file = "$main::writable_dir/DEBUG";
$error_file = "$main::writable_dir/ERROR";
$log_dir = "$main::writable_dir/log";
$request_log_file = "$log_dir/request.log";
$log_requests = 1;
$WebMaster = 'oyvind.holm@ba.no';
$doc_width = '80%';

$main::rcs_id = '$Id: std.cgi,v 1.1 2001/04/15 16:20:05 sunny Exp $';
unshift(@main::rcs_array, $main::rcs_id);

$css_default = <<END;
<style type="text/css">
	<!--
	body { color: #000000; background: #fefbeb; font-family: sans-serif; }
	p, big, th, td, ul, li, h1, h2, h3 { font-family: sans-serif; }
	pre { font-family: monospace; }
	td.for { font-weight: bold; text-align: right; }
	td.oinp, p.oinp { font-weight: bold; text-align: left; }
	td.einp { font-weight: lighter; text-align: left; font-size: small; }
	div.footer { font-family: sans-serif; font-size: x-small; }
	-->
</style>
END

$Opt = get_cgivars();

print_header("Det virket visst.");

tab_print("<h1>Vi er oppe og går</h1>\n");

#### End of file $Id: std.cgi,v 1.1 2001/04/15 16:20:05 sunny Exp $ ####
