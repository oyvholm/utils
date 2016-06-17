
/*
 * STDexecDTS.c
 * File ID: STDuuidDTS
 *
 * (C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>
 *
 * This program is free software; you can redistribute it and/or modify 
 * it under the terms of the GNU General Public License as published by 
 * the Free Software Foundation; either version 2 of the License, or (at 
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "STDexecDTS.h"
#include "version.h"

/*
 * Global variables
 */

char *progname;
int debug = 0;

/*
 * print_license() - Display the program license
 */

void print_license(void)
{
	puts("(C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>\n");
	puts("\n");
	puts("This program is free software; you can redistribute it "
	     "and/or modify it \n"
	     "under the terms of the GNU General Public License as "
	     "published by the \n"
	     "Free Software Foundation; either version 2 of the License, "
	     "or (at your \n"
	     "option) any later version.\n");
	puts("\n");
	puts("This program is distributed in the hope that it will be "
	     "useful, but \n"
	     "WITHOUT ANY WARRANTY; without even the implied warranty of \n"
	     "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  "
	     "See the GNU \n"
	     "General Public License for more details.\n");
	puts("\n");
	puts("You should have received a copy of "
	     "the GNU General Public License along \n"
	     "with this program; if not, write to "
	     "the Free Software Foundation, Inc., \n"
	     "59 Temple Place, Suite 330, Boston, MA  02111-1307  USA\n");
}

/*
 * print_version() - Print version information on stdout
 */

void print_version(void)
{
	fprintf(stdout, "%s %s\n", progname, VERSION);
}

/*
 * usage() - Prints a help screen
 */

void usage(int retval)
{
	if (retval != EXIT_OK)
		fprintf(stderr, "\nType \"%s --help\" for help screen. "
			"Returning with value %d.\n", progname, retval);
	else {
		fprintf(stdout, "\n");
		print_version();
		printf("Usage: %s [options] [file [files [...]]]\n", progname);
		puts("\n");
		puts("Options:\n");
		puts("\n");
		puts("  -h, --help\n"
		     "    Show this help.\n");
		puts("  --license\n"
		     "    Print the software license\n");
		puts("  -v, --verbose\n"
		     "    Increase level of verbosity. Can be repeated.\n");
		puts("  --version\n"
		     "    Print version information.\n");
		puts("  --debug\n"
		     "    Print debugging messages.\n"
		     "\n");
	}
}

/*
 * main()
 */

int main(int argc, char *argv[])
{
	int c;
	int retval = EXIT_OK;

	progname = argv[0];

	while (1) {
		int option_index = 0;
		static struct option long_options[] = {
			{"debug", no_argument, 0, 0},
			{"help", no_argument, 0, 'h'},
			{"license", no_argument, 0, 0},
			{"version", no_argument, 0, 'V'},
			{0, 0, 0, 0}
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

		c = getopt_long(argc, argv, "hV", long_options, &option_index);

		if (c == -1)
			break;

		switch (c) {
		case 0:
			if (!strcmp(long_options[option_index].name, "debug"))
				debug = 1;
			else if (!strcmp(long_options[option_index].name,
					 "license")
			    ) {
				print_license();
				return EXIT_OK;
			}
#if 0
			fprintf(stddebug, "option %s",
				long_options[option_index].name);
			if (optarg)
				fprintf(stddebug, " with arg %s", optarg);
			fprintf(stddebug, "\n");
#endif /* if 0 */
			break;
		case 'h':
			usage(EXIT_OK);
			return EXIT_OK;
		case 'V':
			print_version();
			return EXIT_OK;
		default:
			debpr1("getopt_long() returned "
			       "character code %d\n", c);
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
		int t;

		for (t = optind; t < argc; t++)
			retval |= process_file(argv[t]);
	} else
		retval |= process_file("-");
	 */

	/* ...and stops here */

	debpr1("Returning from main() with value %d\n", retval);

	return retval;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w fenc=UTF-8 : */
