package suncgi;

=head1 NAME

suncgi - HTML-rutiner for bruk i index.cgi

=head1 REVISION

S<$Id: suncgi.pm,v 1.6 2000/08/17 19:21:03 sunny Exp $>

=head1 SYNOPSIS

require suncgi;

=head1 DESCRIPTION

Inneholder en del rutiner som brukes av F<index.cgi>.
Inneholder generelle HTML-rutiner som brukes hele tiden.

=head1 COPYRIGHT

(C)opyright 1999-2000 Øyvind A. Holm E<lt>F<sunny256@mail.com>E<gt>

=cut

require 5.003;

=head1 VARIABLER

=head2 Nødvendige variabler

Når man bruker dette biblioteket, er det en del variabler som må defineres
under kjøring:

=over 4

=item I<${main::Url}>

URL'en til index.cgi.
Normalt sett blir denne satt til navnet på scriptet, for eksempel "I<index.cgi>" eller lignende.
Før ble I<${main::Url}> satt til full URL med F<httpZ<>://> og greier, men det gikk dårlig hvis ting for eksempel ble kjørt under F<httpsZ<>://>

=item I<${main::WebMaster}>

Emailadressen til den som eier dokumentet.
Denne blir ikke satt inn på copyrighter og sånn.

=item I<${main::error_file}>

Filnavn på en fil som er skrivbar av den som kjører scriptet (som oftest I<nobody>).
Alle feilmeldinger og warnings havner her.

=item I<${main::log_dir}>

Navn på directory der logging fra blant annet I<&log_access()> havner.
Brukeren I<nobody> (eller hva nå httpd måtte kjøre under) skal ha skrive/leseaksess der.

=back

NB: Disse må ikke være I<my>'et, de må være globale så de kan bli brukt av alle modulene.

=head2 Valgfrie variabler

Disse variablene er ikke nødvendige å definere, bare hvis man gidder:

=over 4

=item I<${main::doc_width}>

Bredden på dokumentet i pixels.
I<$STD_DOCWIDTH> som default.

=item I<${main::CharSet}>

Tegnsett som brukes.
Er I<$STD_CHARSET> som default, "I<ISO-8859-1>".

=item I<${main::BackGround}>

Bruker denne som default bakgrunn til I<&print_background()>.
Hvis den ikke er definert, brukes I<$STD_BACKGROUND>, en tom greie.

=item I<${main::Debug}>

Skriver ut en del debuggingsinfo.

=item I<${main::FONTB}>
=item I<${main::FONTE}>

