
/*
 * -
 *
 * (C)opyleft 1998 Oyvind A. Solheim <sunny@sunbase.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "getopt.h"

#include "std.h"

/*
 * Function prototypes
 */

void  print_version(void);
char  *date2iso(const char *);
void  usage(int);

/*
 * Global variables
 */

char  *progname;
int   debug = 0;
FILE  *stddebug = stderr;

/*
 * main()
 */

int  main (int argc, char *argv[])
{
  int  c,
       retval = EXIT_OK;

  progname = argv[0];

  while (1)
  {
    int option_index = 0;
    static struct option long_options[] =
    {
      {  "debug", 0, 0,   0},
      {   "help", 0, 0, 'h'},
#ifdef C_LICENSE
      {"license", 0, 0,   0},
#endif
      {"version", 0, 0, 'V'},
#ifdef C_PGPKEY
      { "pgpkey", 0, 0,   0},
#endif
      {        0, 0, 0,   0}
    };

    /*
     * long_options:
     *
     * 1. const char  *name;
     * 2. int         has_arg;
     * 3. int         *flag;
     * 4. int         val;
     *
     */

    c = getopt_long (argc, argv, "hV",
                     long_options, &option_index);

    if (c == -1)
      break;

    switch (c)
    {
      case 0 :
        if (!strcmp(long_options[option_index].name, "debug"))
          debug = 1;

#ifdef C_PGPKEY
        else
        if (!strcmp(long_options[option_index].name, "pgpkey"))
        {
          fprintf(stdout,
            "-----BEGIN PGP PUBLIC KEY BLOCK-----\n"
            "Version: 2.6.3i\n"
            "Comment: Public key for Oyvind A. Solheim <sunny@sunbase.com>\n"
            "\n"
            "mQCNAi3/mGcAAAEEAKUYYYgy/SXZ+Q+TQAmfaLPaRxB+MCBIY/MmACblmCLO1QQV\n"
            "61k/ANWdqHtJyOd/QSqLip6pk/s8mgUn2j35q8XeDhfih8FluGgLw11lhZcCHlls\n"
            "3BMuoP1Msrm7kf0tNLIoXYu2uyunFhmoG+vSEcXfhDNquzsqFQOm97MzWXiNAAUR\n"
            "tCVPeXZpbmQgQS4gU29saGVpbSA8c3VubnlAc3VuYmFzZS5jb20+iQEVAgUQNE/M\n"
            "MK2EZseekkgdAQGlDAf7B3IgDvrXVvENocsUazfZn7cgLvnkUBbe7NmFiWyE53Gi\n"
            "JMka3H3cvZlzWp8aykjQoG1HtrqU8jz3GH8++SdS1xxAdIzoaQ7ad0WkEtaVn3+0\n"
            "ZxXYs8W4HF6ttLR8c/8ucV6CLuJaaM60Uno9HWHYtfAWEjsWKp83A5gWhhScICqb\n"
            "42jq+c74hRDIrBFxQs+5Cfhv2b6dA8yWZpuUoZ50pFhBLdi1lYpCcUgA0qLpMoEd\n"
            "lfzoxASYaRLabGLC+tlj8kUQTyP0+I/n5zjxurGVNtJnZlILRSbx4ZuaDL8aPURP\n"
            "dgQ1n4IieVdeB+v62IBvkt4cuufQy0B5yOSGb53/ZYkAlQIFEDRNVJIDpvezM1l4\n"
            "jQEB8fEEAJcU1r1c31Jx76LpaRY+Qb8toBJf7pzXVVW8llV58fBHSe5iBm8b5IKd\n"
            "2BVFCuZ2rRj7mrOl5gLTb5BaVs+NRaQo7h1mY3OtoHrR1T437JUTNPDnFg6hdakT\n"
            "EX2voEj35d3TWSBcoP+7rX2VwbNrix5+Dcbq3OCxYvW0RVhcuPTP\n"
            "=L43t\n"
            "-----END PGP PUBLIC KEY BLOCK-----\n"
          );
          return(EXIT_OK);
        }
#endif /* ifdef C_PGPKEY */

#ifdef C_LICENSE
        else
        if (!strcmp(long_options[option_index].name, "license"))
        {
          fprintf(stdout,
           "Copyleft (C) %s %s\n"
           "\n"
           "This program is free software; you can redistribute it and/or modify\n"
           "it under the terms of the GNU General Public License as published by\n"
           "the Free Software Foundation; either version 2 of the License, or\n"
           "(at your option) any later version.\n"
           "\n"
           "This program is distributed in the hope that it will be useful,\n"
           "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
           "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
           "GNU General Public License for more details.\n"
           "\n"
           "You should have received a copy of the GNU General Public License\n"
           "along with this program; if not, write to the Free Software\n"
           "Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.\n",
           RELEASE_DATE, AUTHOR
          );
          return(EXIT_OK);
        }
#endif /* ifdef C_LICENSE */

#if 0
        fprintf(stddebug, "option %s", long_options[option_index].name);
        if (optarg)
          fprintf(stddebug, " with arg %s", optarg);
        fprintf(stddebug, "\n");
#endif /* if 0 */
        break;

      case 'h' :
        usage(EXIT_OK);
        break;

      case 'V' :
        print_version();
        return(EXIT_OK);

      case '?' :
        usage(EXIT_ERROR);
        break;

      default :
        debpr1("getopt_long() returned character code %d\n", c);
        break;
    }
  }

  debpr1("debugging is set to level %d\n", debug);

  if (debug && optind < argc)
  {
    int t;

    debpr0("non-option args: ");
    for (t = optind; t < argc; t++)
      fprintf(stddebug, "%s ", argv[t]);

    fprintf(stddebug, "\n");
  }

  /*
   * Code goes here
   */

/*
  if (optind < argc)
  {
    int  t;

    for (t = optind; t < argc; t++)
      retval |= process_file(argv[t]);
  }
  else
    retval |= process_file("-");
*/

  /* ...and stops here */

  debpr1("Returning from main() with value %d\n", retval);

  return(retval);
} /* main() */


