package tricgi;

=head1 NAME

tricgi - HTML-rutiner for bruk i index.cgi

=head1 REVISION

S<$Header: /home/sunny/tmp/cvs/perllib/tricgi.pm,v 1.1 1999/03/16 00:13:05 sunny Exp $>

=head1 SYNOPSIS

require tricgi;

=head1 DESCRIPTION

Inneholder en del rutiner som brukes av F<index.cgi>. Inneholder generelle
HTML-rutiner som brukes hele tiden.

=head1 COPYRIGHT

(C)opyright 1999 TriTech A/S E<lt>F<http://www.tritech.no>E<gt>

Dette programmet er eiendom tilhørende TriTech A/S og skal
I<IKKE UNDER NOEN OMSTENDIGHETER> kopieres videre til personer
utenfor firmaet.

This program is property of TriTech A/S and shall
I<NOT UNDER ANY CIRCUMSTANCES> be copied to any person outside
the company.

=cut

require 5.003;

=head1 VARIABLER

Når man bruker dette biblioteket, er det en del variabler som må defineres
under kjøring:

=over 4

=item I<${main::Url}>

URL'en til index.cgi. Normalt sett blir denne satt til navnet på scriptet,
for eksempel "I<index.cgi>" eller lignende. Før ble I<${main::Url}> satt til full
URL med F<httpZ<>://> og greier, men det gikk dårlig hvis ting for
eksempel ble kjørt under F<httpsZ<>://>

=item I<${main::doc_width}>

Bredden på dokumentet i pixels. 500 som default.

=item I<$WebMaster>

Emailadressen til den som eier dokumentet. Denne blir ikke satt inn på
copyrighter og sånn, der er det F<tritech@tritech.no> som hersker.

=back

=cut

###########################################################################
#### Variabler
###########################################################################

$cvs_id = '$Id: tricgi.pm,v 1.1 1999/03/16 00:13:05 sunny Exp $';
$cvs_date = '$Date: 1999/03/16 00:13:05 $';
# $tricgi::sendmail_prog = "/bin/mail"; # Brukes til å sende meldinger til $WebMaster om ting som ikke fungerer som det skal.

my $DTD_HTML4FRAMESET = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Frameset//EN\"\n\"http://www.w3.org/TR/REC-html40/frameset.dtd\">\n";
my $DTD_HTML4LOOSE = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n\"http://www.w3.org/TR/REC-html40/loose.dtd\">\n";
my $DTD_HTML4STRICT = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\"\n\"http://www.w3.org/TR/REC-html40/strict.dtd\">\n";
my $STD_CHARSET = "ISO-8859-1";
my $FALSE = 0;
my $TRUE = 1;

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
	my $CharSet = $STD_CHARSET unless length($CharSet);
	print "Content-Type: $ContType; charset=$CharSet\n\n" if length($ContType);
	# print "Content-Type: $ContType\n\n"; # Til ære for slappe servere som ikke har peiling
} # content_type()

###########################################################################

=head2 &curr_utc_time()

Returnerer tidspunktet akkurat nå, brukes av blant annet
F<&print_header()> til å sette rett tidspunkt inn i headeren. Formatet på
datoen er i henhold til S<ISO 8601>, dvs.
I<YYYY>-I<MM>-I<DD>TI<HH>:I<MM>:I<SS>Z

=cut

sub curr_utc_time {
	my @TA = gmtime(time);
	my $UtcTime = sprintf("%04u-%02u-%02uT%02u:%02u:%02uZ", $TA[5]+1900, $TA[4]+1, $TA[3], $TA[2], $TA[1], $TA[0]);
	return($UtcTime);
} # curr_utc_time()

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
	}
	return %in;
} # get_cgivars()

###########################################################################

=head2 &HTMLdie()