Disse to definerer fontene som skal brukes.
I alle områder med tekst legges disse inn, for eksempel:

	$suncgi::tab_print("<h1>${FONTB}Dette er en snadderheader${FONTE}</h1>\n";

Normalt sett er $FONTB og $FONTE satt til disse verdiene sånn omtrent:

	$FONTB = '<font face="arial, helvetica">';
	$FONTE = '</font>';

Dette er som kjent bare lov i HTML når minst I<$DTD_HTML4LOOSE> brukes.

=item I<${main::Utv}>

Beslektet med I<${main::Debug}>, men hvis denne er definert, sitter man lokalt og tester.
Ikke helt klargjort hvordan disse to skal fungere i forhold til hverandre, men når sida ligger offentlig, skal hverken I<${main::Debug}> eller I<${main::Utv}>

=item I<${main::Border}>

Brukes mest til debugging. Setter I<border> i alle E<lt>tableE<gt>'es.

=back

=cut

###########################################################################
#### Variabler og moduler
###########################################################################

# use Time::Local; # curr_local_time() sin greie.

my $Tabs = "";

my $rcs_header = '$Header: /home/sunny/tmp/cvs/perllib/suncgi.pm,v 1.6 2000/08/17 19:21:03 sunny Exp $';
my $rcs_id = '$Id: suncgi.pm,v 1.6 2000/08/17 19:21:03 sunny Exp $';
my $rcs_date = '$Date: 2000/08/17 19:21:03 $';

# $cvs_* skal ut av sirkulasjon etterhvert. Foreløpig er de merket med "GD" (Gammel Drit) for å finne dem.
my $cvs_header = '$Header: /home/sunny/tmp/cvs/perllib/suncgi.pm,v 1.6 2000/08/17 19:21:03 sunny Exp $ GD';
my $cvs_id = '$Id: suncgi.pm,v 1.6 2000/08/17 19:21:03 sunny Exp $ GD';
my $cvs_date = '$Date: 2000/08/17 19:21:03 $ GD';

my $this_counter = "";

my $FALSE = 0;
my $TRUE = 1;

my $DTD_HTML4FRAMESET = qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Frameset//EN" "http://www.w3.org/TR/REC-html40/frameset.dtd">\n};
my $DTD_HTML4LOOSE = qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">\n};
my $DTD_HTML4STRICT = qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">\n};

my $STD_BACKGROUND = "";
my $STD_CHARSET = "ISO-8859-1"; # Hvis $main::CharSet ikke er definert
my $STD_DOCALIGN = "left"; # Standard align for dokumentet hvis align ikke er spesifisert
my $STD_DOCWIDTH = "500"; # Hvis ikke $main::doc_width er spesifisert
my $STD_HTMLDTD = $DTD_HTML4LOOSE;
my $STD_LOGDIR = "/usr/local/www/APACHE_LOG/default"; # FIXME: Litt skummelt kanskje. Mulig "/var/log/etellerannet" skulle vært istedenfor, men nøye då.

###########################################################################
#### Subrutiner
###########################################################################

=head1 SUBRUTINER

=cut

###########################################################################

=head2 &content_type()

Brukes omtrent bare av F<&print_header()>, men kan kalles
separat hvis det er speisa content-typer ute og går, som for eksempel
C<application/x-tar> og lignende.

=cut

sub content_type {
	my $ContType = shift;
	my $CharSet = $STD_CHARSET unless length(${main::CharSet});
	if (length($ContType)) {
		print "Content-Type: $ContType; charset=$CharSet\n\n" ;
	} else {
		&HTMLwarn("Intern feil: \$ContType ble ikke spesifisert til &content_type()");
	}
	# print "Content-Type: $ContType\n\n"; # Til ære for slappe servere som ikke har peiling
} # content_type()

###########################################################################

=head2 &curr_local_time()

Returnerer tidspunktet akkurat nå, lokal tid. Formatet er i henhold til S<ISO 8601>, dvs.
I<YYYY>-I<MM>-I<DD>TI<HH>:I<MM>:I<SS>+I<HHMM>

B<FIXME:> Finn en måte å returnere differansen mellom UTC og lokal tid.
Foreløpig droppes +0200 og sånn. Det liker vi I<ikke>. Ikke baser noen
programmer på formatet foreløpig.

=cut

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

###########################################################################

=head2 &curr_utc_time()

Returnerer tidspunktet akkurat nå i UTC. Brukes av blant annet
F<&print_header()> til å sette rett tidspunkt inn i headeren. Formatet på
datoen er i henhold til S<ISO 8601>, dvs.
I<YYYY>-I<MM>-I<DD>TI<HH>:I<MM>:I<SS>Z

=cut

sub curr_utc_time {
	my @TA = gmtime(time);
	my $UtcTime = sprintf("%04u-%02u-%02uT%02u:%02u:%02uZ", $TA[5]+1900, $TA[4]+1, $TA[3], $TA[2], $TA[1], $TA[0]);
	# &deb_pr(__LINE__ . ": curr_utc_time(): Returnerer \"$UtcTime\"");
	return($UtcTime);
} # curr_utc_time()

###########################################################################

=head2 &deb_pr()

En debuggingsrutine som kjøres hvis ${main::Debug} ikke er 0. Den
forlanger at ${main::error_file} er definert, det skal være en fil der
all debuggingsinformasjonen skrives til.

For at debugging skal bli lettere, kan man slenge denne inn på enkelte
steder. Eksempel:

	# &deb_pr(__LINE__ . ": sort_dir(): Det er $Elements elementer her.");

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

=cut

sub deb_pr {
	return unless ${main::Debug};
	my $Msg = shift;
	my $err_msg = "";
	if (-e ${main::debug_file}) {
		open(DebugFP, "+<${main::debug_file}") || ($err_msg = "Klarte ikke å åpne debugfila for lesing/skriving");
	} else {
		open(DebugFP, ">${main::debug_file}") || ($err_msg = "Klarte ikke å lage debugfila");
	}
	unless(length($err_msg)) {
		flock(DebugFP, LOCK_EX);
		seek(DebugFP, 0, 2) || ($err_msg = "Kan ikke seek'e til slutten av debugfila");
	}
	if (length($err_msg)) {
		print <<END;
Content-type: text/html

${DTD_HTML4STRICT}
<html>
	<!-- ${rcs_id} -->
	<head>
		<title>Intern feil i deb_pr()</title>
	</head>
	<body>
		<h1>Intern feil i deb_pr()</h1>
		<p>${err_msg}: <samp>$!</samp>
		<p>Litt info:
		<p>\${main::Debug} = "${main::Debug}"
		<br>\${main::debug_file} = "${main::debug_file}"
		<br>\${main::error_file} = "${main::error_file}"
	</body>
</html>
END
		exit();
	}
	print(DebugFP "$$ $Msg\n");
	close(DebugFP);
} # deb_pr()

###########################################################################

=head2 &escape_dangeours_chars()

Brukes hvis man skal utføre en systemkommando og man får med kommandolinja
å gjøre. Eksempel:

	$cmd_line = &escape_dangerous_chars("$cmd_line");
	system("$cmd_line");

Tegn som kan rote til denne kommandoen får en backslash foran seg.

=cut

sub escape_dangerous_chars {
	my $string = shift;

	$string =~ s/([;\\<>\*\|`&\$!#\(\)\[\]\{\}'"])/\\$1/g;
	return $string;
} # escape_dangerous_chars()

###########################################################################

=head2 &file_mdate()

Returnerer tidspunktet fila sist ble modifisert i sekunder siden
S<1970-01-01 00:00:00 UTC>. Brukes hvis man skal skrive ting som "sist
oppdatert da og da".

=cut

sub file_mdate {
	my($FileName) = @_;
	my(@TA);
	@StatArray = stat($FileName);
	return($StatArray[9]);
} # file_mdate()

###########################################################################

=head2 &get_cgivars()

Leser inn alle verdier sendt med GET eller POST requests og returnerer en
hash med verdiene. Fungerer på denne måten:

	%Opt = &get_cgivars;
	my $Document = $Opt{doc};
	my $user_name = $Opt{username};

Alle verdiene ligger nå i de respektive variablene og kan (mis)brukes Vilt
& UhemmetZ<>(tm).

Funksjonen leser både 'I<&>' (ampersand) og 'I<;>' (semikolon) som
skilletegn i GET/POST, scripts bør sende 'I<;>' så det ikke blir kluss med
entities. Eksempel:

	index.cgi?doc=login;username=suttleif;pwd=hemmelig

B<FIXME:> Denne må utvides litt med flere Content-type'er.

=cut

sub get_cgivars {
	local($in, %in);
	local($name, $value);

	my $has_args = ($#ARGV > -1) ? $TRUE : $FALSE;
	if ($has_args) {
		$in = $ARGV[0];
	} elsif (($ENV{'REQUEST_METHOD'} eq 'GET') ||
	         ($ENV{'REQUEST_METHOD'} eq 'HEAD')) {
		$in = $ENV{'QUERY_STRING'};
	} elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
		if ($ENV{'CONTENT_TYPE'} =~ m#^application/x-www-form-urlencoded$#i) {
			length($ENV{'CONTENT_LENGTH'}) || &HTMLdie("Ingen Content-Length vedlagt POST-foresp&oslash;rselen.");
			read(STDIN, $in, $ENV{'CONTENT_LENGTH'});
		} else {
			&HTMLdie("Usupportert Content-Type: \"$ENV{'CONTENT_TYPE'}\"");
		}
	} else {
		&HTMLdie("Programmet ble kalt med ukjent REQUEST_METHOD: \"$ENV{'REQUEST_METHOD'}\"");
	}
	foreach (split("[&;]", $in)) {
		s/\+/ /g;
		($name, $value) = split('=', $_, 2);
		$name =~ s/%(..)/chr(hex($1))/ge;
		$value =~ s/%(..)/chr(hex($1))/ge;
		$in{$name} .= "\0" if defined($in{$name});
		$in{$name} .= $value;
		# Den under her er veldig grei å ha upåvirket av perldeboff(1).
		&deb_pr (__LINE__ . ": get_cgivars(): $name = \"$value\"");
	}
	return %in;
} # get_cgivars()

###########################################################################

=head2 &get_counter()

Skriver ut verdien av en teller, angi filnavn. Fila skal inneholde et tall
i standard ASCII-format.

=cut

# FIXME: Skal my TmpFP brukes?
sub get_countervalue {
	my $counter_file = shift;
	my $counter_value = 0;
	# &deb_pr(__LINE__ . ": get_countervalue(): Åpner $counter_file for lesing+flock");
	open(TmpFP, "<$counter_file") || (&HTMLwarn("$counter_file i get_counter(): Kan ikke åpne fila for lesing: $!"), return(0));
	flock(TmpFP, LOCK_EX);
	$counter_value = <TmpFP>;
	chomp($counter_value);
	close(TmpFP);
	# &deb_pr(__LINE__ . ": get_countervalue(): $counter_file: Fila er lukket, returnerer fra subrutina med \"$counter_value\"");
	return $counter_value;
} # get_countervalue()

###########################################################################

=head2 &HTMLdie()

Tilsvarer F<die()> i standard Perl, men sender HTML-output så man ikke får
Internal Server Error. Funksjonen tar to parametere, I<$Msg> som havner i
E<lt>titleE<gt>E<lt>/titleE<gt> og E<lt>h1E<gt>E<lt>/h1E<gt>, og I<$Msg>
som blir skrevet ut som beskjed.

Hvis hverken I<${main::Utv}> eller I<${main::Debug}> er sann, skrives meldinga til
I<${main::error_file}> og en standardmelding blir skrevet ut. Folk får ikke vite
mer enn de har godt av.

=cut

sub HTMLdie {
	my($Msg,$Title) = @_;
	my $curr_utc = &curr_utc_time;
	my $msg_str;

	# &deb_pr(__LINE__ . ": HDIE: $Msg");
	$Title || ($Title = "Intern feil");
	if (!${main::Debug} && !${main::Utv}) {
		$msg_str = "<p>En intern feil har oppst&aring;tt. Feilen er loggf&oslash;rt, og vil bli fikset snart.";
	} else {
		chomp($msg_str = $Msg);
	}
	my $CharSet = $STD_CHARSET unless length($CharSet);
	print <<END;
Content-type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">

<html lang="no">
	<!-- $rcs_id -->
	<!-- ${main::rcs_id} -->
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
		<meta http-equiv="Content-Type" content="text/html; charset=$CharSet">
		<meta name="author" content="${main::WebMaster}">
		<meta name="copyright" content="&copy; &Oslash;yvind A. Holm">
		<meta name="description" content="CGI error">
		<meta name="date" content="$curr_utc">
		<link rev="made" href="mailto:${main::WebMaster}">
	</head>
	<body>
		<h1>$Title</h1>
		<blockquote>
			$msg_str
		</blockquote>
	</body>
</html>
END
	if (length(${main::error_file})) {
		system("touch ${main::error_file}") unless (-e ${main::error_file});
		open(ErrorFP, "+<${main::error_file}") or exit;
		flock(ErrorFP, LOCK_EX);
		seek(ErrorFP, 0, 2) or exit;
		$Msg =~ s/\\/\\\\/g;
		$Msg =~ s/\n/\\n/g;
		$Msg =~ s/\t/\\t/g;
		printf(ErrorFP "%s HDIE %s\n", &curr_utc_time, $Msg);
		close(ErrorFP);
	}
	exit;
} # HTMLdie()

###########################################################################

=head2 &HTMLwarn()

En lightversjon av I<&HTMLdie()>, den skriver kun til
I<${main::error_file}>. Når det oppstår feil, men ikke trenger å rive ned
hele systemet. Brukes til småting som tellere som ikke virker og sånn.

B<FIXME:> Muligens det burde vært lagt inn at ${main::WebMaster} fikk mail om
hver gang ting går på trynet.

=cut

sub HTMLwarn {
	local($Msg) = shift;
	my $curr_utc = &curr_utc_time;

	# &deb_pr(__LINE__ . ": WARN: $Msg");
	# Gjør det så stille og rolig som mulig.
	if (${main::Utv} || ${main::Debug}) {
		&print_header("CGI warning");
		&tab_print("<p><font size=\"+1\"><b>HTMLwarn(): $Msg</font></n>\n");
	}
	if (-e ${main::error_file}) {
		open(ErrorFP, ">>${main::error_file}") or return;
	} else {
		open(ErrorFP, ">${main::error_file}") or return;
	}
	$Msg =~ s/\\/\\\\/g;
	$Msg =~ s/\n/\\n/g;
	$Msg =~ s/\t/\\t/g;
	print(ErrorFP "$curr_utc WARN $Msg\n");
	close(ErrorFP);
} # HTMLwarn()

###########################################################################

=head2 &increase_counter()

Øker telleren i en spesifisert fil med en. Fila skal inneholde et tall i
ASCII-format. I tillegg lages en fil som heter F<{fil}.ip> som inneholder
IP'en som brukeren er tilkoblet fra. Hvis IP'en er den samme som i fila,
oppdateres ikke telleren.

=cut

# FIXME: my TmpFP?
sub increase_counter {
	my $counter_file = shift;
	my $ip_file = "$counter_file.ip";
	my $user_ip = $ENV{REMOTE_ADDR};
	system("touch $counter_file") unless (-e $counter_file);
	system("touch $ip_file") unless (-e $ip_file);
	open(TmpFP, "+<$ip_file") || (&HTMLwarn("$ip_file i increase_counter(): Kan ikke åpne fila for lesing og skriving: $!"), return(0));
	flock(TmpFP, LOCK_EX);
	$last_ip = <TmpFP>;
	chomp($last_ip);
	my $new_ip = ($last_ip eq $user_ip) ? $FALSE : $TRUE;
	if ($new_ip) {
		seek(TmpFP, 0, 0) || (&HTMLwarn("$ip_file: Kan ikke gå til begynnelsen av fila: $!"), close(TmpFP), return(0));
		print(TmpFP "$user_ip\n");
	}
	open(TmpFP, "+<$counter_file") || (&HTMLwarn("$counter_file i increase_counter(): Kan ikke åpne fila for lesing og skriving: $!"), return(0));
	flock(TmpFP, LOCK_EX);
	my $counter_value = <TmpFP>;
	if ($new_ip) {
		seek(TmpFP, 0, 0) || (&HTMLwarn("$counter_file: Kan ikke gå til begynnelsen av fila: $!"), close(TmpFP), return(0));
		printf(TmpFP "%u\n", $counter_value+1) if ($user_ip ne $last_ip);
	}
	close(TmpFP);
	return($counter_value + ($new_ip ? 1 : 0));
} # increase_counter()

###########################################################################

=head2 &log_access()

Logger aksess til en fil. Filnavnet skal være uten extension, rutina tar seg av det. I tillegg
øker den en teller i fila I<$Base.count> unntatt hvis parameter 2 != 0.

Forutsetter at I<${main::log_dir}> er definert. Hvis ikke, settes den til
I<$STD_LOGDIR>.

B<FIXME:> Skriv mer her.

=cut

sub log_access {
	my ($Base, $no_counter) = @_;
	my $log_dir = length(${main::log_dir}) ? ${main::log_dir} : $STD_LOGDIR;
	my $File = "$log_dir/$Base.log";
	my $Countfile = "$log_dir/$Base.count";
	system("touch $File") unless (-e $File);
	open(LogFP, "+<$File") || (&HTMLwarn("$File: Can't open access log for read/write: $!"), return);
	flock(LogFP, LOCK_EX);
	seek(LogFP, 0, 2) || (&HTMLwarn("$Countfile: Can't seek to EOF: $!"), close(LogFP), return);
	my $Agent = $ENV{HTTP_USER_AGENT};
	$Agent =~ s/\n/\\n/g; # Vet aldri hva som kommer
	printf(LogFP "%u\t%s\t%s\t%s\t%s\n", time, $ENV{REMOTE_ADDR}, $ENV{REMOTE_HOST}, $ENV{HTTP_REFERER}, $Agent);
	close(LogFP);
	$this_counter = &increase_counter($Countfile) unless $no_counter;
} # log_access()

###########################################################################

=head2 &print_doc()

Leser inn et dokument og konverterer det til HTML. Dette blir en av de
mest sentrale rutinene i en hjemmeside, i og med at det skal ta seg av
HTML-output'en. Istedenfor å fylle opp scriptene med HTML-koder, gjøres et
kall til F<&print_doc()> som skriver ut sidene og genererer HTML.

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

Alt F<&print_footer()> gjør, er å lete opp plassen i fila som ting skal
skrives ut fra. Grunnen til dette er at et dokument kan inneholde flere
dokumenter som separeres med E<lt>=pageE<gt>.

=back

B<FIXME:> Skriver mer på denne seinere. Og gjør greia ferdig. Support for
<=page> må legges inn.

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

=cut

sub print_doc {
	my ($file_name, $page_num) = @_;
	my $in_header = $TRUE;

	open(FromFP, "<$file_name") || &HTMLdie("$file_name: Kan ikke åpne fila for lesing: $!");
	LINE: while (<FromFP>) {
		chomp;
		next LINE if /^#\s/;
		last unless length;
		if (/^(\S+)\s+(.*)$/) {
			$doc_val{$1} = $2;
		} else {
			&HTMLwarn("$file_name: Ugyldig headerinfo i linje $.: \"$_\"");
		}
	}
	$doc_val{title} || &HTMLwarn("$file_name: Mangler title");
	$doc_val{owner} || &HTMLwarn("$file_name: Mangler owner");
	$doc_val{lang} || &HTMLwarn("$file_name: Mangler lang");
	$doc_val{id} || &HTMLwarn("$file_name: Mangler id");
	# $doc_val{} || &HTMLwarn("$file_name: Mangler ");
	if (${main::Debug}) {
		&print_header("er i print_doc"); # debug
		while (($act_name,$act_time) = each %doc_val) {
			print("<br>\"$act_name\"\t\"$act_time\"\n");
		}
	}
	# my ($DocTitle, $html_version, $Language, $user_background, $Refresh, $no_body, $Description, $Keywords, @StyleSheet) = @_;
	&print_header($doc_val{title}, "", $doc_val{lang}, $doc_val{background}, $doc_val{refresh}, $doc_val{no_body}, $doc_val{description}, $doc_val{keywords});
	while (<FromFP>) {
		chomp;
		&tab_print("$_\n");
	}
	print <<END;
	</body>
</html>
END
	close(FromFP);
} # print_doc()

###########################################################################

=head2 &print_footer()

Skriver ut en footer med en E<lt>hrE<gt> først. Funksjonen tar disse
parameterne:

=over 4

=item I<$footer_width>

Bredden på footeren i pixels. Hvis den ikke er definert, brukes
I<${main::doc_width}>. Og hvis den heller ikke er definert, brukes
I<$STD_DOCWIDTH> som default.

=item I<$footer_align>

Kan være I<left>, I<center> eller I<right>. Brukes av E<lt>tableE<gt>.
Hvis udefinert, brukes I<${main::doc_align}>. Hvis den ikke er definert,
brukes I<$STD_DOCALIGN>.

=item I<$no_vh>

I<$FALSE> eller udefinert: Skriver I<Valid HTML>-logoen nederst i høyre
hjørne. I<$TRUE>: Dropper den.

=item I<$no_end>

Tar ikke med E<lt>/bodyE<gt>E<lt>/htmlE<gt> på slutten hvis I<$TRUE>.

=back

=cut

sub print_footer {
	my ($footer_width, $footer_align, $no_vh, $no_end) = @_;

	# &deb_pr(__LINE__ . ": Går inn i print_footer(\"$footer_width\", \"$footer_align\", \"$no_vh\", \"$no_end\")");
	unless (length($footer_width)) {
		$footer_width = length(${main::doc_width}) ? ${main::doc_width} : $STD_DOCWIDTH;
	}
	unless (length($footer_align)) {
		$footer_align = length(${main::doc_align}) ? ${main::doc_align} : $STD_DOCALIGN;
	}
	$no_vh = $FALSE unless length($no_vh);
	$no_end = $FALSE unless length($no_end);
	my $rcs_str = ${main::rcs_date}; # FIXME: Er ikke nødvendigvis denne som skal brukes.
	$rcs_str =~ s/ /&nbsp;/g;
	my $vh_str = $no_vh ? "&nbsp;" : "<a href=\"http://validator.w3.org/check/referer;ss\"><img src=\"${main::GrafDir}/vh40.gif\" height=\"31\" width=\"88\" align=\"right\" border=\"0\" alt=\"Valid HTML 4.0!\"></a>";
	my $count_str = length($this_counter) ? "Du er bes&oslash;kende nummer $this_counter p&aring; denne siden." : "&nbsp;";

	# FIXME: Hardkoding av URL her pga av at ${main::Url} har skifta navn.
	# FIXME: I resten av HTML'en er det brukt <div align="center">.
	&tab_print(<<END);
<table width="$footer_width" cellpadding="0" cellspacing="0" border="${main::Border}" align="$footer_align">
	<tr>
		<td colspan="3">
			<hr>
		</td>
	</tr>
	<tr>
		<td align="center">
			<table cellpadding="0" cellspacing="0" border="${main::Border}">
				<tr>
					<td align="center">
						${main::FONTB}<small>$rcs_str</small>${main::FONTE}
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
		&Tabs(-2);
		&tab_print(<<END);
	</body>
</html>
END
	}
	exit; # FIXME: Sikker på det?
} # print_footer()

###########################################################################

# print_header() før henting fra BA-Snakk
# begin-base64 664 -
# H4sIALwy3zgCA41Y2W7bSBZ9Nr/imk7cEmBJveTJltXtRUmMOAtsBZkeCBBK
# YomiSRU1VUV5hMT9t+5v6Mc5t4qUKNkJxghssuru99yFOZ1JEf1KhwudKDvi
# F6kbzSC4FrHUJBW9Hby/ftXyF5TQTKpZnkVkk4y+/HbxkyGhxnIqskTFbboE
# gxWaosQYGSyEFnNppVbyOAhO8yUkvMJDYuWcrrovLvPJILGZ7AXBpbRk8jmZ
# VGSUKAVN/W5me5bv+93Y9txrZ/NekzOz82wE4SbJFc7fLpMshSGXg8uNzLEu
# UmkgdizjlVIyM1K16ZxPtbNlcDlyrt4Obq4uBj3mDCI4VmT2iERmzWMQ3Had
# FfuXHy8Gf37qu9jQp8/n11cXFLY6HQSk02G17uJV+2caaKFMYmGYyDqd/oew
# ByHhzNrFv7u9407n/v6+ff9bO9dxZ3DTuelftNiZVz93sjw3sh3ZKHTe1t29
# FioukJ4eZ0lFJs0jSYtHsjmN89RYwXFmx2diqVzSnNUsmDLwOoFturVgFjoC
# dZQEoAtVHh5RhEwggGSSINjrrplO+bZuRWGkHo3FJI11XqgIV+cCzwVytxN0
# hoUlZ0hhY8gyi0Klls8UTYWOJTWkipGSNHCvCnaTzDKw3Lw5b01zPReWwoOp
# +wmbRzQH52yZGJL/tVJx3ll+lqRBu3G3iL/dLWT8LU6m3xYqbvIVe4V/4ySL
# ZLvmxY2camlmsP5MWZHBbZnCG3DMYQDHkIOpPdUmZmAFsAVxIlvyP0Wy7K2J
# atJVPhrn0cpj0sAIAI+t2cfd67Pr237vCIHSyZKRmabSJ4pZXI4QrjZ90iK1
# iUmdv0HkIzmXOpVZEu8y7ET+qIzizGu3/i6TcSxNwFWmcgTyTiyFmehkYVux
# lomLlq67cSn9tS+vrVI19tHVlPeCi6qCG8fHGdXCrV1paesi38nVfa4jA3nV
# 4xNGhJtVLP/WktJ8PhdGoqNIbSmPEYEICUVlAV8buX/c2lUmb2dScoM401qs
# HCXqd7u9GKYjw4TA53n39dW/3vePe0jwKo7JiJTDZSXanSZhEXZF80dvCirN
# ZAUuFYkllT1OSyU5lwXizWQO22MZgX7+CDnmkbMfpAKnWQKUqchb1B8MaN0n
# PbBdoqB3mThdMkERyzb1cSIzjxM0I/XPClgCGnGzlMoWkn3MuJAcK3cF5X2F
# Gskuw8iYY+dFuNNAcIwQwfPBF7aspqPWvR2cLDsxh1Ju/VwWkYiBMAfL191y
# gET5pNHseUlTbiwx6WTuoIoyttwKdIkc6E/vYDgnJzALaZJpArddPjcJYbTN
# RIQOF99BAMLhc2+TCEJB7npti7v/Xc7dLo/NIyOCWxP+TAobBKYYU33A0ddg
# b76ixnoCHdHWEMFr1WTxuNPpcFJ2DTyVFY6nWpHgrQL1EdUg2aRT+mN04nSz
# 6gLZtgOEB+eHk0LrUWEnI4uDRrOkOofwW6tBEHZdKwmri7U9uC7PSrM8ffVG
# v4N1p1mdDsOyWw1DmuQKWLY4q1hwWOiMD77ORaKOjz/r7GEY9oZqaIc2pGMK
# KzPYT6+PkWdnjbXnzY1iBRxBWlrebOt8tz59Tv7FTOhbQAD+3GJCX7w9u7nt
# D6hQmTRmrbOkqoLmUmmcVcalfdoI3SR7aXqYcBVXlWJnqR9ysKc6HYbekOYm
# X1dRKbWSALSPliL7mkQPLKTb7X+4rKzv7rdaVKegVqsXgCDYS6aAnkciCkbB
# AOBx74AOIzkeLXRjNLq++tAfjahN4TH9me/T9naG8kJHvPvHlUO2JFTSsC6P
# o1V7beO2Ajqu4GP1NvTu7TnxjXConNGwooiPt3VuMR1RHSvurayD8q1eS8Ow
# +R0rEY+h8gZgOhRa4emBeIi4eOx49AvfBt+N0naEjmltrlNQ4qVRJW6npJs+
# A7vHtUyXhcBV98bduYQ/c4z0O6Sen128e3Pz8fOHS2835/zH2h0qnljwF3WG
# z+w0LzqJ59p70iJow8543pGIMmN0Ml+9gzC3O68l4CnJrrCT7xgQT/Is16x9
# S0Kl+2E7z8/2uGeUPxfWA/KDgs554viZ7YcVTymsNzx2VDG1GECYgbx9Ys/A
# 8BC/MzPHfP/HaTnwvfZNzZKSIZk2SpqKaMvcp9g4qUifdfiA6rF/TuKTAPxY
# WuB/HZbNdmRXC9kILVbmDheoKwxXNmuU1+vW4bt+UCGb5y2+cdbMruudBMG6
# 7QabXll2wTIUemJGVSMsb/zRpjUeDsTYNH5tntABuW8PrCtc1EEt1e8x+rEF
# JrxcYD+TP+HT03+38HoVoy9ineZFJcaKxJvTAF+kbqXBx6tZKQeNF6wIB7wf
# b9YuXjN59912DZ9BMAE273Xd92dv3Vy6/oPUXe3O2PDCx701QNw3I2+TgBOa
# YG4ZaU+rARayoNoYr43PUBR2luuanCqqX+T4vTDY0x48ezmS67yTfLHSSTyz
# NfZDPjyhw48mE2Z2slomaDdnbXqbZ/Nw45AXEG2Wm7oFtZ3nKYuwcou2tu94
# 4ixRKb6aEKk5unZIM+wk/JxkNj9+1juGSJWbkHeFrt/jGdnoNi6yE+NXiZCL
# 20xEhuTXdrCTCmO/MPzRHKSYzKixtaV9rUYi9oaX5qWBsCMPGPwZNX3nqVvR
# cWb8H0pbHtne6gra1fh1Grodh7VyMFZzq5qvNdtK+qr8mQFXNd8eggeo2vl/
# nf8BVLmUwu8RAAA=
# ====

# FIXME: Mer pod under her.

=head2 &print_header()

Parametere i print_header():

 1. Tittelen på dokumentet.
 2. Antall sekunder på hver refresh, 0 disabler refresh.
 3. Style sheet.
 4. Evt. scripts, havner mellom </style> og </head>.
 5. Evt. attributter i <body>, f.eks. " onLoad=\"myfunc()\"".
    Husk spacen i begynnelsen.
 6. HTML-versjon. F.eks. $DTD_HTML4STRICT. Default er $DTD_HTML4LOOSE.
 7. Språk. Default "no".

=cut

sub print_header {
	local($DocTitle, $Refresh, $style_sheet, $head_script, $body_attr, $html_version, $doc_lang) = @_;
	# &deb_pr(__LINE__ . ": Går inn i print_header(), \$DocTitle=\"$DocTitle\"");
	if (${main::header_done}) {
		# &deb_pr(__LINE__ . "Yo! print_header() ble kjørt selv om \${main::header_done} = ${main::header_done}");
		print("\n<!-- debug: print_header($DocTitle) selv om \${main::header_done} -->\n");
		return;
	}
	$doc_lang = "no" unless length($doc_lang);
	$html_version = $DTD_HTML4LOOSE unless length($html_version);
	&content_type("text/html");
	my $DocumentTime = &curr_utc_time();
	$RefreshStr = (length($Refresh)) ? qq{<meta http-equiv="refresh" content="$Refresh" url="${main::Url}">} : "";
	if (length(${main::user_background})) {
		if (${main::user_background} =~ /\.(jpg|jpeg|png|gif)$/i) {
			$BodyStr = "\t</head>\n\t<body background=\"${main::user_background}\"$body_attr>\n";
			$BackgroundStr = "white";
		} else {
			$BackgroundStr = ${main::user_background};
			$BodyStr = qq{</head>\n<body bgcolor="$BackgroundStr"$body_attr>\n};
		}
	} else {
		$BackgroundStr = "white";
		$BodyStr = qq{</head>\n<body bgcolor="$BackgroundStr"$body_attr>\n};
	}
	print $html_version;
	print "\n<html lang=\"$doc_lang\">\n";
	&Tabs(1);
	chomp($head_script);
	&tab_print(<<END_PHH);
<!-- ${main::rcs_id} -->
<!-- $rcs_id -->
<head>
	<title>$DocTitle</title>
	<meta http-equiv="Content-Type" content="text/html; charset=$CharSet">
	$RefreshStr
	<meta name="author" content="&Oslash;yvind A. Holm">
	<meta name="copyright" content="&copy; &Oslash;yvind A. Holm">
	<meta name="date" content="$DocumentTime">
	<link rev="made" href="mailto:${main::WebMaster}">
END_PHH
	&Tabs(1);
	# print ("Tabs = $Tabs\n");
	&tab_print(<<END);
$style_sheet
$head_script
END
	&Tabs(-1);
	# chomp($head_script);
	&tab_print($BodyStr);
	&Tabs(1);
	${main::header_done} = ${main::TRUE};
} # print_header()


###########################################################################

=head2 &tab_print()

Skriver ut på samme måte som print, men setter inn I<$Tabs> først på
hver linje. Det er for å få riktige innrykk. Det forutsetter at
I<$Tabs> er oppdatert til enhver tid.

B<FIXME:> Legg inn konvertering av tegn > 0x7f til entities.

=cut

sub tab_print {
	my @Txt = @_;

	foreach (@Txt) {
		s/^(.*)/${Tabs}$1/gm;
		s/([\x7f-\xff])/sprintf("&#%u;", ord($1))/ge;
		print "$_";
	}
} # tab_print()

###########################################################################

=head2 &tab_str()

Fungerer på samme måte som I<&tab_print()>, men returnerer en streng med
innholdet istedenfor å skrive det ut. Mulignes det burde vært implementert
i I<&tab_print()> på en eller annen måte, men blir ikke det tungvint?

Vi lar det være sånn foreløpig.

B<FIXME:> Legg inn konvertering av tegn > 0x7f til entities her også.

=cut

sub tab_str {
	my @Txt = @_;
	my $RetVal = "";

	foreach (@Txt) {
		s/^(.*)/${Tabs}$1/gm;
		$RetVal .= "$_";
	}
	return $RetVal;
} # tab_str()

###########################################################################

=head2 &Tabs()

Øker/minsker verdien av I<${suncgi::Tabs}>.
Den kan ta ett parameter, en verdi som er negativ eller positiv alt ettersom man skal fjerne eller legge til TAB'er.
Hvis man skriver

	&Tabs(-2);

fjernes to spacer, hvis man skriver

	&Tabs(5);

legges 5 TAB'er til. Hvis ingen parametere spesifiseres, brukes 1 som default, altså en TAB legges til.

=cut

sub Tabs {
	my $Value = shift;

	# FIXME: Finpussing seinere.
	if ($Value > 0) {
		for (1..$Value) {
			$Tabs =~ s/(.*)/$1\t/;
		}
	} elsif ($Value < 0) {
		$Value = 0 - $Value;
		for (1..$Value) {
			$Tabs =~ s/^(.*)\t/$1/;
		}
	} else {
		&HTMLwarn("Intern feil: Tabs() ble kalt med \$Value = 0");
	}
} # Tabs()

###########################################################################

=head1 BUGS

Strukturen er ikke helt klar enda, det blir nok mange forandringer underveis.

Tror ikke tellerfunksjonene er helt i rute.

=cut

1;

__END__

#### End of file $Id: suncgi.pm,v 1.6 2000/08/17 19:21:03 sunny Exp $ ####
