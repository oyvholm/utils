
/*
 * personnr.c - Skriver ut alle gyldige personnummer p† en gitt dato
 *
 * Oppbygningen av personnummeret 020656-45850:
 *
 * 020656 = F›dselsdato (ddmm††)
 *    458 = F›dselsnummer.
 *          Den f›rste registrerte gutten den dagen fikk f›dselsnummeret 499.
 *          Den neste fikk 497. Den f›rste registrerte jenta fikk 498, den
 *          neste 496 osv.
 *          Oddetall = hankj›nn, like tall = hunkj›nn.
 *          For personer f›dt i forrige eller neste †rhundre (18XX/20XX)
 *          brukes tall fra 999/998 ned til 500/501.
 *     50 = Kontrollsiffer som er regnet ut etter en spesiell formel. Enhver
 *          som kjenner denne formelen har mulighet for † kontrollere om det
 *          personnummeret som oppgis er beregnet p† den riktige m†ten. Det
 *          vil bare v‘re de registere som har tilgang til folkeregisteret
 *          som vil kunne sjekke om personnummeret er det som er det riktige.
 *
 * Formel for † regne ut kontrollsiffer:
 *
 * Utgangspunktet er to faste rekker med multiplikatorer. Den f›rste rekken
 * blir brukt til † regne ut f›rste kontrollsiffer, og den andre rekken til
 * det andre kontrollsifferet.
 *
 * ---------------------------
 * | f›dselsdato f.num ktr   |
 * | -----------|-----|---   |
 * | a b c d e f g h i j k   |
 * | 3 7 6 1 8 9 4 5 2 - - x |
 * | 5 4 3 2 7 6 5 4 3 2 - y |
 * ---------------------------
 *
 * x = a*3 + b*7 + c*6 + d*1 + e*8 + f*9 + g*4 + h*5 +i*2
 * j = 11 [1 - frac(x/11)]
 * y = a*5 + b*4 + c*3 + d*2 + e*7 + f*6 + g*5 + h*4 + i*3 + j*2
 * k = 11 [1 - frac(y/11)]
 *
 * j og k avrundes etter vanlige avrundingsregler.
 * Dersom j eller k <= 9 er j eller k riktige kontrollsiffer.
 * Dersom j eller k = 10 er personnummeret ugyldig.
 * Dersom j eller k = 11 er j eller k = 0.
 * Det betyr at det for en f›dselsdato ikke finnes mer enn noe over 200
 * mulige personnummer for hvert kj›nn.
 *
 * "Frac" er desimaltallene ved resultatet av divisjonen med 11 som skal
 * trekkes fra 1. Eksempel: frac(126/11) = frac(11.45) = 0.45.
 * Det er ikke n›dvendig † bruke mer enn to desimaler ved denne utregningen.
 *
 * Liste over endringer:
 *
 * 04-Oct-1993 ver. 1.00
 *   Denne sourcen er egentlig basert p† ALLPERS.C (CRC32/16: 1974871C-378E,
 *   Date: 1991-12-08 18:17:40, Size: 7766), men ville ha support for flere
 *   †rhundrer. Dette kan man si er en endelig versjon, derfor kalte jeg hele
 *   saken for PERSONNR.C, ALLPERS passa ikke helt.
 *   I ALLPERS.C hadde jeg lagt inn en enkel kryptering  for † forhindre at
 *   folk patcha bort at programmet var gitt til dem. Den har jeg forbedra
 *   en del s† mye som jeg gidder.
 *
 * Programmet er laget av yvind Solheim (Sunny)
 * Programmert i Turbo C++ ver. 1.00.
 *
 */

#define ENGLISH		1
#define NORWEGIAN	2

#define C_LANG		NORWEGIAN
#define C_SECURITY      1  /* Patchebeskyttelse. 0 = Ingen beskyttelse, 1 = Vanlig beskyttelse, 2 = Finn kode. */
#define C_DEBUG		0

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#define c2i(c)		((c) - '0') /* (char)tall --> (int)tall */
#define frac(a)		(((int)((a) * 100) % 100) / (float)100) /* Returnerer 2 desimaler */

