
/*
 * Skriver ut alle gyldige norske personnummer på angitte datoer
 * $Id: personnr.c,v 1.4 2003/09/12 03:24:52 sunny Exp $
 *
 * Oppbygningen av personnummeret 020656-45850: {{{
 *
 * 020656 = Fødselsdato (ddmmåå)
 *    458 = Fødselsnummer.
 *          Den første registrerte gutten den dagen fikk fødselsnummeret 499.
 *          Den neste fikk 497. Den første registrerte jenta fikk 498, den
 *          neste 496 osv.
 *          Oddetall = hankjønn, like tall = hunkjønn.
 *          For personer født i forrige eller neste århundre (18xx/20xx)
 *          brukes tall fra 999/998 ned til 500/501.
 *     50 = Kontrollsiffer som er regnet ut etter en spesiell formel. Enhver
 *          som kjenner denne formelen har mulighet for å kontrollere om det
 *          personnummeret som oppgis er beregnet på den riktige måten. Det
 *          vil bare være de registere som har tilgang til folkeregisteret
 *          som vil kunne sjekke om personnummeret er det som er det riktige.
 *
 * Formel for å regne ut kontrollsiffer:
 *
 * Utgangspunktet er to faste rekker med multiplikatorer. Den første rekken
 * blir brukt til å regne ut første kontrollsiffer, og den andre rekken til
 * det andre kontrollsifferet.
 *
 * +-------------------------+
 * | fødselsdato f.num ktr   |
 * | -----------|-----|---   |
 * | a b c d e f g h i j k   |
 * | 3 7 6 1 8 9 4 5 2 - - x |
 * | 5 4 3 2 7 6 5 4 3 2 - y |
 * +-------------------------+
 *
 * x = a*3 + b*7 + c*6 + d*1 + e*8 + f*9 + g*4 + h*5 +i*2
 * j = 11 - x % 11
 * y = a*5 + b*4 + c*3 + d*2 + e*7 + f*6 + g*5 + h*4 + i*3 + j*2
 * k = 11 - y % 11
 *
 * Dersom j eller k <= 9 er j eller k riktige kontrollsiffer.
 * Dersom j eller k = 10 er personnummeret ugyldig.
 * Dersom j eller k = 11 er j eller k = 0.
 *
 * Det betyr at det for en fødselsdato ikke finnes mer enn litt over 200
 * mulige personnummer for hvert kjønn.
 * }}}
 *
 * Laget av Øyvind A. Holm <sunny@sunbase.org>.
 *
 * Takk til Markus B. Krüger <markusk@pvv.org> for patch som bruker modulus
 * og dermed gjorde bruk av frac() overflødig.
 *
 * Programlisens: GNU General Public License. Ingen over, ingen ved siden.
 */

#define VERSION   "1.11"
#define RCS_DATE  "$Date: 2003/09/12 03:24:52 $"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define c2i(c)  ((c) - '0')  /* (char)tall --> (int)tall */

#define EXIT_OK    0
#define EXIT_ERROR 1

static char rcs_id[] = "$Id: personnr.c,v 1.4 2003/09/12 03:24:52 sunny Exp $";

char *persnr(char *);
int persnr_date(char *);
void usage(int);

char *progname = NULL;

