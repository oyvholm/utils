package suncgi;

#==========================================================
# $Id: suncgi.pm,v 1.37.2.3 2003/10/13 06:16:05 sunny Exp $
# Standardrutiner for cgi-bin-programmering.
# Tilhører branchen "public-ba" for bruk hos Bergensavisen.
# Dokumentasjon ligger som pod på slutten av fila.
# (C)opyright 1999-2003 Øyvind A. Holm <sunny@sunbase.org>
#==========================================================

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw{
	%Opt %Cookie
	@cookies_done
	get_cookie set_cookie delete_cookie split_cookie
	content_type create_file curr_local_time curr_utc_time deb_pr
	escape_dangerous_chars file_mdate get_cgivars get_countervalue HTMLdie
	HTMLwarn inc_counter increase_counter log_access print_header p_footer tab_print tab_str
	Tabs url_encode print_doc sec_to_string
	$has_args $query_string
	$log_requests $ignore_double_ip
	$curr_utc $CharSet $Tabs $Border $Footer $WebMaster $base_url $Url
	$css_default
	$doc_lang $doc_align $doc_width
	$debug_file $error_file $log_dir $Method $request_log_file $emptyrequest_log_file
	$DTD_HTML4FRAMESET $DTD_HTML4LOOSE $DTD_HTML4STRICT
};

@EXPORT_OK = qw{
	print_footer
};
# %EXPORT_TAGS = tag => [...];  # define names for sets of symbols

use Fcntl ':flock';
use strict;

require 5.003;

$suncgi::Tabs = "";
$suncgi::curr_utc = time;
$suncgi::log_requests = 0; # 1 = Logg alle POST og GET, 0 = Drit i det
$suncgi::ignore_double_ip = 0; # 1 = Skipper flere etterfølgende besøk fra samme IP, 0 = Nøye då

$suncgi::rcs_id = '$Id: suncgi.pm,v 1.37.2.3 2003/10/13 06:16:05 sunny Exp $';
push(@main::rcs_array, $suncgi::rcs_id);

$suncgi::this_counter = "";

$suncgi::DTD_HTML4FRAMESET = qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">\n};
$suncgi::DTD_HTML4LOOSE = qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n};
$suncgi::DTD_HTML4STRICT = qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n};

$suncgi::STD_LANG = "no";
$suncgi::STD_BACKGROUND = "";
$suncgi::STD_CHARSET = "ISO-8859-1"; # Hvis $suncgi::CharSet ikke er definert
$suncgi::STD_DOCALIGN = "left"; # Standard align for dokumentet hvis align ikke er spesifisert
$suncgi::STD_DOCWIDTH = '95%'; # Hvis ikke $suncgi::doc_width er spesifisert
$suncgi::STD_HTMLDTD = $suncgi::DTD_HTML4LOOSE;

$suncgi::CharSet = $suncgi::STD_CHARSET;
$suncgi::css_default = "";
$suncgi::doc_width = $suncgi::STD_DOCWIDTH;
$suncgi::doc_align = $suncgi::STD_DOCALIGN;
$suncgi::doc_lang = $suncgi::STD_LANG;
$suncgi::Border = 0;
$suncgi::Method = "post";

$suncgi::Footer = <<END;
	</body>
</html>
END

#### Subrutiner ####

sub content_type {
	my $ContType = shift;
	my $loc_charset;
	if (length($suncgi::CharSet)) {
		$loc_charset = $suncgi::CharSet;
	} else {
		$loc_charset = $suncgi::STD_CHARSET;
		HTMLwarn("content_type(): \$suncgi::CharSet udefinert. Bruker \"$loc_charset\".");
	}
	if (length($ContType)) {
		print "Content-Type: $ContType; charset=$loc_charset\n\n" ;
	} else {
		HTMLwarn("Intern feil: \$ContType ble ikke spesifisert til content_type()");
	}
	# print "Content-Type: $ContType\n\n"; # Til ære for slappe servere som ikke har peiling
} # content_type()

sub curr_local_time {
	my @TA = localtime();
	# my $GM = mktime(gmtime());
	# my $LO = localtime();
	# my $utc_diff = ($GM-$LO)/3600;

	# - # &deb_pr(__LINE__ . ": curr_local_time(): gmtime = \"$GM\", localtime = \"$LO\"");
	my $LocalTime = sprintf("%04u-%02u-%02uT%02u:%02u:%02u", $TA[5]+1900, $TA[4]+1, $TA[3], $TA[2], $TA[1], $TA[0]);
	# &deb_pr(__LINE__ . ": curr_local_time(): Returnerer \"$LocalTime\"");
	return($LocalTime);
} # curr_local_time()

sub create_file {
	my $file_name = shift;
	local *LocFP;
	return if (-e $file_name);
	open(LocFP, ">$file_name") || HTMLdie("create_file(): $file_name: Klarte ikke å lage fila: $!");
	close(LocFP);
} # create_file()

sub curr_utc_time {
	my @TA = gmtime(time);
	my $UtcTime = sprintf("%04u-%02u-%02uT%02u:%02u:%02uZ", $TA[5]+1900, $TA[4]+1, $TA[3], $TA[2], $TA[1], $TA[0]);
	# &deb_pr(__LINE__ . ": curr_utc_time(): Returnerer \"$UtcTime\"");
	return($UtcTime);
} # curr_utc_time()