/*
 * print_version() - Print version information on stdout
 */

void  print_version(void)
{
  fprintf(stdout, "%s ver. %s - %s - Compiled %s %s\n",
   progname, VERSION, RELEASE_DATE, date2iso(__DATE__), __TIME__);
} /* print_version() */


/*
 * date2iso() - Convert date format from "Mmm DD YYYY" into the format
 * specified by ISO 8601 and EN 28601, i.e. "YYYY-MM-DD".
 *
 * Return value: Character string with proper date format, or NULL
 * if some error.
 */

char	*date2iso(const char *s)
{
  static char buf[50];
  char datebuf[30], *a[5];
  char *months[] = {
                     "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                   };
  int t, y, m = 0, d;

  if (!s || !strchr(s, ' '))
    return(NULL);

  strncpy(datebuf, s, 29);
  a[0] = strtok(datebuf, " ");
  if (!a[0])
    return(NULL);

  for (t = 1; t < 3; t++)
  {
    a[t] = strtok(NULL, " ");

    if (!a[t] && t < 3)
      return(NULL);
  }

  y = strtoul(a[2], NULL, 10);
  d = strtoul(a[1], NULL, 10);

  for (t = 0; t < 12; t++)
  {
    if (!strncmp(a[0], months[t], 3))
    {
      m = t+1;
      break;
    }
  }

  if (!y || !m || !d)
    return(NULL);

  sprintf(buf, "%04u-%02u-%02u", y, m, d);

  return(buf);
} /* date2iso() */


/*
 * usage() - Prints a help screen
 */

void  usage(int retval)
{
  if (retval != EXIT_OK)
    fprintf(stderr, "\nType \"%s --help\" for help screen. Returning with value %d.\n", progname, retval);
  else
  {
    int  t;

    fprintf(stdout, "\n");
    print_version();
    t = fprintf(stdout, "(C)opyleft %s %s", RELEASE_DATE, AUTHOR);
    fputc('\n', stdout);

    for (; t; t--)
      fputc('-', stdout);

    fprintf(stdout,
     "\n"
     "Usage: %s [options]\n"
     "\n"
     "Options:\n"
     "\n"
     "-h, --help     Show this help screen and exit gracefully\n"
     "-V, --version  Display version information\n"
#ifdef C_LICENSE
     "    --license  Print the software license\n"
#endif
     "\n"
     "Undocumented options (May disappear in future versions):\n"
     "\n"
     "    --debug    Print lots of annoying debug information\n"
#ifdef C_PGPKEY
     "    --pgpkey   Print the PGP public key of the author to stdout\n"
#endif
     "\n", progname
    );
  }

  exit(retval);
} /* usage() */

/***** End of file *****/