Tilsvarer F<die()> i standard Perl, men sender HTML-output så man ikke får
Internal Server Error. Funksjonen tar to parametere, I<$Msg> som havner i
E<lt>titleE<gt>E<lt>/titleE<gt> og E<lt>h1E<gt>E<lt>/h1E<gt>, og I<$Msg>
som blir skrevet ut som beskjed.

Hvis hverken I<$Utv> eller I<$Debug> er sann, skrives meldinga til
I<$error_file> og en standardmelding blir skrevet ut. Folk får ikke vite
mer enn de har godt av.

=cut

sub HTMLdie {
	my($Msg,$Title) = @_;
	my $curr_utc = &curr_utc_time;
	my $msg_str;

	$Title || ($Title = "Intern feil");
	if (!$Debug && !$Utv) {
		$msg_str = <<END;
			<p>En intern feil har oppstått. Feilen er loggført, og vil bli
			fikset snart.
END
	} else {
		$msg_str = $Msg;
	}
	my $CharSet = $STD_CHARSET unless length($CharSet);
	print <<END;
Content-type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN"
"http://www.w3.org/TR/REC-html40/strict.dtd">

<html lang="no">
	<!-- $cvs_id -->
	<!-- $main::cvs_id -->
	<head>
		<title>$Title</title>
		<style type="text/css">
			body { background: white; color: black; }
			a:link { color: blue; }
			a:visited { color: maroon; }
			a:active { color: fuchsia; }
			b.krise { color: red; }
			h1 { color: red; }
		</style>
		<meta http-equiv="Content-Type" content="text/html; charset=$CharSet">
		<meta name="author" content="tritech\@tritech.no">
		<meta name="copyright" content="&copy; Tritech A/S http://www.tritech.no">
		<meta name="description" content="CGI error">
		<meta name="date" content="$curr_utc">
		<link rev="made" href="mailto:tritech\@tritech.no">
	</head>
	<body>
		<h1>$Title</h1>
		<blockquote>
			$msg_str
		</blockquote>
	</body>
</html>
END
	touch($error_file) unless (-e $error_file);
	open(ErrorFP, "+<$error_file") or exit;
	flock(ErrorFP, LOCK_EX);
	seek(ErrorFP, 0, 2) or exit;
	printf(ErrorFP "%s HDIE %s\n", &curr_utc_time, $Msg);
	close(ErrorFP);
	exit;
} # HTMLdie()

###########################################################################

=head2 &HTMLwarn()

En lightversjon av I<&HTMLdie()>, den skriver kun til I<$error_file>. Når
det oppstår feil men man ikke trenger å stoppe hele systemet. Brukes til
småting som tellere som ikke virker og sånn.

=cut

sub HTMLwarn {
	local($Msg) = shift;
	my $curr_utc = &curr_utc_time;

	# Gjør det så stille og rolig som mulig.
	if ($Utv || $Debug) {
		&print_header("CGI warning");
		print "\n\t\t<p><font size=\"+1\"><b>HTMLwarn(): $Msg</font></n>\n";
	}
	if (-e $error_file) {
		open(ErrorFP, ">>$error_file") or return;
	} else {
		open(ErrorFP, ">$error_file") or return;
	}
	print(ErrorFP "$curr_utc WARN $Msg\n");
	close(ErrorFP);
} # HTMLwarn()

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

FIXME: Skriver mer på denne seinere. Og gjør greia ferdig.

=cut

sub print_doc {
	my ($file_name, $page_num) = @_;

} # print_doc()

###########################################################################

=head2 &print_footer()

Skriver ut en footer med en E<lt>hrE<gt> først. Funksjonen tar disse
parameterne:

=over 4

=item I<$footer_width>

Bredden på footeren i pixels. Er I<${main::doc_width}> som default.

=item I<$footer_align>

Kan være I<left>, I<center> eller I<right>. Brukes av E<lt>tableE<gt>.
Standard er "center".

=item I<$no_vh>

Tar ikke med I<Valid HTML>-logoen nederst i høyre hjørne.