sub deb_pr {
	return unless $main::Debug;
	my $Msg = shift;
	my @call_info = caller;
	$Msg =~ s/^(.*?)\s+$/$1/;
	my $err_msg = "";
	if (-e $suncgi::debug_file) {
		open(DebugFP, "+<$suncgi::debug_file") || ($err_msg = "Klarte ikke å åpne debugfila for lesing/skriving");
	} else {
		open(DebugFP, ">$suncgi::debug_file") || ($err_msg = "Klarte ikke å lage debugfila");
	}
	unless(length($err_msg)) {
		flock(DebugFP, LOCK_EX);
		seek(DebugFP, 0, 2) || ($err_msg = "Kan ikke seek'e til slutten av debugfila");
	}
	if (length($err_msg)) {
		print <<END;
Content-type: text/html

$suncgi::DTD_HTML4STRICT
<html>
	<!-- $suncgi::rcs_id -->
	<head>
		<title>Intern feil i deb_pr()</title>
	</head>
	<body>
		<h1>Intern feil i deb_pr()</h1>
		<p>${err_msg}: <samp>$!</samp>
		<p>Litt info:
		<p>\$main::Debug = "$main::Debug"
		<br>\${suncgi::debug_file} = "${suncgi::debug_file}"
		<br>\${suncgi::error_file} = "${suncgi::error_file}"
	</body>
</html>
END
		exit();
	}
	my $deb_time = time;
	my $Fil = $call_info[1];
	$Fil =~ s#\\#/#g;
	$Fil =~ s#^.*/(.*?)$#$1#;
	print(DebugFP "$deb_time $Fil:$call_info[2] $$ $Msg\n");
	close(DebugFP);
} # deb_pr()

