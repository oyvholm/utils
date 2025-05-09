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

char *progname;
struct Options opt;

/*
 * msg() - Print a message prefixed with "[progname]: " to stderr if the 
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
		retval = fprintf(stderr, "%s: ", progname);
		retval += vfprintf(stderr, format, ap);
		retval += fprintf(stderr, "\n");
		va_end(ap);
	}

	return retval;
}

/*
 * std_strerror() - Replacement for `strerror()` that returns a predictable 
 * error message on every platform so the tests work everywhere.
 */

const char *std_strerror(const int errnum)
{
	switch (errnum) {
	case EACCES:
		return "Permission denied";
	default: /* gncov */
		/*
		 * Should never happen. If this line is executed, an `errno` 
		 * value is missing from `std_strerror()`, and tests may fail 
		 * on other platforms.
		 */
		fprintf(stderr, /* gncov */
		        "\n%s: %s(): Unknown errno received: %d, \"%s\"\n",
		        progname, __func__, errnum, strerror(errnum));
		return strerror(errnum); /* gncov */
	}
}

/*
 * myerror() - Print an error message to stderr using this format:
 *
 *     a: b: c
 *
 * where `a` is the name of the program (the value of `progname`), `b` is the 
 * output from the printf-like string and optional arguments, and `c` is the 
 * error message from `errno`.
 *
 * If `errno` contained an error value (!0), it is reset to 0.
 *
 * If `errno` indicates no error, the ": c" part is not printed. Returns the 
 * number of characters written.
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
	if (orig_errno) {
		retval += fprintf(stderr, ": %s", /* gncov */
		                          std_strerror(orig_errno));
		errno = 0; /* gncov */
	}
	retval += fprintf(stderr, "\n");

	return retval;
}

/*
 * print_license() - Display the program license. Returns `EXIT_SUCCESS`.
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
	     "with this program. If not, see <http://www.gnu.org/licenses/>.");

	return EXIT_SUCCESS;
}

/*
 * print_version() - Print version information on stdout. If `-q` is used, only 
 * the version number is printed. Returns `EXIT_SUCCESS`.
 */

static int print_version(void)
{
#ifdef FAKE_MEMLEAK
	char *p;

	p = malloc(100);
	if (p) { }
#endif

	if (opt.verbose < 0) {
		puts(EXEC_VERSION);
		return EXIT_SUCCESS;
	}
	printf("%s %s (%s)\n", progname, EXEC_VERSION, EXEC_DATE);
#ifdef FAKE_MEMLEAK
	printf("has FAKE_MEMLEAK\n");
#endif
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
#ifdef USE_NEW
	printf("has USE_NEW\n");
#endif

	return EXIT_SUCCESS;
}

/*
 * usage() - Prints a help screen. Returns `retval`.
 */