=item I<$no_end>

Tar ikke med E<lt>/bodyE<gt>E<lt>/htmlE<gt> på slutten.

=back

=cut

sub print_footer {
	my ($footer_width, $footer_align, $no_vh, $no_end) = @_;

	$footer_width = ${main::doc_width} unless length($footer_width);
	$footer_align = "center" unless length($footer_align);
	$no_vh = $FALSE unless length($no_vh);
	$no_end = $FALSE unless length($no_end);
	my $cvs_str = $tricgi::cvs_date;
	$cvs_str =~ s/ /&nbsp;/g;
	my $vh_str = $no_vh ? "&nbsp;" : "<a href=\"http://validator.w3.org/check/referer;ss\"><img src=\"$GrafDir/vh40.gif\" height=\"31\" width=\"88\" align=\"right\" border=\"0\" alt=\"Valid HTML 4.0!\"></a>";

	# FIXME: Hardkoding av URL her pga av at ${main::Url} har skifta navn.
	# FIXME: I resten av HTML'en er det brukt <div align="center">.
	print(<<END);
		<table width="$footer_width" cellpadding="0" cellspacing="0" border="$Border" align="$footer_align">
			<tr>
				<td colspan="3">
					<hr>
				</td>
			</tr>
			<tr>
				<td align="center">
					<table cellpadding="0" cellspacing="0" border="$Border">
						<tr>
							<td align="center">
								${FONTB}<small>&copy;&nbsp;<a href="http://www.tritech.no" target="_top">TriTech&nbsp;AS</a>&nbsp;&lt;<code><a href="http://www.tritech.no/index.cgi?doc=kontakt">tritech\@tritech.no</a></code>&gt;</small>${FONTE}
							</td>
						</tr>
						<tr>
							<td align="center">
								${FONTB}<small>$cvs_str</small>${FONTE}
							</td>
						</tr>
					</table>
				</td>
				<td width="100%" align="center">
					&nbsp;
				</td>
				<td align="right">
					$vh_str
				</td>
			</tr>
		</table>
	</body>
</html>
END
	exit;
} # print_footer()

###########################################################################

=head2 &print_header()

Lager en HTML4-header i henhold til W3C's anbefaling. Den tar disse
parameterne:

=over 4

=item I<$DocTitle>

Det som skal inn i E<lt>titleE<gt>E<lt>/titleE<gt>

=item I<$html_version>

Hvilken DTD som skal brukes i begynnelsen. Bruker I<$DTD_HTML4STRICT> som
default, altså

S<E<lt>!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
S<"httpZ<>://www.w3.org/TR/REC-html40/loose.dtd"E<gt>>

=item I<$Language>

Landskode på to bokstaver som havner i E<lt>html langE<gt>. Standardverdi
er "no", det vil si

	<html lang="no">

=item I<$user_background>

Bakgrunn som skal brukes. Det er i utgangspunktet en farge (engelsk
fargenavn eller RGB-format "#ffffff"), men hvis extension er lik
.(jpg|jpeg|gif|png) er det et bilde.

=item I<$Refresh>

Antall sekunder mellom hver refresh. Standard I<meta http-equiv> refresh.

=item I<$no_body>

Hvis denne er !I<$FALSE>, skrives ikke E<lt>bodyE<gt> ut. Praktisk hvis
det er merkelig E<lt>bodyE<gt> som skal brukes, eller hvis det skal legges
inn noen javascript-greier der.

=item I<$Description>

Det som skal stå i beskrivelsen i E<lt>metaE<gt>-bestyret.

=item I<$Keywords>

Keywords i E<lt>metaE<gt>. Skal være kommaseparert og med etities.

=item I<@StyleSheet>

Array med alt som skal inn style sheets.
FIXME: Stygg sak dette her at den må være på slutten av parametrene,
skulle vært en bedre måte så den kan bli sendt som ETT parameter, men det
ser vi på seinere. Er vel ikke så nøye enda.