sub escape_dangerous_chars {
	my $string = shift;

	$string =~ s/([;\\<>\*\|`&\$!#\(\)\[\]\{\}'"])/\\$1/g;
	return $string;
} # escape_dangerous_chars()

sub file_mdate {
	my($FileName) = @_;
	my(@TA);
	my @StatArray = stat($FileName);
	return($StatArray[9]);
} # file_mdate()

sub get_cgivars {
	my ($in, %in);
	my ($name, $value) = ("", "");
	$in = "";
	# FIXME: Noe byr meg imot her...
	foreach my $var_name ('HTTP_USER_AGENT', 'REMOTE_ADDR', 'REMOTE_HOST', 'HTTP_REFERER', 'CONTENT_TYPE', 'CONTENT_LENGTH', 'QUERY_STRING') {
		defined($ENV{$var_name}) || ($ENV{$var_name} = "");
	}
	my $user_method = defined($ENV{REQUEST_METHOD}) ? $ENV{REQUEST_METHOD} : "";
	# length($user_method) || ($user_method = "");

	# length($ENV{REQUEST_METHOD}) ||
	$suncgi::has_args = ($#ARGV > -1) ? 1 : 0;
	if ($suncgi::has_args) {
		$in = $ARGV[0];
	} elsif (($user_method =~ /^get$/i) ||
	         ($user_method =~ /^head$/i)) {
		$in = $ENV{QUERY_STRING};
	} elsif ($user_method =~ /^post$/i) {
		if ($ENV{CONTENT_TYPE} =~ m#^(application/x-www-form-urlencoded|text/xml)$#i) {
			length($ENV{CONTENT_LENGTH}) || HTMLdie("Ingen Content-Length vedlagt POST-forespørselen.");
			my $Len = $ENV{CONTENT_LENGTH};
			read(STDIN, $in, $Len) || HTMLwarn("get_cgivars(): Feil under read() fra STDIN: $!");
		} else {
			HTMLdie("Usupportert Content-Type: \"$ENV{CONTENT_TYPE}\"") if length($ENV{CONTENT_TYPE});
			exit;
		}
	} else {
		if (length($user_method)) {
			HTMLdie("Programmet ble kalt med ukjent REQUEST_METHOD: \"$user_method\"");
			exit;
		}
	}
	defined($suncgi::request_log_file) || ($suncgi::request_log_file = "");
	defined($suncgi::emptyrequest_log_file) || ($suncgi::emptyrequest_log_file = "");
	if (length($suncgi::request_log_file) && $suncgi::log_requests) {
		local *ReqFP;
		my $loc_in = $in;
		unless (length($suncgi::emptyrequest_log_file)) { # For bakoverkompatibilitet før suncgi.pm,v 1.29
			$suncgi::emptyrequest_log_file = "$suncgi::request_log_file.empty";
		}
		my $file_name = length($in) ? $suncgi::request_log_file : "$suncgi::emptyrequest_log_file";
		if (-e $file_name) {
			open(ReqFP, "+<$file_name") || HTMLdie("$file_name: Klarte ikke å åpne loggfila for r+w: $!");
		} else {
			open(ReqFP, ">$file_name") || HTMLdie("$file_name: Klarte ikke å lage loggfila: $!");
		}
		flock(ReqFP, LOCK_EX);
		seek(ReqFP, 0, 2) || HTMLdie("$file_name: Klarte ikke å seeke til slutten: $!");
		print(ReqFP "$suncgi::curr_utc\t$ENV{REMOTE_ADDR}\t$in\n") || HTMLwarn("$file_name: Klarte ikke å skrive til loggfila: $!");
		close(ReqFP);
	}
	$suncgi::query_string = $in;
	foreach (split("[&;]", $in)) {
		s/\+/ /g;
		my ($name, $value) = ("", "");
		($name, $value) = split('=', $_, 2);
		$name =~ s/%(..)/chr(hex($1))/ge;
		$value =~ s/%(..)/chr(hex($1))/ge;
		$in{$name} .= "\0" if defined($in{$name});
		$in{$name} .= $value;
		# Den under her er veldig grei å ha upåvirket av perldeboff(1).
		deb_pr(__LINE__ . ": get_cgivars(): $name = \"$value\"");
	}
	return %in;
} # get_cgivars()

sub get_cookie {
	my $env_str = defined($ENV{'HTTP_COOKIE'}) ? $ENV{'HTTP_COOKIE'} : "";
	my ($chip, $val);
	foreach (split(/; /, $env_str)) {
		# split cookie at each ; (cookie format is name=value; name=value; etc...)
		# Convert plus to space (in case of encoding (not necessary, but recommended)
		s/\+/ /g;
		# Split into key and value.
		my ($chip, $val) = ("", "");
		($chip, $val) = split(/=/,$_,2); # splits on the first =.
		# Convert %XX from hex numbers to alphanumeric
		$chip =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
		$val =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
		# Associate key and value
		$suncgi::Cookie{$chip} .= "\1" if (defined($suncgi::Cookie{$chip})); # \1 is the multiple separator
		$suncgi::Cookie{$chip} .= $val;
		deb_pr("get_cookie(): $chip=$val");
	}
} # get_cookie()

sub set_cookie {
	# $expires must be in unix time format, if defined.  If not defined it sets the expiration to December 31, 1999.
	# If you want no expiration date set, set $expires = -1 (this causes the cookie to be deleted when user closes
	# his/her browser).

	my ($expires, $domain, $path, $sec) = @_;
	my (@days) = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
	my (@months) = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	my ($seconds,$min,$hour,$mday,$mon,$year,$wday);
	if ($expires > 0) {
		# get date info if expiration set.
		($seconds,$min,$hour,$mday,$mon,$year,$wday) = gmtime($expires);
		$seconds = "0" . $seconds if $seconds < 10; # formatting of date variables
		$min = "0" . $min if $min < 10;
		$hour = "0" . $hour if $hour < 10;
	}
	my (@secure) = ("","secure"); # add security to the cookie if defined.  I'm not too sure how this works.
	if (!defined $expires) {
		# if expiration not set, expire at 12/31/1999
		$expires = " expires\=Fri, 31-Dec-1999 00:00:00 GMT;";
	} elsif ($expires == -1) {
		# if expiration set to -1, then eliminate expiration of cookie.
		$expires = "";
	} else {
		$year += 1900;
		$expires = "expires\=$days[$wday], $mday-$months[$mon]-$year $hour:$min:$seconds GMT; "; #form expiration from value passed to function.
	}
	if (!defined $domain) {
		# set domain of cookie.  Default is current host.
		$domain = $ENV{'SERVER_NAME'};
	}
	if (!defined $path) {
		# set default path = "/"
		$path = "/";
	}
	(!defined($sec) || !length($sec)) || ($sec = "0");
	while (my ($Key, $Value) = each %suncgi::Cookie) {
	# foreach my $key (keys %suncgi::Cookie) {
		defined($Value) || ($Value = "");
		$Value =~ s/ /+/g; #convert plus to space.
		defined($sec) || ($sec = 0);
		my $cookie_str = "Set-Cookie: $Key\=$Value; $expires path\=$path; domain\=$domain; $secure[$sec]\n";
		deb_pr($cookie_str);
		print($cookie_str);
		push(@suncgi::cookies_done, $cookie_str);
		undef $suncgi::Cookie{key};
		# print cookie to browser,
		# this must be done *before*	you print any content type headers.
	}
	undef %suncgi::Cookie;
} # set_cookie()

sub delete_cookie {
	# to delete a cookie, simply pass delete_cookie the name of the cookie to delete.
	# you may pass delete_cookie more than 1 name at a time.
	my (@to_delete) = @_;
	my ($name);
	foreach $name (@to_delete) {
		undef $suncgi::Cookie{$name}; #undefines cookie so if you call set_cookie, it doesn't reset the cookie.
		print "Set-Cookie: $name=; expires=Thu, 01-Jan-1970 00:00:00 GMT;\n";
		#this also must be done before you print any content type headers.
	}
} # delete_cookie()

sub split_cookie {
	# Splits a multi-valued parameter into a list of the constituent parameters

	my ($param) = @_;
	my (@params) = split ("\1", $param);
	return (wantarray ? @params : $params[0]);
} # split_cookie()

sub get_countervalue {
	my $counter_file = shift;
	my $counter_value = 0;
	local *TmpFP;
	# &deb_pr(__LINE__ . ": get_countervalue(): Åpner $counter_file for lesing+flock");
	unless (-e $counter_file) {
		open(TmpFP, ">$counter_file") || (HTMLwarn("$counter_file i get_countervalue(): Klarte ikke å lage fila: $!"), return(0));
		flock(TmpFP, LOCK_EX);
		print TmpFP "0\n";
		close(TmpFP);
	}
	open(TmpFP, "<$counter_file") || (HTMLwarn("$counter_file i get_countervalue(): Kan ikke åpne fila for lesing: $!"), return(0));
	flock(TmpFP, LOCK_EX);
	$counter_value = <TmpFP>;
	chomp($counter_value);
	close(TmpFP);
	# &deb_pr(__LINE__ . ": get_countervalue(): $counter_file: Fila er lukket, returnerer fra subrutina med \"$counter_value\"");
	return $counter_value;
} # get_countervalue()

sub HTMLdie {
	my($Msg,$Title) = @_;
	my $utc_str = curr_utc_time;
	my $msg_str = "";

	deb_pr("HDIE: $Msg");
	$Title || ($Title = "Intern feil");
	if (!$main::Debug && !$main::Utv) {
		$msg_str = "<p>En intern feil har oppst&aring;tt. Feilen er loggf&oslash;rt, og vil bli fikset snart.";
	} else {
		chomp($msg_str = $Msg);
	}
	print <<END;
Content-type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">

<html lang="no">
	<!-- $suncgi::rcs_id -->
	<!-- $main::rcs_id -->
	<head>
		<title>$Title</title>
		<style type="text/css">
			<!--
			body { background: white; color: black; font-family: sans-serif; }
			a:link { color: blue; }
			a:visited { color: maroon; }
			a:active { color: fuchsia; }
			b.krise { color: red; }
			h1 { color: red; }
			-->
		</style>
		<meta http-equiv="Content-Type" content="text/html; charset=$suncgi::CharSet">
END
	print(<<END) if defined($suncgi::WebMaster);
		<meta name="author" content="$suncgi::WebMaster">
END
	print <<END;
		<meta name="copyright" content="&copy; &Oslash;yvind A. Holm">
		<meta name="description" content="CGI error">
		<meta name="date" content="$utc_str">
END
	print(<<END) if defined($suncgi::WebMaster);
		<link rev="made" href="mailto:$suncgi::WebMaster">
END
	print <<END;
	</head>
	<body>
		<h1>$Title</h1>
		<blockquote>
			$msg_str
		</blockquote>
	</body>
</html>
END
	if (length(${suncgi::error_file})) {
		unless (-e $suncgi::error_file) {
			open(ErrorFP, ">$suncgi::error_file");
			close(ErrorFP);
		}
		open(ErrorFP, "+<${suncgi::error_file}") or exit;
		flock(ErrorFP, LOCK_EX);
		seek(ErrorFP, 0, 2) or exit;
		$Msg =~ s/\\/\\\\/g;
		$Msg =~ s/\n/\\n/g;
		$Msg =~ s/\t/\\t/g;
		printf(ErrorFP "%s HDIE %s\n", $utc_str, $Msg);
		close(ErrorFP);
	}
	exit;
} # HTMLdie()

sub HTMLwarn {
	my $Msg = shift;
	my $utc_str = curr_utc_time();
	deb_pr("WARN: $Msg");
	# Gjør det så stille og rolig som mulig.
	if ($main::Utv || $main::Debug) {
		print_header("CGI warning");
		tab_print("<p><b>HTMLwarn(): $Msg</b>\n");
	}
	if (-e ${suncgi::error_file}) {
		open(ErrorFP, ">>${suncgi::error_file}") or return;
	} else {
		open(ErrorFP, ">${suncgi::error_file}") or return;
	}
	$Msg =~ s/\\/\\\\/g;
	$Msg =~ s/\n/\\n/g;
	$Msg =~ s/\t/\\t/g;
	print(ErrorFP "$utc_str WARN $Msg\n");
	close(ErrorFP);
} # HTMLwarn()

# increase_counter() øker kun med 1 hvis IP'en er forskjellig fra forrige gang.
# Hvis parameter 2 er !0, øker den uanskvett.

sub increase_counter {
	my ($counter_file, $ignore_ip) = @_;
	my $last_ip = "";
	HTMLwarn("suncgi::increase_counter() er avlegs. inc_counter() svinger.") if $main::Debug;
	$ignore_ip = 0 unless defined($ignore_ip);
	my $ip_file = "$counter_file.ip";
	my $user_ip = $ENV{REMOTE_ADDR};
	local *TmpFP;
	create_file($counter_file);
	create_file($ip_file);
	open(TmpFP, "+<$ip_file") || (HTMLwarn("$ip_file i increase_counter(): Kan ikke åpne fila for lesing og skriving: $!"), return(0));
	flock(TmpFP, LOCK_EX);
	$last_ip = <TmpFP>;
	chomp($last_ip);
	my $new_ip = ($last_ip eq $user_ip) ? 0 : 1;
	$new_ip = 1 if ($ignore_ip || $suncgi::ignore_double_ip);
	if ($new_ip) {
		seek(TmpFP, 0, 0) || (HTMLwarn("$ip_file: Kan ikke gå til begynnelsen av fila: $!"), close(TmpFP), return(0));
		print(TmpFP "$user_ip\n");
	}
	open(TmpFP, "+<$counter_file") || (HTMLwarn("$counter_file i increase_counter(): Kan ikke åpne fila for lesing og skriving: $!"), return(0));
	flock(TmpFP, LOCK_EX);
	my $counter_value = <TmpFP>;
	if ($new_ip) {
		seek(TmpFP, 0, 0) || (HTMLwarn("$counter_file: Kan ikke gå til begynnelsen av fila: $!"), close(TmpFP), return(0));
		printf(TmpFP "%u\n", $counter_value+1);
	}
	close(TmpFP);
	return($counter_value + ($new_ip ? 1 : 0));
} # increase_counter()

sub inc_counter {
	my ($counter_file, $Value) = @_;
	my $last_ip = "";
	$Value = 1 unless defined($Value);
	local *TmpFP;
	create_file($counter_file);
	open(TmpFP, "+<$counter_file") || (HTMLwarn("$counter_file i inc_counter(): Kan ikke åpne fila for lesing og skriving: $!"), return(0));
	flock(TmpFP, LOCK_EX);
	my $counter_value = <TmpFP>;
	seek(TmpFP, 0, 0) || (HTMLwarn("$counter_file: Kan ikke gå til begynnelsen av fila: $!"), close(TmpFP), return(0));
	$counter_value += $Value;
	print(TmpFP "$counter_value\n");
	close(TmpFP);
	return($counter_value);
} # inc_counter()

sub log_access {
	my ($Base, $no_counter) = @_;
	my $log_dir = length(${suncgi::log_dir}) ? ${suncgi::log_dir} : $suncgi::STD_LOGDIR;
	my $File = "$log_dir/$Base.log";
	my $Countfile = "$log_dir/$Base.count";
	create_file($File);
	open(LogFP, "+<$File") || (HTMLwarn("$File: Can't open access log for read/write: $!"), return);
	flock(LogFP, LOCK_EX);
	seek(LogFP, 0, 2) || (HTMLwarn("$Countfile: Can't seek to EOF: $!"), close(LogFP), return);
	foreach my $var_name ('HTTP_USER_AGENT', 'REMOTE_ADDR', 'REMOTE_HOST', 'HTTP_REFERER') {
		defined($ENV{$var_name}) || ($ENV{$var_name} = "");
	}
	my $Agent = $ENV{HTTP_USER_AGENT};
	$Agent =~ s/\n/\\n/g; # Vet aldri hva som kommer
	printf(LogFP "%u\t%s\t%s\t%s\t%s\n", time, $ENV{REMOTE_ADDR}, $ENV{REMOTE_HOST}, $ENV{HTTP_REFERER}, $Agent);
	close(LogFP);
	$suncgi::this_counter = increase_counter($Countfile) unless $no_counter;
} # log_access()

sub print_doc {
	my ($file_name, $page_num) = @_;
	my $in_header = 1;
	my %doc_val;

	open(FromFP, "<$file_name") || HTMLdie("$file_name: Kan ikke åpne fila for lesing: $!");
	LINE: while (<FromFP>) {
		chomp;
		next LINE if /^#\s/;
		last unless length;
		if (/^(\S+)\s+(.*)$/) {
			$doc_val{$1} = $2;
		} else {
			HTMLwarn("$file_name: Ugyldig headerinfo i linje $.: \"$_\"");
		}
	}
	$doc_val{title} || HTMLwarn("$file_name: Mangler title");
	$doc_val{owner} || HTMLwarn("$file_name: Mangler owner");
	$doc_val{lang} || HTMLwarn("$file_name: Mangler lang");
	$doc_val{id} || HTMLwarn("$file_name: Mangler id");
	# $doc_val{} || HTMLwarn("$file_name: Mangler ");
	if ($main::Debug) {
		print_header("er i print_doc"); # debug
		while (my ($act_name,$act_time) = each %doc_val) {
			print("<br>\"$act_name\"\t\"$act_time\"\n");
		}
	}
	# my ($DocTitle, $html_version, $Language, $user_background, $Refresh, $no_body, $Description, $Keywords, @StyleSheet) = @_;
	print_header($doc_val{title}, "", $doc_val{lang}, $doc_val{background}, $doc_val{refresh}, $doc_val{no_body}, $doc_val{description}, $doc_val{keywords});
	while (<FromFP>) {
		chomp;
		tab_print("$_\n");
	}
	print <<END;
	</body>
</html>
END
	close(FromFP);
} # print_doc()

sub p_footer {
	my $no_endhtml = shift;
	defined($no_endhtml) || ($no_endhtml = 0);
	my $Retval = "";
	my ($validator_str, $array_str) = ("&nbsp;", "");
	if ($main::Utv) {
		my $query_enc = url_encode($suncgi::query_string);
		my $url_enc = url_encode($suncgi::Url);
		# FIXME: Hardkoding av URL
		$validator_str = <<END;
					<a href="$suncgi::Url?$suncgi::query_string">URL</a>&nbsp;
					<a href="http://jigsaw.w3.org/css-validator/validator?uri=$url_enc%3F$query_enc"><img border="0" src="images/vcss.png" alt="[CSS-validator]" height="31" width="88"></a>
					<a href="http://validator.w3.org/check?uri=$url_enc%3F$query_enc;ss=1;outline=1"><img border="0" src="images/valid-html401.png" alt="[HTML-validator]" height="31" width="88"></a>
END
		$array_str .= <<END . join("\n$suncgi::Tabs<br>", @main::rcs_array) . <<END;
			<tr>
				<td colspan="2" align="center">
					<table cellpadding="10" cellspacing="0" border="5">
						<tr>
							<td width="100%">
END

							</td>
						</tr>
					</table>
				</td>
			</tr>
END
	}

	$Retval = <<END;
		<table width="$suncgi::doc_width" cellpadding="0" cellspacing="0" border="$suncgi::Border">
			<tr>
				<td colspan="2">
					<hr>
				</td>
			</tr>
			<tr>
				<td align="left">
					<small>&lt;<code><a href="mailto:$suncgi::WebMaster">$suncgi::WebMaster</a></code>&gt;
					<br>&#169; &#216;yvind A. Holm</small>
				</td>
				<td align="right" valign="middle">
$validator_str
				</td>
			</tr>
$array_str
		</table>
END
	$Retval .= <<END unless ($no_endhtml);
	</body>
</html>
END
	return $Retval;
} # p_footer()

sub print_footer {
	my ($footer_width, $footer_align, $no_vh, $no_end) = @_;

	# &deb_pr(__LINE__ . ": Går inn i print_footer(\"$footer_width\", \"$footer_align\", \"$no_vh\", \"$no_end\")");
	defined($footer_width) || ($footer_width = "");
	unless (length($footer_width)) {
		$footer_width = length($suncgi::doc_width) ? $suncgi::doc_width : $suncgi::STD_DOCWIDTH;
	}
	unless (length($footer_align)) {
		$footer_align = length($suncgi::doc_align) ? $suncgi::doc_align : $suncgi::STD_DOCALIGN;
	}
	$no_vh = 0 unless defined($no_vh);
	$no_end = 0 unless defined($no_end);
	my $rcs_str = ${main::rcs_date}; # FIXME: Er ikke nødvendigvis denne som skal brukes.
	$rcs_str =~ s/ /&nbsp;/g;
	my $vh_str = $no_vh ? "&nbsp;" : "<a href=\"http://validator.w3.org/check/referer;ss\"><img src=\"${main::GrafDir}/vh40.gif\" height=\"31\" width=\"88\" align=\"right\" border=\"0\" alt=\"Valid HTML 4.0!\"></a>";
	my $count_str = length($suncgi::this_counter) ? "Du er bes&oslash;kende nummer $suncgi::this_counter p&aring; denne siden." : "&nbsp;";

	# FIXME: Hardkoding av URL her pga av at ${suncgi::Url} har skifta navn.
	# FIXME: I resten av HTML'en er det brukt <div align="center">.
	tab_print(<<END);
<table width="$footer_width" cellpadding="0" cellspacing="0" border="$suncgi::Border" align="$footer_align">
	<tr>
		<td colspan="3">
			<hr>
		</td>
	</tr>
	<tr>
		<td align="center">
			<table cellpadding="0" cellspacing="0" border="$suncgi::Border">
				<tr>
					<td align="center">
						<small>$rcs_str</small>
					</td>
				</tr>
			</table>
		</td>
		<td width="100%" align="center">
			$count_str
		</td>
		<td align="right">
			$vh_str
		</td>
	</tr>
</table>
END
	unless ($no_end) {
		Tabs(-2);
		tab_print(<<END);
	</body>
</html>
END
	}
	exit; # FIXME: Sikker på det?
} # print_footer()

sub print_header {
	my ($DocTitle, $RefreshStr, $style_sheet, $head_script, $body_attr, $html_version, $head_lang, $no_body) = @_;
	# &deb_pr(__LINE__ . ": Går inn i print_header(), \$DocTitle=\"$DocTitle\"");
	if ($suncgi::header_done) {
		# &deb_pr(__LINE__ . "Yo! print_header() ble kjørt selv om \$suncgi::header_done = $suncgi::header_done");
		print("\n<!-- debug: print_header($DocTitle) selv om \$suncgi::header_done -->\n");
		return;
	} else {
		$suncgi::header_done = 1;
	}
	# FIXME: Kanskje dette kan gjøres via referanser istedenfor.
	defined($DocTitle) || ($DocTitle = ""); # FIXME: Midlertidig
	defined($RefreshStr) || ($RefreshStr = "");
	defined($style_sheet) || ($style_sheet = "");
	defined($head_script) || ($head_script = "");
	defined($body_attr) || ($body_attr = "");
	defined($html_version) || ($html_version = $Suncgi::DTD_HTML4LOOSE);
	defined($head_lang) || ($head_lang = "");
	defined($no_body) || ($no_body = 0);
	$style_sheet = $suncgi::css_default unless length($style_sheet);
	$head_lang = $suncgi::STD_LANG unless length($head_lang);
	$html_version = $suncgi::DTD_HTML4LOOSE unless defined($html_version);
	$no_body = 0 unless length($no_body);
	my $DocumentTime = curr_utc_time();
	length($RefreshStr) && ($RefreshStr = qq{<meta http-equiv="refresh" content="$RefreshStr" url="$suncgi::Url">});

	content_type("text/html");
	print $html_version;
	print "\n<html lang=\"$head_lang\">\n";
	Tabs(1);
	$head_script = "" unless defined($head_script);
	if (defined(@main::rcs_array)) {
		foreach(@main::rcs_array) {
			tab_print("<!-- $_ -->\n");
		}
	}
	tab_print(<<END);
<head>
	<title>$DocTitle</title>
	<meta http-equiv="Content-Type" content="text/html; charset=$suncgi::CharSet">
END
	Tabs(1);
	tab_print($RefreshStr) if length($RefreshStr);
	tab_print(<<END);
<meta name="author" content="&Oslash;yvind A. Holm">
<meta name="copyright" content="&copy; &Oslash;yvind A. Holm">
<meta name="date" content="$DocumentTime">
END
	tab_print(<<END) if defined($suncgi::WebMaster);
<link rev="made" href="mailto:$suncgi::WebMaster">
END
	# tab_print ("Tabs = Tabs\n");
	tab_print($style_sheet) if length($style_sheet);
	tab_print($head_script) if length($head_script);
	Tabs(-1);
	tab_print("</head>\n");
	unless ($no_body) {
		tab_print("<body$body_attr>\n");
		Tabs(1);
	}
} # print_header()

sub tab_print {
	my @Txt = @_;

	unless($suncgi::header_done) {
		print_header("tab_print()-header");
		print("\n<!-- debug: tab_print() før print_header(). Tar saken i egne hender. -->\n");
	}

	foreach (@Txt) {
		s/^(.*)/${suncgi::Tabs}$1/gm;
		s/([\x7f-\xff])/sprintf("&#%u;", ord($1))/ge;
		print "$_";
	}
} # tab_print()

sub tab_str {
	my @Txt = @_;
	my $RetVal = "";

	foreach (@Txt) {
		s/^(.*)/${suncgi::Tabs}$1/gm;
		s/([\x7f-\xff])/sprintf("&#%u;", ord($1))/ge;
		$RetVal .= "$_";
	}
	return $RetVal;
} # tab_str()

sub Tabs {
	my $Value = shift;

	# FIXME: Finpussing seinere.
	if ($Value > 0) {
		for (1..$Value) {
			$suncgi::Tabs =~ s/(.*)/$1\t/;
		}
	} elsif ($Value < 0) {
		$Value = 0 - $Value;
		for (1..$Value) {
			$suncgi::Tabs =~ s/^(.*)\t/$1/;
		}
	} else {
		HTMLwarn("Intern feil: Tabs() ble kalt med \$Value = 0");
	}
} # Tabs()

sub url_encode {
	my $String = shift;

	defined($String) || ($String = "");
	$String =~ s/([\x00-\x20"#%&\.\/;<>?{}|\\\\^~`\[\]\x7F-\xFF])/
	           sprintf ('%%%X', ord($1))/eg;

	return $String;
} # url_encode()