int main(int argc, char *argv[])
{
	/* {{{ */
	int retval = 0,
	    i = 0;

	(void)rcs_id; /* Unngå klaging fra kompilatorer */
	progname = argv[0];
	if (argc > 1 && (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-h") || !strcmp(argv[1], "?") || !strcmp(argv[1], "-?")))
		usage(0);

	if (argc > 1) {
		for (i = 1; i < argc; i++) {
			retval |= persnr_date(argv[i]);
		}
	} else {
		char buf[20];
		while (fgets(buf, 15, stdin), !feof(stdin)) {
			char *p = strstr(buf, "\n");
			if (p)
				*p = '\0';
			retval |= persnr_date(buf);
		}
	}

	return(retval);
	/* }}} */
} /* main() */

char *persnr(char *orgbuf)
{
	/* Mottar peker til en buffer med plass til minst 12 tegn der de første 10 er fylt ut. Returnerer komplett nummer. {{{ */
	int x, y, j, k;
	static char buf[12];

	strcpy(buf, orgbuf);

	x = c2i(buf[0])*3 + c2i(buf[1])*7 + c2i(buf[2])*6 + c2i(buf[3])*1 + \
	    c2i(buf[4])*8 + c2i(buf[5])*9 + c2i(buf[6])*4 + c2i(buf[7])*5 + \
	    c2i(buf[8])*2;
	j = 11 - x % 11;
	y = c2i(buf[0])*5 + c2i(buf[1])*4 + c2i(buf[2])*3 + c2i(buf[3])*2 + \
	    c2i(buf[4])*7 + c2i(buf[5])*6 + c2i(buf[6])*5 + c2i(buf[7])*4 + \
	    c2i(buf[8])*3 + j*2;
	k = 11 - y % 11;

	if (j == 10 || k == 10) { /* Hvis j eller k == 10 er nummeret falskt */
		strcpy(buf, ""); /* Returnerer tom streng hvis ulovlig */
		goto endfunc;
	}

	if (j == 11)
		j = 0;
	if (k == 11)
		k = 0;

	buf[9] = j + '0';
	buf[10] = k + '0';
	buf[11] = '\0';

endfunc:
;
	return(buf);
	/* }}} */
} /* persnr */

int persnr_date(char *birth_str)
{
	/* Sender alle gyldige personnr for en viss dato til stdout {{{ */
	register int i; /* Tellevariabel */
	int retval = EXIT_OK,
		startnum = 999; /* Avhengig av curr_century */
	char buf[12], birthdate[20], tmpbuf[12], century[3], iso_date[12];
	char curr_century = 1; /* 0 = 499 og nedover, 1 = 999 og nedover */

	sprintf(birthdate, "%.15s", birth_str);

	if ((strlen(birthdate) != 6) && (strlen(birthdate) != 8)) { /* Sjekk at lengden på datoen er seks eller åtte tegn */
		fprintf(stderr, "%s: \"%s\": Feil format på datoen. Formatet skal være ddmmåå eller ddmmåååå.\n", progname, birthdate);
		retval = EXIT_ERROR;
		goto endfunc;
	}

	strcpy(century, "20"); /* Default århundre er 20xx */

	/*
	 * Her kommer det en sjekk som finner ut om det er spesifisert et
	 * annet århundre, f.eks. 24091971, dvs. to ekstra siffer i året.
	 */

	if (strlen(birthdate) == 8) {
		strncpy(century, birthdate + 4, 2); /* Nytt århundre på gang */
		curr_century = (atoi(century) % 2) ? 0 : 1;

		strcpy(tmpbuf, birthdate);
		sprintf(birthdate, "%c%c%c%c%c%c",
		birthdate[0],
		birthdate[1],
		birthdate[2],
		birthdate[3],
		birthdate[6],
		birthdate[7]);
	}

	startnum = curr_century ? 999 : 499; /* Hvilket århundre skal brukes? */

	sprintf(iso_date, "%2.2s%c%c-%c%c-%c%c",
		century,
		birthdate[4],
		birthdate[5],
		birthdate[2],
		birthdate[3],
		birthdate[0],
		birthdate[1]);

	fprintf(stdout, "\nListe over alle gyldige norske personnummer for %s:\n\n", iso_date);
	fprintf(stdout, "Gutter:\n\n");
	for (i = startnum; i >= (startnum-499); i -= 2) {
		sprintf(buf, "%s%3.3d\n", birthdate, i);
		strcpy(tmpbuf, persnr(buf));
		if (!strlen(tmpbuf))
			continue;
		fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
	}

	fprintf(stdout, "\nJenter:\n\n");
	for (i = (startnum-1); i >= (startnum-499); i -= 2) {
		sprintf(buf, "%s%3.3d\n", birthdate, i);
		strcpy(tmpbuf, persnr(buf));
		if (!strlen(tmpbuf))
			continue;
		fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
	}

	fprintf(stdout, "\n--- Utlisting for %s slutt ---\n", iso_date);

endfunc:
;
	return(retval);
	/* }}} */
} /* persnr_date() */

void usage(int retval)
{
	/* Send hjelpen til stdout {{{ */
	int charnum; /* Cosmetic thing */

	putchar('\n');
	charnum = printf("%s ver. %s (%s) -- (C)opyleft by sunny", progname, VERSION, RCS_DATE);
	putchar('\n');

	for (; charnum; charnum--)
		putchar('-');
	printf(
		"\nBruk: %s [fødselsdato [...]]\n\n"
		"Skriver ut alle gyldige norske personnummer for en eller flere datoer.\n"
		"Fødselsdatoen spesifiseres på formatet ddmmåå. Hvis et annet århundre\n"
		"enn 20xx skal brukes, brukes formatet ddmmåååå.\n\n"
		"Hvis ingen datoer skrives på kommandolinja, leser programmet datoer fra\n"
		"standard input.\n\n"
		"Programlisens: GNU General Public License, se fila COPYING for detaljer.\n"
		, progname
	);
	exit(retval);
	/* }}} */
} /* usage() */

/* vim600: set fdm=marker fdl=0 ts=4 sw=4 : */
/* End of file $Id: personnr.c,v 1.4 2003/09/12 03:24:52 sunny Exp $ */
