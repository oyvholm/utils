/*
 * STDfilenameDTS
 * File ID: STDuuidDTS
 *
 * (C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>
 *
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "STDexecDTS.h"

/*
 * Global variables
 */

const char *progname;
struct Options opt;

/*
 * msg() - Print a message prefixed with "[progname]: " to stddebug if the 
 * current verbose level is equal or higher than the first argument. The rest 
 * of the arguments are delivered to vfprintf().
 * Returns the number of characters written.
 */

int msg(const int verbose, const char *format, ...)
{
	int retval = 0;

	assert(format);
	assert(strlen(format));

	if (opt.verbose >= verbose) {
		va_list ap;

		va_start(ap, format);
		retval = fprintf(stddebug, "%s: ", progname);
		retval += vfprintf(stddebug, format, ap);
		retval += fprintf(stddebug, "\n");
		va_end(ap);
	}

	return retval;
}

/*
 * myerror() - Print an error message to stderr using this format:
 *   a: b: c
 * where a is the name of the program (progname), b is the output from the 
 * printf-like string and optional arguments, and c is the error message from 
 * errno. Returns the number of characters written.
 */

int myerror(const char *format, ...)
{
	va_list ap;
	int retval = 0;
	const int orig_errno = errno;

	assert(format);
	assert(strlen(format));

	retval = fprintf(stderr, "%s: ", progname);
	va_start(ap, format);
	retval += vfprintf(stderr, format, ap);
	va_end(ap);
	if (orig_errno)
		retval += fprintf(stderr, ": %s", strerror(orig_errno));
	retval += fprintf(stderr, "\n");

	return retval;
}

/*
 * print_license() - Display the program license. Returns EXIT_SUCCESS.
 */

static int print_license(void)
{
	puts("(C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>");
	puts("");
	puts("This program is free software; you can redistribute it"
	     " and/or modify it \n"
	     "under the terms of the GNU General Public License as"
	     " published by the \n"
	     "Free Software Foundation; either version 2 of the License,"
	     " or (at your \n"
	     "option) any later version.");
	puts("");
	puts("This program is distributed in the hope that it will be"
	     " useful, but \n"
	     "WITHOUT ANY WARRANTY; without even the implied warranty of \n"
	     "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.");
	puts("See the GNU General Public License for more details.");
	puts("");
	puts("You should have received a copy of"
	     " the GNU General Public License along \n"
	     "with this program. If not, see"
	     " <http://www.gnu.org/licenses/>.");

	return EXIT_SUCCESS;
}

/*
 * print_version() - Print version information on stdout. Returns EXIT_SUCCESS.
 */

static int print_version(void)
{
	if (opt.verbose < 0) {
		puts(EXEC_VERSION);
		return EXIT_SUCCESS;
	}
	printf("%s %s (%s)\n", progname, EXEC_VERSION, EXEC_DATE);
#ifdef GCOV
	printf("has GCOV\n");
#endif
#ifdef NDEBUG
	printf("has NDEBUG\n");
#endif
#ifdef PROF
	printf("has PROF\n");
#endif
#ifdef UNUSED
	printf("has UNUSED\n");
#endif

	return EXIT_SUCCESS;
}

/*
 * usage() - Prints a help screen. Returns retval.
 */

static int usage(const int retval)
{
	if (retval != EXIT_SUCCESS) {
		fprintf(stderr, "Type \"%s --help\" for help screen."
		                " Returning with value %d.\n",
		                progname, retval);
		return retval;
	}
	puts("");
	if (opt.verbose >= 1) {
		print_version();
		puts("");
	}
	printf("Usage: %s [options]\n", progname);
	printf("\n");
	printf("Options:\n");
	printf("\n");
	printf("  -h, --help\n"
	       "    Show this help.\n");
	printf("  --license\n"
	       "    Print the software license.\n");
	printf("  -q, --quiet\n"
	       "    Be more quiet. Can be repeated to increase silence.\n");
	printf("  -v, --verbose\n"
	       "    Increase level of verbosity. Can be repeated.\n");
	printf("  --selftest\n"
	       "    Run the built-in test suite.\n");
	printf("  --version\n"
	       "    Print version information.\n");
	printf("\n");

	return retval;
}

/*
 * choose_opt_action() - Decide what to do when option `c` is found. Read 
 * definitions for long options from `opts`.
 * Returns EXIT_SUCCESS if ok, EXIT_FAILURE if `c` is unknown or anything 
 * fails.
 */

static int choose_opt_action(const int c, const struct option *opts)
{
	int retval = EXIT_SUCCESS;

	assert(opts);

	switch (c) {
	case 0:
		if (!strcmp(opts->name, "license"))
			opt.license = true;
		else if (!strcmp(opts->name, "selftest"))
			opt.selftest = true;
		else if (!strcmp(opts->name, "version"))
			opt.version = true;
		break;
	case 'h':
		opt.help = true;
		break;
	case 'q':
		opt.verbose--;
		break;
	case 'v':
		opt.verbose++;
		break;
	default:
		msg(4, "%s(): getopt_long() returned character code %d",
		       __func__, c);
		retval = EXIT_FAILURE;
		break;
	}

	return retval;
}

/*
 * parse_options() - Parse command line options.
 * Returns EXIT_SUCCESS if ok, EXIT_FAILURE if error.
 */

static int parse_options(const int argc, char * const argv[])
{
	int retval = EXIT_SUCCESS;

	assert(argv);

	opt.help = false;
	opt.license = false;
	opt.selftest = false;
	opt.verbose = 0;
	opt.version = false;

	while (retval == EXIT_SUCCESS) {
		int c;
		int option_index = 0;
		static const struct option long_options[] = {
			{"help", no_argument, NULL, 'h'},
			{"license", no_argument, NULL, 0},
			{"quiet", no_argument, NULL, 'q'},
			{"selftest", no_argument, NULL, 0},
			{"verbose", no_argument, NULL, 'v'},
			{"version", no_argument, NULL, 0},
			{0, 0, 0, 0}
		};

		c = getopt_long(argc, argv,
		                "h"  /* --help */
		                "q"  /* --quiet */
		                "v"  /* --verbose */
		                , long_options, &option_index);
		if (c == -1)
			break;
		retval = choose_opt_action(c, &long_options[option_index]);
	}

	return retval;
}

/*
 * main()
 */

int main(int argc, char *argv[])
{
	int retval;

	progname = argv[0];
	errno = 0;

	retval = parse_options(argc, argv);
	if (retval != EXIT_SUCCESS) {
		myerror("Option error");
		return usage(EXIT_FAILURE);
	}

	msg(4, "%s(): Using verbose level %d", __func__, opt.verbose);
	msg(4, "%s(): argc = %d, optind = %d", __func__, argc, optind);

	if (opt.help)
		return usage(EXIT_SUCCESS);
	if (opt.selftest)
		return selftest();
	if (opt.version)
		return print_version();
	if (opt.license)
		return print_license();

	if (optind < argc) {
		int t;

		for (t = optind; t < argc; t++) {
			msg(4, "%s(): Non-option arg %d: %s",
			       __func__, t, argv[t]);
		}
	}

	msg(4, "Returning from %s() with value %d", __func__, retval);
	return retval;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
