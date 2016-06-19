/*
 * STDfilenameDTS
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
 */

#include "STDexecDTS.h"
#include "version.h"

/*
 * Global variables
 */

char *progname;
struct Options {
	int help;
	int license;
	int verbose;
	int version;
} opt;

/*
 * msg() - Print a message prefixed with "[progname]: " to stddebug if 
 * opt.verbose is equal or higher than the first argument. The rest of 
 * the arguments are delivered to vfprintf().
 * Returns the number of characters written.
 */

int msg(int verbose, const char *format, ...)
{
	va_list ap;
	int retval = 0;
	if (opt.verbose >= verbose) {
		va_start(ap, format);
		retval = fprintf(stddebug, "%s: ", progname);
		retval += vfprintf(stddebug, format, ap);
		va_end(ap);
	}
	return retval;
}

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
 * choose_opt_action() - Decide what to do when option c is found. Store 
 * changes in dest. opts is the struct with the definitions for the long 
 * options.
 * Return EXIT_OK if ok, EXIT_ERROR if c is unknown.
 */

int choose_opt_action(struct Options *dest, int c, struct option *opts)
{
	int retval = EXIT_OK;

	switch (c) {
	case 0:
		if (!strcmp(opts->name, "license")) {
			dest->license = 1;
		} else if (!strcmp(opts->name, "version")) {
			dest->version = 1;
		}
		if (opt.verbose >= 2) {
			fprintf(stddebug, "%s: option %s",
					  progname, opts->name);
			if (optarg)
				fprintf(stddebug, " with arg %s", optarg);
			fprintf(stddebug, "\n");
		}
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
	default:
		msg(2, "getopt_long() returned "
		       "character code %d\n", c);
		retval = EXIT_ERROR;
		break;
	}

	return retval;
}

/*
 * parse_options() - Parse command line options.
 * Returns EXIT_OK if ok, EXIT_ERROR if error.
 */

int parse_options(struct Options *dest, int argc, char *argv[])
{
	int retval = EXIT_OK;
	int c;

	dest->help = 0;
	dest->license = 0;
	dest->verbose = 0;
	dest->version = 0;

	while (retval == EXIT_OK) {
		int option_index = 0;
		static struct option long_options[] = {
			{"help", no_argument, 0, 'h'},
			{"license", no_argument, 0, 0},
			{"quiet", no_argument, 0, 'q'},
			{"verbose", no_argument, 0, 'v'},
			{"version", no_argument, 0, 0},
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

		c = getopt_long(argc, argv, "hqv", long_options,
				&option_index);

		if (c == -1)
			break;

		retval = choose_opt_action(dest,
					   c, &long_options[option_index]);
	}

	if (opt.verbose >= 2 && optind < argc) {
		int t;

		fprintf(stddebug, "%s: non-option args: ", progname);
		for (t = optind; t < argc; t++)
			fprintf(stddebug, "%s ", argv[t]);

		fprintf(stddebug, "\n");
	}

	msg(3, "parse_options() returns %d\n", retval);
	return retval;
}

/*
 * process_file()
 */

int process_file(const char *fname)
{
	int retval = 0;
	msg(1, "Processing file '%s'\n", fname);
	return retval;
}

/*
 * main()
 */

int main(int argc, char *argv[])
{
	int retval = EXIT_OK;

	progname = argv[0];

	retval = parse_options(&opt, argc, argv);
	msg(3, "retval after parse_options(): %d\n", retval);
	if (retval != EXIT_OK) {
		fprintf(stderr, "%s: Option error\n", progname);
		return EXIT_ERROR;
	}

	msg(2, "Using verbose level %d\n", opt.verbose);

	if (opt.help) {
		usage(EXIT_OK);
		return EXIT_OK;
	}

	if (opt.version) {
		print_version();
		return EXIT_OK;
	}

	if (opt.license) {
		print_license();
		return EXIT_OK;
	}

	if (optind < argc) {
		int t;

		for (t = optind; t < argc; t++)
			retval |= process_file(argv[t]);
	}

	msg(2, "Returning from main() with value %d\n", retval);
	return retval;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w fenc=UTF-8 : */
