
/*
 * Kontrollerer om norske personnumre er gyldige og kan også skrive ut alle
 * gyldige norske personnumre på angitte datoer.
 *
 * $Id: personnr.c,v 1.3.2.12 2004/03/03 09:27:08 sunny Exp $
 *
 * Tegnsett brukt i denne fila: UTF-8
 *
 * Oppbygningen av det feminine personnummeret 020656-45850: {{{
 *
 * 020656 = Fødselsdato (ddmmåå)
 *
 *    458 = Fødselsnummer. Den første registrerte gutten den dagen fikk
 *          fødselsnummeret 499. Den neste fikk 497. Den første registrerte
 *          jenta fikk 498, den neste 496 osv. Oddetall = hankjønn, like
 *          tall = hunkjønn.
 *
 *          For personer født på 1800- eller 2000-tallet brukes tall fra
 *          999/998 ned til 501/500. Personer som er født på 1900-tallet har
 *          personnummer i området 499/498 til 001/000.
 *
 *     50 = Kontrollsum som er regnet ut etter en spesiell formel. Enhver
 *          som kjenner denne formelen har mulighet for å kontrollere om det
 *          personnummeret som oppgis er beregnet på den riktige måten og
 *          dermed er gyldig.
 *
 * Formel for å regne ut kontrollsummen:
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
 * Dersom j eller k = 11 settes j eller k til 0.
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

#define VERSION   "1.12"
#define RCS_DATE  "$Date: 2004/03/03 09:27:08 $"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define c2i(c)             (int)((c) - '0')  /* (char)tall --> (int)tall */
#define in_range(a, b, c)  ((((a) >= (b)) && ((a) <= (c))) ? 1 : 0)

#define EXIT_OK     0
#define EXIT_ERROR  1

static char rcs_id[] = "$Id: personnr.c,v 1.3.2.12 2004/03/03 09:27:08 sunny Exp $";

int lovlig_personnr(char *);
char *persnr(char *);
int persnr_date(char *);
int persnr_ok(char *);
int process_personnr(char *);
void usage(int);

char *progname = NULL;