static int usage(const int retval)
{
	if (retval != EXIT_SUCCESS) {
		myerror("Type \"%s --help\" for help screen."
		        " Returning with value %d.", progname, retval);
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
	printf("  --selftest [arg]\n"
	       "    Run the built-in test suite. If specified, the argument"
	       " can contain \n"
	       "    one or more of these strings: \"exec\" (the tests use the"
	       " executable \n"
	       "    file), \"func\" (runs function tests), or \"all\"."
	       " Multiple strings \n"
	       "    should be separated by commas. If no argument is"
	       " specified, default \n"
	       "    is \"all\".\n");
	printf("  --valgrind [arg]\n"
	       "    Run the built-in test suite with Valgrind memory checking."
	       " Accepts \n"
	       "    the same optional argument as --selftest, with the same"
	       " defaults.\n");
	printf("  -v, --verbose\n"
	       "    Increase level of verbosity. Can be repeated.\n");
	printf("  --version\n"
	       "    Print version information.\n");
	printf("\n");

	return retval;
}

/*
 * choose_opt_action() - Decide what to do when option `c` is found. Store 
 * changes in `dest`. Read definitions for long options from `opts`.
 * Returns 0 if ok, or 1 if `c` is unknown or anything fails.
 */

static int choose_opt_action(struct Options *dest,
                             const int c, const struct option *opts)
{
	int retval = 0;

	assert(dest);
	assert(opts);

	switch (c) {
	case 0:
		if (!strcmp(opts->name, "license")) {
			dest->license = true;
		} else if (!strcmp(opts->name, "selftest")) {
			dest->selftest = true;
		} else if (!strcmp(opts->name, "valgrind")) {
			dest->valgrind = dest->selftest = true;
		} else if (!strcmp(opts->name, "version")) {
			dest->version = true;
		}
		break;
	case 'h':
		dest->help = true;
		break;
	case 'q':
		dest->verbose--;
		break;
	case 'v':
		dest->verbose++;
		break;
	default:
		myerror("%s(): getopt_long() returned character code %d",
		        __func__, c);
		retval = 1;
		break;
	}

	return retval;
}

/*
 * init_opt() - Initializes a `struct Options` with default values. Returns 
 * nothing.
 */

void init_opt(struct Options *dest)
{
	assert(dest);

	dest->help = false;
	dest->license = false;
	dest->selftest = false;
	dest->testexec = false;
	dest->testfunc = false;
	dest->valgrind = false;
	dest->verbose = 0;
	dest->version = false;
}

/*
 * parse_options() - Parse command line options.
 * Returns 0 if succesful, or 1 if an error occurs.
 */

static int parse_options(struct Options *dest,
                         const int argc, char * const argv[])
{
	int retval = 0;

	assert(dest);
	assert(argv);

	init_opt(dest);

	while (!retval) {
		int c;
		int option_index = 0;
		static const struct option long_options[] = {
			{"help", no_argument, NULL, 'h'},
			{"license", no_argument, NULL, 0},
			{"quiet", no_argument, NULL, 'q'},
			{"selftest", no_argument, NULL, 0},
			{"valgrind", no_argument, NULL, 0},
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
		retval = choose_opt_action(dest,
		                           c, &long_options[option_index]);
	}

	return retval;
}

/*
 * setup_options() - Do necessary changes to `o` based on the user input.
 *
 * - Parse the optional argument to --selftest and set `o->testexec` and 
 *   `o->testfunc`.
 *
 * Returns 0 if everything is ok, otherwise it returns 1.
 */

static int setup_options(struct Options *o, const int argc, char *argv[])
{
	if (o->selftest) {
		if (optind < argc) {
			const char *s = argv[optind];
			if (!s) {
				myerror("%s(): argv[optind] is" /* gncov */
				        " NULL", __func__);
				return 1; /* gncov */
			}
			if (strstr(s, "all"))
				o->testexec = o->testfunc = true; /* gncov */
			if (strstr(s, "exec"))
				o->testexec = true; /* gncov */
			if (strstr(s, "func"))
				o->testfunc = true; /* gncov */
		} else {
			o->testexec = o->testfunc = true;
		}
	}

	return 0;
}

/*
 * main()
 */

int main(int argc, char *argv[])
{
	int retval = EXIT_SUCCESS;

	progname = argv[0];
	errno = 0;

	if (parse_options(&opt, argc, argv)) {
		myerror("Option error");
		return usage(EXIT_FAILURE);
	}

	msg(4, "%s(): Using verbose level %d", __func__, opt.verbose);
	msg(4, "%s(): argc = %d, optind = %d", __func__, argc, optind);

	if (setup_options(&opt, argc, argv))
		return EXIT_FAILURE; /* gncov */

	if (opt.help)
		return usage(EXIT_SUCCESS);
	if (opt.selftest)
		return opt_selftest(progname);
	if (opt.version)
		return print_version();
	if (opt.license)
		return print_license();

	if (optind < argc) {
		int t;

		for (t = optind; t < argc; t++) { /* gncov */
			msg(4, "%s(): Non-option arg %d: %s", /* gncov */
			       __func__, t, argv[t]); /* gncov */
		}
	}

	check_errno;

	msg(4, "Returning from %s() with value %d", __func__, retval);
	return retval;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
