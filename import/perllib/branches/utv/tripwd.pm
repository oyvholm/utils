package tripwd;

=head1 NAME

tripwd - Passordrutiner

=head1 REVISION

S<$Id: tripwd.pm,v 1.4 1999/06/30 11:42:17 sunny Exp $>

=head1 SYNOPSIS

require tripwd;

=head1 DESCRIPTION

Inneholder diverse passordrutiner.

=head1 COPYRIGHT

(C)opyright 1999 Øyvind A. Holm E<lt>F<sunny@tritech.no>E<gt>

Denne modulen er eiendom tilhørende Øyvind A. Holm. Dispensasjon for bruk
er gitt til Tritech A/S E<lt>F<http://www.tritech.no>E<gt> inntil videre.

=cut

require 5.003;

###########################################################################
#### Variabler
###########################################################################

my $rcs_date = '$Date: 1999/06/30 11:42:17 $';
my $rcs_header = '$Header: /home/sunny/tmp/cvs/perllib/tripwd.pm,v 1.4 1999/06/30 11:42:17 sunny Exp $';
my $rcs_id = '$Id: tripwd.pm,v 1.4 1999/06/30 11:42:17 sunny Exp $';

my $FALSE = 0;
my $TRUE = 1;

# $EXIT_OK = 0;
# $EXIT_ERROR = 1;
$EXIT_CORRECT_PWD = 2364; # FIXME: Funker det sånn? Tror det bør være tilfeldige verdier med i bildet her.
$EXIT_WRONG_PWD = 6452;
$EXIT_UNKNOWN_USER = 3623;

###########################################################################
#### Subrutiner
###########################################################################

=head1 SUBRUTINER

=cut

=head2 &correct_pwd()

Sjekker at brukerpassordet i /etc/passwd er rett.

Tar to parametere: brukernavn og passord. Returnerer disse verdiene:

=over 4

=item I<$EXIT_CORRECT_PWD>

Passordet stemmer

=item I<$EXIT_WRONG_PWD>

Feil passord

=item I<$EXIT_UNKNOWN_USER>

Brukeren finnes ikke

=back

FIXME: Lurer litt på disse returverdiene. Er det ikke bedre hvis den
returnerer 0 hvis passordet er rett? Kanskje en F<&wrong_password()> hadde
vært på sin plass. Sånn som det er nå, er returverdiene rimelig
tilfeldige. Jaja. Vi bruker denne foreløpig. Den funker.

Mulig det skal defineres et parameter seinere som bestemmer hvordan
passordet skal sjekkes.

=cut

sub correct_pwd {
	my ($user_name, $user_password) = @_;
	print("debug i correct_pwd(): user_name = \"$user_name\", user_password = \"$user_password\"\n") if ${main::Debug};
	if (length getpwnam($user_name)) {
		my $Pwd = (getpwnam($user_name))[1];
		my $Salt = substr($Pwd, 0, 2);
		$RetVal = (crypt($user_password, $Salt) eq $Pwd) ? $EXIT_CORRECT_PWD : $EXIT_WRONG_PWD;
	} else {
		$RetVal = $EXIT_UNKNOWN_USER;
	}
	print("debug: Går ut av &correct_pwd(), \$RetVal = \"$RetVal\"\n") if ${main::Debug};
	return $RetVal;
} # correct_pwd()

=head1 BUGS

Rimelig spinkel foreløpig. Det kommer seg vel.

=cut

1;

#### End of file $Id: tripwd.pm,v 1.4 1999/06/30 11:42:17 sunny Exp $ ####