sub sec_to_string {
	my ($Seconds, $Sep, $Sep2, $Gmt) = @_;
	defined($Sep)  || ($Sep = "");
	defined($Sep2) || ($Sep2 = "");
	defined($Gmt)  || ($Gmt = 0);
	$Sep = "T" unless length($Sep);
	$Sep2 = "-" unless length($Sep2);
	my @TA = $Gmt ? gmtime($Seconds) : localtime($Seconds);
	my($DateString) = sprintf("%04u%s%02u%s%02u%s%02u:%02u:%02u%s", $TA[5]+1900, $Sep2, $TA[4]+1, $Sep2, $TA[3], $Sep, $TA[2], $TA[1], $TA[0], $Gmt ? "Z" : "");
	return($DateString);
} # sec_to_string()

1;

__END__

=head1 NAME

suncgi - HTML-rutiner for bruk i index.cgi

=head1 REVISION

S<$Id: suncgi.pm,v 1.37.2.3 2003/10/13 06:16:05 sunny Exp $>

=head1 SYNOPSIS

use suncgi;

=head1 DESCRIPTION

Inneholder en del rutiner som brukes av F<index.cgi>.
Inneholder generelle HTML-rutiner som brukes hele tiden.

=head1 COPYRIGHT

(C)opyright 1999-2003 Øyvind A. Holm E<lt>F<sunny@sunbase.org>E<gt>