#define REV_DATE	"04-Oct-1993"   /* Last revision date */
#define VERSION		"1.00"
#define MINPARAM	1               /* Kan spesifisere ett parameter */

#define OS_NAME		"DOS"           /* Name of operating system */

#define EXIT_OK		0
#define EXIT_ERROR	1

#define OK		0
#define ERROR		1


#if C_SECURITY
#define check_secur()	{if (security != 0x6793) exit(EXIT_OK);}
#else
#define check_secur()	{}
#endif


/*
 * ENGLISH
 */

#if C_LANG == ENGLISH
#error English language not supported
#endif /* if C_LANG == ENGLISH */


/*
 * NORWEGIAN
 */

#if C_LANG == NORWEGIAN

char	PROG_NAME[]		= "PERSONNR";
char	AUTHOR[]		= "SunWare (yvind Solheim (\"Sunny\"))";

char	MSG_LANGUAGE[]		= "Norsk";

char	MSG_SYN_VER[]		= "\n%s ver. %s (%s) for %s\n";
char	MSG_SYN_MADEBY[]	= "Laget av %s %s";
char	MSG_SYN_USAGE[]		= "\nBruk: %s [f›dselsdato]\n\n";
char	MSG_SYN_TXT[]		= "F›dselsdatoen spesifiseres p† formatet ddmm††. Hvis et annet †rhundre enn\n"\
				  "1900 skal brukes, brukes formatet ddmm††††.\n";

#if C_DEBUG
char	MSG_SYN_DEBUGVER[]	= "\nDebug version, C_DEBUG = %d\n\n";
#endif /* if C_DEBUG */

char	MSG_STARTHEADER[]	= "*** Program for generering av norske personnummer ***";
char	MSG_ASK_BIRTHDATE[]	= "F›dselsdato (ddmm†† eller ddmm††††): ";
char	MSG_HEADER[]		= "Liste over alle gyldige norske personnummer for %c%c/%c%c %2.2s%c%c:\n\n";
char	MSG_MALE[]		= "Hankj›nn:";
char	MSG_FEMALE[]		= "Hunkj›nn:";
char	MSG_END_OF_LIST[]	= "*** Slutt p† utlisting ***";

char	MSG_ERROR[]		= "%s FEIL: ";

char	ERR_TOO_MANY_PARAMS[]	= "For mange parametere. Skriv %s ? for hjelp.";
char	ERR_INVALID_PARAMLEN[]	= "Feil format p† datoen. Formatet skal v‘re ddmm†† eller ddmm††††.";

#endif /* if C_LANG == NORWEGIAN */

#if C_SECURITY
char    s[102], ss[11]; /* ss brukes ikke, den er bare her for at det ikke skal k›ddes med s. */
int	security = 0x6553;
#endif /* if C_SECURITY */

char	*myname = NULL;

char	*persnr(char *);
char	*crdate(void);
void	display_error(char *, ...);


