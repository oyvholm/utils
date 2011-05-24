
/*
 * [Beskrivelse]
 * File ID: STDuuidDTS
 *
 * (C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

#include "std.h"
#include "version.h"

/*
 * Function prototypes
 */

void print_version(void);
void usage(int);

/*
 * Global variables
 */

char *progname;
int  debug = 0;

/*
 * main()
 */

int main(int argc, char *argv[])
{
	int c,
		retval = EXIT_OK;

	progname = argv[0];

	while (1)
	{
		int option_index = 0;
		static struct option long_options[] = {
			{  "debug", 0, 0,   0},
			{   "help", 0, 0, 'h'},
#ifdef C_LICENSE
			{"license", 0, 0,   0},
#endif
			{"version", 0, 0, 'V'},
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

		switch (c) {
			case 0 :
				if (!strcmp(long_options[option_index].name, "debug"))
					debug = 1;

#ifdef C_LICENSE
				else if (!strcmp(long_options[option_index].name, "license"))
				{
					fprintf(stdout,
						"(C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>\n"
						"\n"
						"This program is free software: you can redistribute it and/or modify\n"
						"it under the terms of the GNU General Public License as published by\n"
						"the Free Software Foundation, either version 3 of the License, or\n"
						"(at your option) any later version.\n"
						"\n"
						"This program is distributed in the hope that it will be useful,\n"
						"but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
						"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
						"GNU General Public License for more details.\n"
						"\n"
						"You should have received a copy of the GNU General Public License\n"
						"along with this program.  If not, see <http://www.gnu.org/licenses/>.\n"
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

			default :
				debpr1("getopt_long() returned character code %d\n", c);
				break;
		}
	}

	debpr1("debugging is set to level %d\n", debug);

	if (debug && optind < argc) {
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
	if (optind < argc) {
		int  t;

		for (t = optind; t < argc; t++)
			retval |= process_file(argv[t]);
	} else
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
	fprintf(stdout, "%s version %s - %s\n", progname, VERSION, RELEASE_DATE);
} /* print_version() */

/*
 * usage() - Prints a help screen
 */

void usage(int retval)
{
	if (retval != EXIT_OK)
		fprintf(stderr, "\nType \"%s --help\" for help screen. Returning with value %d.\n", progname, retval);
	else {
		fprintf(stdout, "\n");
		print_version();
		fprintf(stdout,
			"\n"
			"Usage: %s [options]\n"
			"\n"
			"Options:\n"
			"\n"
			"-h, --help	 Show this help screen and exit gracefully\n"
			"-V, --version  Display version information\n"
#ifdef C_LICENSE
			"    --license  Print the software license\n"
#endif
			"\n"
			"Undocumented options (May disappear in future versions):\n"
			"\n"
			"    --debug    Print lots of annoying debug information\n"
			"\n", progname
		);
	}

	exit(retval);
} /* usage() */

/* vim: set ts=8 sw=8 sts=8 noet fo+=w fenc=UTF-8 : */