BTW blir vel ikke paramterne brukt så mye til hverdags, hvis
F<&print_doc()> blir ferdig rimelig fort. Der skal som kjent alt
spesifiseres.

=back

=cut

sub print_header {
	my ($DocTitle, $html_version, $Language, $user_background, $Refresh, $no_body, $Description, $Keywords, @StyleSheet) = @_;
	my $DocumentTime = &curr_utc_time();
	my $BodyStr = "<body>";
	my $BackgroundStr;
	my $RefreshStr = $Refresh ? "<meta http-equiv=\"refresh\" content=\"$Refresh\" url=\"${main::Url}\">\n\t\t" : "";
	my $KeywStr = length($Keywords) ? "<meta name=\"keywords\" content=\"$Keywords\">\n\t\t" : "";
	my $CharSet = $STD_CHARSET unless length($CharSet);

	if (length($user_background)) {
		if ($user_background =~ /\.(jpg|jpeg|gif|png)$/i) {
			$BodyStr = "<body background=\"$user_background\">";
			$BackgroundStr = "";
		} else {
			$BackgroundStr = $user_background;
			$BodyStr = "<body bgcolor=\"$BackgroundStr\">";
		}
	} else {
		$BackgroundStr = "";
		$BodyStr = "<body>";
	}

	&content_type("text/html");
	if (!length($html_version)) {
		print $DTD_HTML4LOOSE;
	} else {
		print $html_version;
	}
	print <<END;
<html lang="$Language">
	<!-- $cvs_id -->
	<!-- $main::cvs_id -->
END
	&Tabs(2); # html og head

	# FIXME: Midlertidig here'ing, det kan gjøres mye gøyere. Tar ikke hensyn til $Tabs heller, men det kommer.
	print <<END;
	<head>
		<title>$DocTitle</title>
		<meta http-equiv="Content-Type" content="text/html; charset=$CharSet">
		$RefreshStr<meta name="author" content="tritech\@tritech.no">
		$KeywStr<meta name="copyright" content="&copy; TriTech A/S &lt;http://www.tritech.no&gt;">
		<meta name="description" content="$Description">
		<meta name="date" content="$DocumentTime">
		<link rev="made" href="mailto:${main::WebMaster}">
END

	print "\t\t<style type=\"text/css\">\n" if scalar @StyleSheet;
	&Tabs(1);
	foreach (@StyleSheet) {
		printf("%s%s\n", $Tabs, $_);
	}
	print "\t\t</style>\n" if scalar @StyleSheet;
	&Tabs(-2); # style og head
	print("$Tabs</head>\n");
	print("$Tabs$BodyStr\n") unless $no_body;
} # print_header()

###########################################################################

=head2 &tab_print()

Skriver ut på samme måte som print, men setter inn I<$Tabs> først på
hver linje. Det er for å få riktige innrykk. Det forutsetter at
I<$Tabs> er oppdatert til enhver tid.

=cut

sub tab_print {
	my $Txt = shift;

	$Txt =~ s/^(.*)/$Tabs$1/gm;
	print "$Txt";
} # tab_print()

###########################################################################

=head2 &Tabs()

Øker/minsker verdien av I<$Tabs> som er en lokal variabel i I<$tricgi::>.
Den kan ta ett parameter, en verdi som er negativ eller positiv alt
ettersom man skal fjerne eller legge til TAB'er. Hvis man skriver

	&Tabs(-2);

fjernes to spacer, hvis man skriver

	&Tabs(5);

legges 5 TAB'er til. Hvis ingen parametere spesifiseres, brukes 1 som
default.

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

=head1 BUGS

Strukturen er ikke helt klar enda, det blir nok mange forandringer
underveis.

=cut

1;

#### End of file $Id: tricgi.pm,v 1.1 1999/03/16 00:13:05 sunny Exp $ ####