int	main(int argc, char *argv[])
{
	char		*p = NULL;
	register int	i;                /* Tellevariabel */
	int		retval = EXIT_OK,
			startnum = 499;   /* Avhengig av next_century */
	char		buf[12], birthdate[20], tmpbuf[12], century[3];
	char		next_century = 0; /* 0 = 499 og nedover, 1 = 999 og nedover */

#if C_SECURITY

	/*
	 * Det som kommer her er det lagt inn beskyttelse p† s† det er
	 * vanskelig † patche det bort. Dette programmet skal ikke kopieres
	 * vilt og uhemmet, s† hvis noen f†r en kopi, skal det skrives her
	 * hvem som f†r den, og datoen. N†r det er skrevet, skal alle
	 * linjene sorteres s† de kommer hulter til bulter. De hexadesimale
	 * tallene er valgt helt tilfeldig og skal forhindre at man bruker
	 * f.eks. STRINGS for † lete etter tekst.
	 */

        /* 102 */
        /* 007 */ s[  6] = ' ';
        /* 015 */ s[ 14] = ' ';
        /* 019 */ s[ 18] = ' ';
        /* 028 */ s[ 27] = ' ';
        /* 033 */ s[ 32] = ' ';
        /* 038 */ s[ 37] = ' ';
        /* 047 */ s[ 46] = ' ';
        /* 190 */ ss[8] = /* */ '\xAE';
        /* 054 */ s[ 53] = '!';
        /* 172 */ ss[6] = /*!*/ '\xF4';
        /* 178 */ ss[9] = /*"*/ '\xF7';
        /* 177 */ ss[4] = /*#*/ '\xFB';
        /* 179 */ ss[4] = /*%*/ '\x0A';
        /* 174 */ ss[3] = /*,*/ '\x08';
        /* 188 */ ss[8] = /*,*/ '\x1A';
        /* 175 */ ss[7] = /*-*/ '\x12';
        /* 027 */ s[ 26] = '.';
        /* 173 */ ss[8] = /*.*/ '\xAC';
        /* 130 */ ss[8] = /*0*/ '\x08';
        /* 139 */ ss[0] = /*1*/ '\xF5';
        /* 193 */ ss[5] = /*1*/ '\xFD';
        /* 138 */ ss[2] = /*2*/ '\xE1';
        /* 137 */ ss[1] = /*3*/ '\xD4';
        /* 192 */ ss[9] = /*4*/ '\xE4';
        /* 136 */ ss[7] = /*4*/ '\xF1';
        /* 196 */ ss[7] = /*5*/ '\xB2';
        /* 135 */ ss[4] = /*5*/ '\xF3';
        /* 195 */ ss[0] = /*6*/ '\x0C';
        /* 134 */ ss[7] = /*6*/ '\xB2';
        /* 133 */ ss[3] = /*7*/ '\xAF';
        /* 191 */ ss[5] = /*7*/ '\xDF';
        /* 132 */ ss[8] = /*8*/ '\xEE';
        /* 131 */ ss[3] = /*9*/ '\x1A';
        /* 176 */ ss[9] = /*?*/ '\xCE';
        /* 147 */ ss[9] = /*A*/ '\xD9';
        /* 142 */ ss[5] = /*B*/ '\x06';
        /* 144 */ ss[7] = /*C*/ '\xD3';
        /* 149 */ ss[9] = /*D*/ '\xE9';
        /* 037 */ s[ 36] = 'E';
        /* 166 */ ss[6] = /*E*/ '\xA7';
        /* 150 */ ss[4] = /*F*/ '\xF3';
        /* 184 */ ss[4] = /*G*/ '\x03';
        /* 151 */ ss[8] = /*G*/ '\xA2';
        /* 152 */ ss[6] = /*H*/ '\xE3';
        /* 034 */ s[ 33] = 'I';
        /* 161 */ ss[0] = /*I*/ '\xDE';
        /* 153 */ ss[1] = /*J*/ '\xDA';
        /* 035 */ s[ 34] = 'K';
        /* 036 */ s[ 35] = 'K';
        /* 154 */ ss[3] = /*K*/ '\xEB';
        /* 155 */ ss[2] = /*L*/ '\xDE';
        /* 140 */ ss[9] = /*M*/ '\xF9';
        /* 141 */ ss[8] = /*N*/ '\xE2';
        /* 160 */ ss[8] = /*O*/ '\xEA';
        /* 001 */ s[  0] = 'P';
        /* 159 */ ss[9] = /*P*/ '\xBB';
        /* 168 */ ss[6] = /*Q*/ '\x01';
        /* 165 */ ss[8] = /*R*/ '\x1E';
        /* 020 */ s[ 19] = 'S';
        /* 029 */ s[ 28] = 'S';
        /* 148 */ ss[5] = /*S*/ '\xA7';
        /* 164 */ ss[5] = /*T*/ '\xAC';
        /* 162 */ ss[6] = /*U*/ '\xFE';
        /* 143 */ ss[6] = /*V*/ '\x15';
        /* 023 */ s[ 22] = 'W';
        /* 167 */ ss[8] = /*W*/ '\x1F';
        /* 145 */ ss[4] = /*X*/ '\xA5';
        /* 163 */ ss[8] = /*Y*/ '\xCC';
        /* 146 */ ss[7] = /*Z*/ '\xD8';
        /* 055 */ s[ 54] = '\0';
        /* 056 */ s[ 55] = '\0';
        /* 057 */ s[ 56] = '\0';
        /* 058 */ s[ 57] = '\0';
        /* 059 */ s[ 58] = '\0';
        /* 060 */ s[ 59] = '\0';
        /* 061 */ s[ 60] = '\0';
        /* 062 */ s[ 61] = '\0';
        /* 063 */ s[ 62] = '\0';
        /* 064 */ s[ 63] = '\0';
        /* 065 */ s[ 64] = '\0';
        /* 066 */ s[ 65] = '\0';
        /* 067 */ s[ 66] = '\0';
        /* 068 */ s[ 67] = '\0';
        /* 069 */ s[ 68] = '\0';
        /* 070 */ s[ 69] = '\0';
        /* 071 */ s[ 70] = '\0';
        /* 072 */ s[ 71] = '\0';
        /* 073 */ s[ 72] = '\0';
        /* 074 */ s[ 73] = '\0';
        /* 075 */ s[ 74] = '\0';
        /* 076 */ s[ 75] = '\0';
        /* 077 */ s[ 76] = '\0';
        /* 078 */ s[ 77] = '\0';
        /* 079 */ s[ 78] = '\0';
        /* 080 */ s[ 79] = '\0';
        /* 081 */ s[ 80] = '\0';
        /* 082 */ s[ 81] = '\0';
        /* 083 */ s[ 82] = '\0';
        /* 084 */ s[ 83] = '\0';
        /* 085 */ s[ 84] = '\0';
        /* 086 */ s[ 85] = '\0';
        /* 087 */ s[ 86] = '\0';
        /* 088 */ s[ 87] = '\0';
        /* 089 */ s[ 88] = '\0';
        /* 090 */ s[ 89] = '\0';
        /* 091 */ s[ 90] = '\0';
        /* 092 */ s[ 91] = '\0';
        /* 093 */ s[ 92] = '\0';
        /* 094 */ s[ 93] = '\0';
        /* 095 */ s[ 94] = '\0';
        /* 096 */ s[ 95] = '\0';
        /* 097 */ s[ 96] = '\0';
        /* 098 */ s[ 97] = '\0';
        /* 099 */ s[ 98] = '\0';
        /* 100 */ s[ 99] = '\0';
        /* 101 */ s[100] = '\0';
        /* 005 */ s[  4] = 'a';
        /* 024 */ s[ 23] = 'a';
        /* 031 */ s[ 30] = 'a';
        /* 114 */ ss[8] = /*a*/ '\x92';
        /* 127 */ ss[9] = /*b*/ '\x0E';
        /* 189 */ ss[5] = /*b*/ '\x1B';
        /* 125 */ ss[6] = /*c*/ '\xD0';
        /* 050 */ s[ 49] = 'd';
        /* 116 */ ss[3] = /*d*/ '\xE6';
        /* 009 */ s[  8] = 'e';
        /* 026 */ s[ 25] = 'e';
        /* 043 */ s[ 42] = 'e';
        /* 045 */ s[ 44] = 'e';
        /* 051 */ s[ 50] = 'e';
        /* 053 */ s[ 52] = 'e';
        /* 180 */ ss[3] = /*e*/ '\xA0';
        /* 105 */ ss[4] = /*e*/ '\xDA';
        /* 203 */ ss[3] = /*e*/ '\xFA';
        /* 016 */ s[ 15] = 'f';
        /* 199 */ ss[0] = /*f*/ '\x42';
        /* 117 */ ss[5] = /*f*/ '\x95';
        /* 109 */ ss[1] = /*g*/ '\x01';
        /* 118 */ ss[7] = /*g*/ '\xC9';
        /* 119 */ ss[4] = /*h*/ '\xAA';
        /* 197 */ ss[0] = /*h*/ '\xB7';
        /* 198 */ ss[5] = /*h*/ '\xC5';
        /* 003 */ s[  2] = 'i';
        /* 042 */ s[ 41] = 'i';
        /* 049 */ s[ 48] = 'i';
        /* 200 */ ss[6] = /*i*/ '\xAC';
        /* 111 */ ss[4] = /*i*/ '\xDC';
        /* 012 */ s[ 11] = 'j';
        /* 120 */ ss[4] = /*j*/ '\x1B';
        /* 030 */ s[ 29] = 'k';
        /* 039 */ s[ 38] = 'k';
        /* 121 */ ss[6] = /*k*/ '\x0C';
        /* 187 */ ss[5] = /*k*/ '\x19';
        /* 032 */ s[ 31] = 'l';
        /* 122 */ ss[7] = /*l*/ '\x1E';
        /* 129 */ ss[5] = /*m*/ '\xE3';
        /* 014 */ s[ 13] = 'n';
        /* 022 */ s[ 21] = 'n';
        /* 185 */ ss[2] = /*n*/ '\x08';
        /* 128 */ ss[2] = /*n*/ '\xD5';
        /* 013 */ s[ 12] = 'o';
        /* 017 */ s[ 16] = 'o';
        /* 040 */ s[ 39] = 'o';
        /* 112 */ ss[6] = /*o*/ '\xEB';
        /* 041 */ s[ 40] = 'p';
        /* 113 */ ss[7] = /*p*/ '\x8E';
        /* 103 */ ss[6] = /*q*/ '\xF5';
        /* 002 */ s[  1] = 'r';
        /* 010 */ s[  9] = 'r';
        /* 018 */ s[ 17] = 'r';
        /* 025 */ s[ 24] = 'r';
        /* 044 */ s[ 43] = 'r';
        /* 052 */ s[ 51] = 'r';
        /* 106 */ ss[0] = /*r*/ '\xCB';
        /* 182 */ ss[8] = /*r*/ '\xEB';
        /* 011 */ s[ 10] = 's';
        /* 046 */ s[ 45] = 's';
        /* 181 */ ss[6] = /*s*/ '\x18';
        /* 115 */ ss[9] = /*s*/ '\xD3';
        /* 006 */ s[  5] = 't';
        /* 183 */ ss[5] = /*t*/ '\x1A';
        /* 107 */ ss[9] = /*t*/ '\x1D';
        /* 202 */ ss[4] = /*t*/ '\x1E';
        /* 201 */ ss[5] = /*t*/ '\x7B';
        /* 021 */ s[ 20] = 'u';
        /* 110 */ ss[5] = /*u*/ '\xF0';
        /* 004 */ s[  3] = 'v';
        /* 008 */ s[  7] = 'v';
        /* 048 */ s[ 47] = 'v';
        /* 126 */ ss[0] = /*v*/ '\x1D';
        /* 186 */ ss[3] = /*w*/ '\x04';
        /* 104 */ ss[8] = /*w*/ '\xE8';
        /* 124 */ ss[2] = /*x*/ '\xE1';
        /* 108 */ ss[8] = /*y*/ '\xAE';
        /* 123 */ ss[1] = /*z*/ '\xCF';
        /* 194 */ ss[8] = /*|*/ '\xC7';
        /* 169 */ ss[7] = /*†*/ '\xB0';
        /* 158 */ ss[6] = /**/ '\xAB';
        /* 171 */ ss[5] = /*‘*/ '\xCB';
        /* 157 */ ss[7] = /*’*/ '\x1A';
        /* 170 */ ss[8] = /*›*/ '\xDA';
        /* 156 */ ss[4] = /**/ '\x03';

#endif /* if C_SECURITY */

	p = strrchr(argv[0], '\\');
	myname = (!p ? argv[0] : ++p);
	p = strrchr(myname, '.');
	if (p)
		*p = '\0';

	if (!strcmp(argv[1], "?") || !strcmp(argv[1], "/?") || !strcmp(argv[1], "-?"))
	{
		int	charnum; /* Cosmetic thing... */

		fprintf(stderr, MSG_SYN_VER, PROG_NAME, VERSION, MSG_LANGUAGE, OS_NAME);
		charnum = fprintf(stderr, MSG_SYN_MADEBY, AUTHOR, crdate());
		fputc('\n', stderr);

#if C_SECURITY

	/*
	 * Den som kommer n† ligger to steder i programmet.
	 */

	for (i = 0; s[i] && (2+2==4) && (100/5==20) && 1; i++) /* Bare for † forvirre */
	{
		security ^= ~(s[i]*1969);
		fputc(s[i], stderr);
	}

	fputc('\n', stderr);

#if C_SECURITY == 2

	/*
	 * Hvis C_SECURITY er satt til 2, skrives verdien ut av security, og
	 * programmet stopper. Det er bare for † f† greie p† hva koden er.
	 * C_SECURITY skal ellers BESTANDIG v‘re 1.
	 */

	fprintf(stderr, "\n%04X\n", security);
	exit(EXIT_ERROR);

#endif /* if C_SECURITY == 2 */
#endif /* if C_SECURITY */

		for (; charnum; charnum--)
			fputc('-', stderr);
		fprintf(stderr, MSG_SYN_USAGE, myname);
		fprintf(stderr, MSG_SYN_TXT);
#if C_DEBUG
		fprintf(stderr, MSG_SYN_DEBUGVER, C_DEBUG);
#ifdef __STDC__
		fprintf(stderr, "__STDC__ = %d\n\n", __STDC__);
#endif /* ifdef __STDC__ */
#endif C_DEBUG /* if C_DEBUG */
		retval = EXIT_ERROR;
		goto endfunc;
	}

#if C_SECURITY
	/*
	 * Den som kommer n† ligger to steder i programmet.
	 */

	for (i = 0; s[i] && (2+2==4) && (100/5==20) && 1; i++) /* Bare for † forvirre */
	{
		security ^= ~(s[i]*1969);
	}

#if C_SECURITY == 2

	/*
	 * Hvis C_SECURITY er satt til 2, skrives verdien ut av security, og
	 * programmet stopper. Det er bare for † f† greie p† hva koden er.
	 * C_SECURITY skal ellers BESTANDIG v‘re 1.
	 */

	fprintf(stderr, "\n%04X\n", security);
	exit(EXIT_ERROR);

#endif /* if C_SECURITY == 2 */
#endif /* if C_SECURITY */

	if (argc > 2)
		display_error(ERR_TOO_MANY_PARAMS, myname);

	check_secur();
	fprintf(stderr, "\n%s\n\n", MSG_STARTHEADER);

	if (argc == 1)
	{
		fprintf(stderr, MSG_ASK_BIRTHDATE);
		scanf("%15s", birthdate);
		check_secur();
		fputc('\n', stderr);
	}
	else
		sprintf(birthdate, "%.15s", argv[1]);

	if ((strlen(birthdate) != 6) && (strlen(birthdate) != 8)) /* Sjekk at lengden p† datoen er seks eller †tte tegn */
		display_error(ERR_INVALID_PARAMLEN);

	strcpy(century, "19"); /* Default †rhundre er 1900 */

	/*
	 * Her kommer det en sjekk som finner ut om det er spesifisert et
	 * annet †rhundre, f.eks. 17081889, dvs. to ekstra siffer i †ret.
	 */

	if (strlen(birthdate) == 8)
	{
		strncpy(century, birthdate + 4, 2); /* Nytt †rhundre p† gang */
		next_century = (atoi(century) % 2) ? 0 : 1;

		strcpy(tmpbuf, birthdate);
		sprintf(birthdate, "%c%c%c%c%c%c",
		  birthdate[0],
		  birthdate[1],
		  birthdate[2],
		  birthdate[3],
		  birthdate[6],
		  birthdate[7]);
	}

	startnum = next_century ? 999 : 499; /* Hvilket †rhundre skal brukes? */

	fprintf(stdout, MSG_HEADER,
	  birthdate[0],
	  birthdate[1],
	  birthdate[2],
	  birthdate[3],
	  century,
	  birthdate[4],
	  birthdate[5]);

	fprintf(stdout, "%s\n\n", MSG_MALE);
	for (i = startnum; i >= (startnum-499); i -= 2)
	{
		sprintf(buf, "%s%03.3d\n", birthdate, i);
		strcpy(tmpbuf, persnr(buf));
		if (!strlen(tmpbuf))
			continue;
		fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
	}

	fprintf(stdout, "\n%s\n\n", MSG_FEMALE);
	for (i = (startnum-1); i >= (startnum-499); i -= 2)
	{
		sprintf(buf, "%s%03.3d\n", birthdate, i);
		strcpy(tmpbuf, persnr(buf));
		if (!strlen(tmpbuf))
			continue;
		fprintf(stdout, "%6.6s-%5.5s\n", tmpbuf, tmpbuf + 6);
	}

	fprintf(stdout, "\n%s\n", MSG_END_OF_LIST);

endfunc:
;
	fcloseall();
	return(retval);
} /* main() */