=head1 VARIABLER

=head2 Nødvendige variabler

Når man bruker dette biblioteket, er det en del variabler som må defineres
under kjøring:

=over 4

=item I<${suncgi::Url}>

URL'en til index.cgi.
Normalt sett blir denne satt til navnet på scriptet, for eksempel "I<index.cgi>" eller lignende.
Før ble I<${suncgi::Url}> satt til full URL med F<httpZ<>://> og greier, men det gikk dårlig hvis ting for eksempel ble kjørt under F<httpsZ<>://>

=item I<${suncgi::WebMaster}>

Emailadressen til den som eier dokumentet.
Denne blir ikke satt inn på copyrighter og sånn.

=item I<${suncgi::error_file}>

Filnavn på en fil som er skrivbar av den som kjører scriptet (som oftest I<nobody>).
Alle feilmeldinger og warnings havner her.

=item I<${suncgi::log_dir}>

Navn på directory der logging fra blant annet I<log_access()> havner.
Brukeren I<nobody> (eller hva nå httpd måtte kjøre under) skal ha skrive/leseaksess der.

=back

NB: Disse må ikke være I<my>'et, de må være globale så de kan bli brukt av alle modulene.

=head2 Valgfrie variabler

Disse variablene er ikke nødvendige å definere, bare hvis man gidder:

=over 4

=item I<${suncgi::doc_width}>

Bredden på dokumentet i pixels.
I<$suncgi::STD_DOCWIDTH> som default.

=item I<${CharSet}>

Tegnsett som brukes.
Er I<$suncgi::STD_CHARSET> som default, "I<ISO-8859-1>".

=item I<${main::BackGround}>

Bruker denne som default bakgrunn til I<print_background()>.
Hvis den ikke er definert, brukes I<$suncgi::STD_BACKGROUND>, en tom greie.

=item I<${main::Debug}>

Skriver ut en del debuggingsinfo.

=item I<${main::Utv}>

Beslektet med I<${main::Debug}>, men hvis denne er definert, sitter man lokalt og tester.
Eneste forskjellen hovedsaklig er at feilmeldinger går til skjerm i tillegg til errorfila.

=item I<${suncgi::Border}>

Brukes mest til debugging. Setter I<border> i alle E<lt>tableE<gt>'es.

=back

=head1 SUBRUTINER

=head2 content_type()

Brukes omtrent bare av F<print_header()>, men kan kalles
separat hvis det er speisa content-typer ute og går, som for eksempel
C<application/x-tar> og lignende.

=head2 curr_local_time()

Returnerer tidspunktet akkurat nå, lokal tid. Formatet er i henhold til S<ISO 8601>, dvs.
I<YYYY>-I<MM>-I<DD>TI<HH>:I<MM>:I<SS>+I<HHMM>