int main(int argc, char *argv[])
{
	/* {{{ */
	int retval = EXIT_OK,
	    i = 0;

	(void)rcs_id; /* Unngå klaging fra kompilatorer */
	progname = argv[0];
	if (argc > 1 && (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-h") || !strcmp(argv[1], "?") || !strcmp(argv[1], "-?")))
		usage(EXIT_OK);

	if (argc > 1) {
		for (i = 1; i < argc; i++) {
			char *p = argv[i];
			retval |= process_personnr(p);
		}
	} else {
		char buf[15];
		while (fgets(buf, 12, stdin), !feof(stdin)) {
			char *p = strstr(buf, "\n");
			if (p)
				*p = '\0';
			retval |= process_personnr(buf);
		}
	}

	if (retval != EXIT_OK)
		fprintf(stderr, "\nSkriv \"%s -h\" for hjelp.\n\n", progname);

	return(retval);
	/* }}} */
} /* main() */

int lovlig_personnr(char *pers_str)
{
	/* Sjekker at personnummeret eller datoen inneholder lovlige tegn og verdier {{{ */
	int retval = 1, i;
	char *p, buf[3];

	for (p = pers_str; *p && retval; p++) {
		if (!isdigit(*p)) {
			fprintf(stderr, "%s: %s: Kan kun inneholde siffer\n", progname, pers_str);
			retval = 0;
		}
	}

	if (retval) {
		strncpy(buf, pers_str, 2);
		buf[2] = '\0';
		i = atoi(buf);
		if (!in_range(i, 1, 31)) {
			fprintf(stderr, "%s: %s: Ulovlig dato: \"%s\"\n", progname, pers_str, buf);
			retval = 0;
		}

		strncpy(buf, pers_str+2, 2);
		buf[2] = '\0';
		i = atoi(buf);
		if (!in_range(i, 1, 12)) {
			fprintf(stderr, "%s: %s: Ulovlig måned: \"%s\"\n", progname, pers_str, buf);
			retval = 0;
		}
	}

	return(retval);
	/* }}} */
} /* lovlig_personnr() */

char *persnr(char *orgbuf)
{
	/* Mottar peker til en buffer med plass til minst 12 tegn der de første 10 er fylt ut. Returnerer komplett nummer. {{{ */
	int x, y, j, k, qfunc = 0;
	static char buf[12];

	strncpy(buf, orgbuf, 11);

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
		qfunc = 1;
	}

	if (!qfunc) {
		if (j == 11)
			j = 0;
		if (k == 11)
			k = 0;

		buf[9] = j + '0';
		buf[10] = k + '0';
		buf[11] = '\0';
	}

	return(buf);
	/* }}} */
} /* persnr() */

int persnr_date(char *birth_str)
{
	/* Sender alle gyldige personnr for en viss dato til stdout {{{ */
	register int i; /* Tellevariabel */
	int retval = EXIT_OK,
		startnum, /* Avhengig av curr_century */
		qfunc = 0;
	char buf[12], birthdate[20], tmpbuf[12], century[3], iso_date[12];
	char curr_century = 1; /* 0 = 499 og nedover, 1 = 999 og nedover */

	if ((strlen(birth_str) != 6) && (strlen(birth_str) != 8)) {
		fprintf(stderr, "%s: \"%s\": Feil format på datoen. Formatet skal være ddmmåå eller ddmmåååå.\n", progname, birth_str);
		retval |= EXIT_ERROR;
		qfunc = 1;
	}

	if (!qfunc) {
		sprintf(birthdate, "%.8s", birth_str);

		strcpy(century, "20"); /* Standard århundre er 20xx */

		/*
		 * Her kommer det en sjekk som finner ut om det er spesifisert et
		 * annet århundre, f.eks. 24091971, dvs. to ekstra siffer i året.
		 */

		if (strlen(birthdate) == 8) {
			strncpy(century, birthdate + 4, 2); /* Muligens annet århundre på gang */
			curr_century = (atoi(century) % 2) ? 0 : 1;

			strncpy(tmpbuf, birthdate, 11);
			sprintf(birthdate, "%c%c%c%c%c%c",
				birthdate[0],
				birthdate[1],
				birthdate[2],
				birthdate[3],
				birthdate[6],
				birthdate[7]
			);
		}

		startnum = curr_century ? 999 : 499; /* Hvilket århundre skal brukes? */

		sprintf(iso_date, "%2.2s%c%c-%c%c-%c%c",
			century,
			birthdate[4],
			birthdate[5],
			birthdate[2],
			birthdate[3],
			birthdate[0],
			birthdate[1]
		);

		fprintf(stdout, "\nListe over alle gyldige norske personnummer for %s:\n\n", iso_date);
		fprintf(stdout, "Gutter:\n\n");
		for (i = startnum; i >= (startnum-499); i -= 2) {
			sprintf(buf, "%s%3.3d\n", birthdate, i);
			strncpy(tmpbuf, persnr(buf), 11);
			if (!strlen(tmpbuf))
				continue;
			fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
		}

		fprintf(stdout, "\nJenter:\n\n");
		for (i = (startnum-1); i >= (startnum-499); i -= 2) {
			sprintf(buf, "%s%3.3d\n", birthdate, i);
			strncpy(tmpbuf, persnr(buf), 11);
			if (!strlen(tmpbuf))
				continue;
			fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
		}

		fprintf(stdout, "\n--- Utlisting for %s slutt ---\n", iso_date);
	}

	return(retval);
	/* }}} */
} /* persnr_date() */

int persnr_ok(char *pers_str)
{
	/* Mottar et komplett personnummer (11 siffer) og returnerer 1 hvis det er rett eller 0 hvis det er feil {{{ */
	int retval;
	char tmpbuf[13];

	strncpy(tmpbuf, persnr(pers_str), 12);
	retval = strcmp(tmpbuf, pers_str) ? 0 : 1;
	return(retval);
	/* }}} */
} /* persnr_ok() */

int process_personnr(char *buf)
{
	/* Utfør det som skal gjøres på datoen eller personnummeret. Returnerer EXIT_OK eller EXIT_ERROR. {{{ */
	int retval = EXIT_OK;

	if ((strlen(buf) == 6) || (strlen(buf) == 8)) {
		if (lovlig_personnr(buf))
			retval |= persnr_date(buf);
		else
			retval |= EXIT_ERROR;
	} else if ((strlen(buf) == 11)) {
		if (lovlig_personnr(buf))
			printf("%s er %sgyldig\n", buf, persnr_ok(buf) ? "" : "IKKE ");
		else
			retval |= EXIT_ERROR;
	} else {
		fprintf(stderr, "%s: \"%s\": Er hverken personnummer eller dato\n", progname, buf);
		retval |= EXIT_ERROR;
	}
	return(retval);
	/* }}} */
} /* process_personnr() */

void usage(int retval)
{
	/* Send hjelpen til stdout og avslutt {{{ */
	printf(
		"\n"
		"personnr versjon %s (%s)\n"
		"(C)opyleft Øyvind A. Holm <sunny@sunbase.org>\n"
		"\n"
		"Bruk: %s [personnummer|fødselsdato [...]]\n"
		"\n"
		"Programmet kan sjekke om et eller flere norske personnumre er gyldig i\n"
		"henhold til kontrollsummen som er lagret i de to siste sifrene av et\n"
		"11-sifret personnummer.\n"
		"\n"
		"Alle personnumrene på en eller flere angitte datoer kan også skrives ut.\n"
		"Fødselsdatoen må være på formatet ddmmåå eller ddmmåååå. Hvis datoen skrives\n"
		"med ddmmåå-formatet, brukes 20xx som århundre.\n"
		, VERSION, RCS_DATE, progname
	); /* Må splittes på grunn av potensielt hjernedøde kompilatorer som ikke liker strenger over 509 bytes. */
	printf(
		"\n"
		"Hvis ingen personnumre eller datoer skrives på kommandolinja, leser\n"
		"programmet fra standard input.\n"
		"\n"
		"Programlisens: GNU General Public License, se fila COPYING for detaljer\n"
		"eller les lisensen på <http://www.gnu.org/copyleft/gpl.html>.\n"
		"\n"
		"Nyeste versjon av programmet kan hentes fra\n"
		"<http://www.sunbase.org/src/personnr>.\n"
		"\n"
	);

	exit(retval);
	/* }}} */
} /* usage() */

/* vim600: set fdm=marker fdl=0 ts=4 sw=4 : */
/* End of file $Id: personnr.c,v 1.3.2.12 2004/03/03 09:27:08 sunny Exp $ */