char	*persnr(char *orgbuf)
{
	int		x, y;
	float		j, k;
	static char	buf[12];

	strcpy(buf, orgbuf);

	x = c2i(buf[0])*3 + c2i(buf[1])*7 + c2i(buf[2])*6 + c2i(buf[3])*1 + \
	    c2i(buf[4])*8 + c2i(buf[5])*9 + c2i(buf[6])*4 + c2i(buf[7])*5 + c2i(buf[8])*2;

	j = 11 * (1 - frac((float)x / 11));
	if (frac(j) >= 0.5) /* Avrunding til n‘rmeste ener */
		j++;
	j = (int)j; /* Stryk alle desimalene */

	check_secur();

	y = c2i(buf[0])*5 + c2i(buf[1])*4 + c2i(buf[2])*3 + c2i(buf[3])*2 + \
	    c2i(buf[4])*7 + c2i(buf[5])*6 + c2i(buf[6])*5 + c2i(buf[7])*4 + \
	    c2i(buf[8])*3 + j*2;

	k = 11 * (1 - frac((float)y / 11));
	if (frac(k) >= 0.5) /* Avrunding til n‘rmeste ener */
		k++;
	k = (int)k; /* Bort med alle desimalene */

	if (j == 10 || k == 10) /* Hvis j eller k == 10 er nummeret falskt */
	{
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
} /* persnr() */


/********************************************************************
 * FUNCTION:
 *  char *crdate(void);
 *
 * ARGUMENTS:
 *   None.
 *
 * DESCRIPTION:
 *   Returns pointer to string containing the date the file was compiled.
 *   The date has the following format: dd-Mmm-yyyy hh:mm:ss.
 *
 * RETURNS:
 *   Pointer to string with compile date.
 *
 */

char	*crdate(void)
{
	static char	buf[30], datebuf[30];
	char		*a[5];
	int		t;

	strcpy(datebuf, __DATE__);

	a[0] = strtok(datebuf, " ");

	for (t = 1; t < 3; t++)
		a[t] = strtok(NULL, " ");

	sprintf(buf, "%s-%s-%s %s", a[1], a[0], a[2], __TIME__);

	return(buf);
} /* crdate() */


/********************************************************************
 * FUNCTION:
 *   void display_error(char *, ...)
 *
 * ARGUMENTS:
 *   char *p; String with error message (printf() format)
 *
 * DESCRIPTION:
 *   This function writes an error message to stderr and then exits the
 *   program. It is done this way to prevent duplication of code.
 *
 * RETURNS:
 *   Nothing.
 *
 */

void	display_error(char *p, ...)
{
	va_list	argptr;

	fprintf(stderr, MSG_ERROR, PROG_NAME);

	va_start(argptr, p);
	vfprintf(stderr, p, argptr);
	va_end(argptr);
	fprintf(stderr, "\n");

	fcloseall();
	exit(EXIT_ERROR);
} /* display_error() */

/******** END OF FILE ********/