B<FIXME:> Finn en måte å returnere differansen mellom UTC og lokal tid.
Foreløpig droppes +0200 og sånn. Det liker vi I<ikke>. Ikke baser noen
programmer på formatet foreløpig.

=head2 create_file()

Lager en fil hvis den ikke eksisterer fra før.

=head2 curr_utc_time()

Returnerer tidspunktet akkurat nå i UTC. Brukes av blant annet
F<print_header()> til å sette rett tidspunkt inn i headeren. Formatet på
datoen er i henhold til S<ISO 8601>, dvs.
I<YYYY>-I<MM>-I<DD>TI<HH>:I<MM>:I<SS>Z

=head2 deb_pr()

En debuggingsrutine som kjøres hvis ${main::Debug} ikke er 0. Den
forlanger at ${suncgi::error_file} er definert, det skal være en fil der
all debuggingsinformasjonen skrives til.

For at debugging skal bli lettere, kan man slenge denne inn på enkelte
steder. Eksempel:

	# deb_pr(__LINE__ . ": sort_dir(): Det er $Elements elementer her.");

Hvis dette formatet brukes (fram til og med __LINE__) kan man filtrere fila
gjennom denne perlsnutten for å kommentere ut alle debuggingsmeldingene:

	#!/usr/bin/perl

	while (<>) {
		s/(&deb_pr\(__LINE__)/# $1/g;
		print;
	}

For å ta bort utkommenteringen, filtrer fila gjennom dette scriptet:

	#!/usr/bin/perl

	while (<>) {
		s/# (&deb_pr\(__LINE__)/$1/g;
		print;
	}

Dette er bare nødvendig hvis det ligger strødd med debuggingsmeldinger på
steder som bør gå raskest mulig. Rutina sjekker verdien av
I<${main::Debug}>, hvis den er 0, returnerer den med en gang.

B<FIXME:> Mer pod seinere.

=head2 escape_dangeours_chars()

Brukes hvis man skal utføre en systemkommando og man får med kommandolinja
å gjøre. Eksempel:

	$cmd_line = escape_dangerous_chars("$cmd_line");
	system("$cmd_line");

Tegn som kan rote til denne kommandoen får en backslash foran seg.

=head2 file_mdate()

Returnerer tidspunktet fila sist ble modifisert i sekunder siden
S<1970-01-01 00:00:00 UTC>. Brukes hvis man skal skrive ting som "sist
oppdatert da og da".

=head2 get_cgivars()

Leser inn alle verdier sendt med GET eller POST requests og returnerer en
hash med verdiene. Fungerer på denne måten:

	%Opt = get_cgivars;
	my $Document = $Opt{doc};
	my $user_name = $Opt{username};

Alle verdiene ligger nå i de respektive variablene og kan (mis)brukes Vilt
& UhemmetZ<>(tm).

Funksjonen leser både 'I<&>' (ampersand) og 'I<;>' (semikolon) som
skilletegn i GET/POST, scripts bør sende 'I<;>' så det ikke blir kluss med
entities. Eksempel:

	index.cgi?doc=login;username=suttleif;pwd=hemmelig

B<FIXME:> Denne må utvides litt med flere Content-type'er.

=head2 get_countervalue()

Skriver ut verdien av en teller, angi filnavn. Fila skal inneholde et tall
i standard ASCII-format.

=head2 HTMLdie()

Tilsvarer F<die()> i standard Perl, men sender HTML-output så man ikke får
Internal Server Error. Funksjonen tar to parametere, I<$Msg> som havner i
E<lt>titleE<gt>E<lt>/titleE<gt> og E<lt>h1E<gt>E<lt>/h1E<gt>, og I<$Msg>
som blir skrevet ut som beskjed.

Hvis hverken I<${main::Utv}> eller I<${main::Debug}> er sann, skrives meldinga til
I<${suncgi::error_file}> og en standardmelding blir skrevet ut. Folk får ikke vite
mer enn de har godt av.

=head2 HTMLwarn()

En lightversjon av I<HTMLdie()>, den skriver kun til I<${suncgi::error_file}>.
Når det oppstår feil, men ikke trenger å rive ned hele systemet.
Brukes til småting som tellere som ikke virker og sånn.

B<FIXME:> Muligens det burde vært lagt inn at $suncgi::WebMaster fikk mail hver gang ting går på trynet.

=head2 increase_counter()

Øker telleren i en spesifisert fil med en.
Fila skal inneholde et tall i ASCII-format.
I tillegg lages en fil som heter F<{fil}.ip> som inneholder IP'en som brukeren er tilkoblet fra.
Hvis IP'en er den samme som i fila, oppdateres ikke telleren.
Hvis parameter 2 er I<!0>, øker telleren uanskvett.

=head2 log_access()

Logger aksess til en fil. Filnavnet skal være uten extension, rutina tar seg av det. I tillegg
øker den en teller i fila I<$Base.count> unntatt hvis parameter 2 != 0.

Forutsetter at I<${suncgi::log_dir}> er definert. Hvis ikke, settes den til
I<$suncgi::STD_LOGDIR>.

B<FIXME:> Skriv mer her.

=head2 print_doc()

Leser inn et dokument og konverterer det til HTML. Dette blir en av de
mest sentrale rutinene i en hjemmeside, i og med at det skal ta seg av
HTML-output'en. Istedenfor å fylle opp scriptene med HTML-koder, gjøres et
kall til F<print_doc()> som skriver ut sidene og genererer HTML.

Formatet på fila består av to deler: Header og HTML. De første linjene
består av ting som tittel, keywords, html-versjon, evt. refresh og så
videre. Her har vi et eksempel på en fil (Ingen space i begynnelsen på
hver linje, det er til ære for F<pod> at det er sånn):

 title Velkommen til snaddersida
 keywords snadder, stilig, kanontøfft, extremt, tjobing
 htmlversion html4strict
 author jeg@er.snill.edu

 <table width="<=docwidth>">
 	<tr>
 		<td colspan="2" align="center">
 			Han dæven sjteiki
 		</td>
 	</tr>
 	<tr>
 		<td>
 			Så tøfft dette var.
 		</td>
 		<td>
 			Nemlig. Mailadressen min er <=author>
 		</td>
 	</tr>
 </table>
 <=footer>

Rutina tar to parametere:

=over 4

=item I<$file_name> (nødvendig)

Fil som skal skrives ut. Denne har som standard extension F<*.shtml> .

=item I<$page_num> (valgfri)

Denne brukes hvis det er en "kjede" med dokumenter, og det skal lages en
"framover" og "bakover"-button.

Alt F<print_footer()> gjør, er å lete opp plassen i fila som ting skal
skrives ut fra. Grunnen til dette er at et dokument kan inneholde flere
dokumenter som separeres med E<lt>=pageE<gt>.

=back

B<FIXME:> Skriver mer på denne seinere. Og gjør greia ferdig. Support for
E<lt>=pageE<gt> må legges inn.

Alt kan legges inn i en fil:

	title Eksempel på datafil
	lang no
	ext html
	cvsroot :pserver:bruker@host.no:/cvsroot
	ftp ftp://black.host.no

	<=page index>
	<p>Bla bla bla

	<=page support>
	<p>Supportpreik

	<=page contact>
	<p>Kontaktpreik osv

=head2 p_footer()

Returnerer footer i HTML.
Brukes mest til debugging for å få validatorknapp og liste over moduler som brukes.

=head2 print_footer()

Skriver ut en footer med en E<lt>hrE<gt> først. Funksjonen tar disse
parameterne:

=over 4

=item I<$footer_width>

Bredden på footeren i pixels.
Hvis den ikke er definert, brukes I<${doc_width}>.
Og hvis den heller ikke er definert, brukes I<$suncgi::STD_DOCWIDTH> som default.

=item I<$footer_align>

Kan være I<left>, I<center> eller I<right>.
Brukes av E<lt>tableE<gt>.
Hvis udefinert, brukes I<$suncgi::doc_align>.
Hvis den ikke er definert, brukes I<$suncgi::STD_DOCALIGN>.

=item I<$no_vh>

I<0> eller udefinert: Skriver I<Valid HTML>-logoen nederst i høyre
hjørne. I<1>: Dropper den.

=item I<$no_end>

Tar ikke med E<lt>/bodyE<gt>E<lt>/htmlE<gt> på slutten hvis I<1>.

=back

=head2 print_header()

Parametere i print_header():

 1. Tittelen på dokumentet.
 2. Antall sekunder på hver refresh, 0 disabler refresh.
 3. Style sheet.
 4. Evt. scripts, havner mellom </style> og </head>.
 5. Evt. attributter i <body>, f.eks. " onLoad=\"myfunc()\"".
    Husk spacen i begynnelsen.
 6. HTML-versjon. F.eks. $suncgi::DTD_HTML4STRICT.
    Default er $suncgi::DTD_HTML4LOOSE.
 7. Språk. Default "no".
 8. no_body. 0 = Skriv <body>, 1 = Ikke skriv.

=head2 tab_print()

Skriver ut på samme måte som print, men setter inn I<$suncgi::Tabs> først på hver linje.
Det er for å få riktige innrykk.
Det forutsetter at I<$suncgi::Tabs> er oppdatert til enhver tid.

=head2 tab_str()

Fungerer på samme måte som I<tab_print()>, men returnerer en streng med innholdet istedenfor å skrive det ut.
Muligens det burde vært implementert i I<tab_print()> på en eller annen måte, men blir ikke det tungvint?

Vi lar det være sånn foreløpig.

=head2 Tabs()

Øker/minsker verdien av I<${suncgi::Tabs}>.
Den kan ta ett parameter, en verdi som er negativ eller positiv alt ettersom man skal fjerne eller legge til TAB'er.
Hvis man skriver

	Tabs(-2);

fjernes to spacer, hvis man skriver

	Tabs(5);

legges 5 TAB'er til.
Hvis ingen parametere spesifiseres, brukes 1 som default, altså en TAB legges til.

=head2 url_encode()

Konverterer en streng til format for bruk i URL'er.

=head2 sec_to_string()

Konverterer til leselig datoformat.

=head1 BUGS

print_doc() er ikke ferdig, ellers svinger det visst.

pod'en er muligens litt ute av sync med Tingenes Tilstand.
Men det er vel sånt som forventes.

=cut

#### End of file $Id: suncgi.pm,v 1.37.2.3 2003/10/13 06:16:05 sunny Exp $ ####
