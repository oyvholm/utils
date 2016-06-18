
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
struct Options {
	int help;
	int verbose;
	int version;
} opt;

/*
 * print_license() - Display the program license
 */

void print_license(void)
{
	puts("(C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>");
	puts("");
	puts("This program is free software; you can redistribute it "
	     "and/or modify it \n"
	     "under the terms of the GNU General Public License as "
	     "published by the \n"
	     "Free Software Foundation; either version 2 of the License, "
	     "or (at your \n"
	     "option) any later version.");
	puts("");
	puts("This program is distributed in the hope that it will be "
	     "useful, but \n"
	     "WITHOUT ANY WARRANTY; without even the implied warranty of \n"
	     "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.");
	puts("See the GNU General Public License for more details.");
	puts("");
	puts("You should have received a copy of "
	     "the GNU General Public License along \n"
	     "with this program. If not, see "
	     "<http://www.gnu.org/licenses/>.");
}

/*
 * print_version() - Print version information on stdout
 */

void print_version(void)
{
	printf("%s %s\n", progname, VERSION);
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
		puts("");
		if (opt.verbose >= 1) {
			print_version();
			puts("");
		}
		printf("Usage: %s [options] [file [files [...]]]\n", progname);
		puts("");
		puts("Options:");
		puts("");
		puts("  -h, --help\n"
		     "    Show this help.");
		puts("  --license\n"
		     "    Print the software license");
		puts("  -q, --quiet\n"
		     "    Be more quiet. "
		     "Can be repeated to increase silence.");
		puts("  -v, --verbose\n"
		     "    Increase level of verbosity. Can be repeated.");
		puts("  --version\n"
		     "    Print version information.");
		puts("");
	}
}

/*
 * parse_options() - Parse command line options.
 * Returns 0 only, the return value is undefined at the moment.
 */

int parse_options(struct Options *dest, int argc, char *argv[]) {
	int retval = 0;
	int c;
	dest->help = 0;
	dest->verbose = 0;
	dest->version = 0;

	while (1) {
		int option_index = 0;
		static struct option long_options[] = {
			{"help", no_argument, 0, 'h'},
			{"license", no_argument, 0, 0},
			{"quiet", no_argument, 0, 'q'},
			{"verbose", no_argument, 0, 'v'},
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

		c = getopt_long(argc, argv, "hqvV", long_options,
				&option_index);

		if (c == -1)
			break;

		switch (c) {
		case 0:
			if (!strcmp(
				long_options[option_index].name, "license"
			)) {
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
			dest->help = 1;
			break;
		case 'q':
			dest->verbose--;
			break;
		case 'v':
			dest->verbose++;
			break;
		case 'V':
			dest->version = 1;
			break;
		default:
			msg1(2, "getopt_long() returned "
				"character code %d\n", c);
			break;
		}
	}

	if (opt.verbose >= 2 && optind < argc) {
		int t;

		fprintf(stddebug, "non-option args: ");
		for (t = optind; t < argc; t++)
			fprintf(stddebug, "%s ", argv[t]);

		fprintf(stddebug, "\n");
	}

	return(retval);
}

/*
 * main()
 */

int main(int argc, char *argv[])
{
	int retval = EXIT_OK;

	progname = argv[0];

	parse_options(&opt, argc, argv);

	msg1(2, "Using verbose level %d\n", opt.verbose);

	if (opt.help) {
		usage(EXIT_OK);
		return EXIT_OK;
	}

	if (opt.version) {
		print_version();
		return(EXIT_OK);
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

	msg1(2, "Returning from main() with value %d\n", retval);

	return retval;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w fenc=UTF-8 : */
