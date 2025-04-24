/*
 * selftest.c
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
 * The functions in this file are supposed to be compatible with `Test::More` 
 * in Perl 5 as far as possible.
 */

#define chp  (char *[])

static int testnum = 0;
static int failcount = 0;

/*
 * ok() - Print a log line to stdout. If `i` is 0, an "ok" line is printed, 
 * otherwise a "not ok" line is printed. `desc` is the test description and can 
 * use printf sequences.
 *
 * If `desc` is NULL, it returns 1. Otherwise, it returns `i`.
 */

static int ok(const int i, const char *desc, ...)
{
	va_list ap;

	if (!desc)
		return 1;
	va_start(ap, desc);
	printf("%sok %d - ", (i ? "not " : ""), ++testnum);
	vprintf(desc, ap);
	puts("");
	va_end(ap);
	fflush(stdout);
	failcount += !!i;

	return i;
}

/*
 * diag_output_va() - Receives a printf-like string and returns an allocated 
 * string, prefixed with "# " and all '\n' characters converted to "\n# ". 
 * Returns NULL if anything fails or `format` is NULL.
 */

static char *diag_output_va(const char *format, va_list ap)
{
	const char *src;
	char *buffer, *converted_buffer, *dst;
	int needed;
	size_t buffer_size = BUFSIZ, converted_size;
	va_list ap_copy;

	if (!format)
		return NULL; /* gncov */

	buffer = malloc(buffer_size);
	if (!buffer)
		return NULL; /* gncov */

	va_copy(ap_copy, ap);
	needed = vsnprintf(buffer, buffer_size, format, ap);

	if ((size_t)needed >= buffer_size) {
		free(buffer);
		buffer_size = (size_t)needed + 1;
		buffer = malloc(buffer_size);
		if (!buffer)
			return NULL; /* gncov */
		vsnprintf(buffer, buffer_size, format, ap_copy);
	}
	va_end(ap_copy);

	/* Prepare for worst case, every char is a newline. */
	converted_size = strlen(buffer) * 3 + 1;
	converted_buffer = malloc(converted_size);
	if (!converted_buffer) {
		free(buffer); /* gncov */
		return NULL; /* gncov */
	}

	src = buffer;
	dst = converted_buffer;
	*dst++ = '#';
	*dst++ = ' ';
	while (*src) {
		if (*src == '\n') {
			*dst++ = '\n';
			*dst++ = '#';
			*dst++ = ' ';
		} else {
			*dst++ = *src;
		}
		src++;
	}
	*dst = '\0';
	free(buffer);

	return converted_buffer;
}

/*
 * diag_output() - Frontend against diag_output_va(), used by the tests. 
 * Returns the value from diag_output_va(); a pointer to the allocated string, 
 * or NULL if anything failed.
 */

static char *diag_output(const char *format, ...)
{
	va_list ap;
	char *result;

	if (!format)
		return NULL;

	va_start(ap, format);
	result = diag_output_va(format, ap);
	va_end(ap);

	return result;
}

/*
 * diag() - Prints a diagnostic message prefixed with "# " to stdout. `printf` 
 * sequences can be used. All `\n` characters are converted to "\n# ".
 *
 * A terminating `\n` is automatically added to the string. Returns 0 if 
 * successful, or 1 if `format` is NULL.
 */

static int diag(const char *format, ...)
{
	va_list ap;
	char *converted_buffer;

	if (!format)
		return 1;

	va_start(ap, format);
	converted_buffer = diag_output_va(format, ap);
	va_end(ap);
	if (!converted_buffer) {
		return ok(1, "%s(): diag_output_va() failed", /* gncov */
		             __func__);
	}
	fprintf(stderr, "%s\n", converted_buffer);
	fflush(stderr);
	free(converted_buffer);

	return 0;
}

/*
 * gotexp_output() - Generate the output used by print_gotexp(). The output is 
 * returned as an allocated string that must be free()'ed after use. Returns 
 * NULL if `got` or `exp` is NULL or allocstr() fails. Otherwise, it returns a 
 * pointer to the string with the output.
 */

static char *gotexp_output(const char *got, const char *exp)
{
	char *s;

	if (!got || !exp)
		return NULL;

	s = allocstr("         got: '%s'\n"
	             "    expected: '%s'",
	             got, exp);
	if (!s)
		ok(1, "%s(): allocstr() failed", __func__); /* gncov */

	return s;
}

/*
 * print_gotexp() - Print the value of the actual and exepected data. Used when 
 * a test fails. Returns 1 if `got` or `exp` is NULL, otherwise 0.
 */

static int print_gotexp(const char *got, const char *exp)
{
	char *s;

	if (!got || !exp)
		return 1;
	if (!strcmp(got, exp))
		return 0;

	s = gotexp_output(got, exp); /* gncov */
	diag(s); /* gncov */
	free(s); /* gncov */

	return 0; /* gncov */
}

/*
 * tc_cmp() - Comparison function used by test_command(). There are 2 types of 
 * verification: One that demands that the whole output must be identical to 
 * the expected value, and the other is just a substring search. `got` is the 
 * actual output from the program, and `exp` is the expected output or 
 * substring.
 *
 * If `identical` is 0 (substring search) and `exp` is empty, the output in 
 * `got` must also be empty for the test to succeed.
 *
 * Returns 0 if the string was found, otherwise 1.
 */

static int tc_cmp(const int identical, const char *got, const char *exp)
{
	assert(got);
	assert(exp);
	if (!got || !exp)
		return 1; /* gncov */

	if (identical || !strlen(exp))
		return !!strcmp(got, exp);

	return !strstr(got, exp);
}

/*
 * valgrind_lines() - Searches for Valgrind markers ("\n==DIGITS==") in `s`, 
 * used by test_command(). If a marker is found or `s` is NULL, it returns 1. 
 * Otherwise, it returns 0.
 */

static int valgrind_lines(const char *s)
{
	const char *p = s;

	if (!s)
		return ok(1, "%s(): s == NULL", __func__); /* gncov */

	while (*p) {
		p = strstr(p, "\n==");
		if (!p)
			return 0;
		p += 3;
		if (!*p)
			return 0;
		if (!isdigit(*p))
			continue;
		while (isdigit(*p))
			p++;
		if (!*p)
			return 0;
		if (!strncmp(p, "==", 2))
			return 1;
		p++;
	}

	return 0;
}

/*
 * test_command() - Run the executable with arguments in `cmd` and verify 
 * stdout, stderr and the return value against `exp_stdout`, `exp_stderr` and 
 * `exp_retval`. Returns nothing.
 */

static void test_command(const char identical, char *cmd[],
                         const char *exp_stdout, const char *exp_stderr,
                         const int exp_retval, const char *desc)
{
	struct streams ss;

	assert(cmd);
	if (!cmd) {
		ok(1, "%s(): cmd is NULL", __func__); /* gncov */
		return; /* gncov */
	}

	if (opt.verbose >= 4) {
		int i = -1; /* gncov */
		fprintf(stderr, "# %s(", __func__); /* gncov */
		while (cmd[++i]) /* gncov */
			fprintf(stderr, "%s\"%s\"", /* gncov */
			                i ? ", " : "", cmd[i]); /* gncov */
		fprintf(stderr, ")\n"); /* gncov */
	}

	streams_init(&ss);
	streams_exec(&ss, cmd);
	if (exp_stdout) {
		ok(tc_cmp(identical, ss.out.buf, exp_stdout),
		   "%s (stdout)", desc);
		if (tc_cmp(identical, ss.out.buf, exp_stdout))
			print_gotexp(ss.out.buf, exp_stdout); /* gncov */
	}
	if (exp_stderr) {
		ok(tc_cmp(identical, ss.err.buf, exp_stderr),
		   "%s (stderr)", desc);
		if (tc_cmp(identical, ss.err.buf, exp_stderr))
			print_gotexp(ss.err.buf, exp_stderr); /* gncov */
	}
	ok(!(ss.ret == exp_retval), "%s (retval)", desc);
	if (ss.ret != exp_retval) {
		char *g = allocstr("%d", ss.ret), /* gncov */
		     *e = allocstr("%d", exp_retval); /* gncov */
		if (!g || !e) /* gncov */
			ok(1, "%s(): allocstr() failed", __func__); /* gncov */
		else
			print_gotexp(g, e); /* gncov */
		free(e); /* gncov */
		free(g); /* gncov */
	}
	if (valgrind_lines(ss.err.buf))
		ok(1, "Found valgrind output"); /* gncov */
	streams_free(&ss);
}

/*
 * sc() - Execute command `cmd` and verify that stdout, stderr and the return 
 * value corresponds to the expected values. The `exp_*` variables are 
 * substrings that must occur in the actual output. Returns nothing.
 */

static void sc(char *cmd[], const char *exp_stdout, const char *exp_stderr,
               const int exp_retval, const char *desc)
{
	test_command(0, cmd, exp_stdout, exp_stderr, exp_retval, desc);
}

/*
 * tc() - Execute command `cmd` and verify that stdout, stderr and the return 
 * value are identical to the expected values. The `exp_*` variables are 
 * strings that must be identical to the actual output. Returns nothing.
 */

static void tc(char *cmd[], const char *exp_stdout, const char *exp_stderr,
               const int exp_retval, const char *desc)
{
	test_command(1, cmd, exp_stdout, exp_stderr, exp_retval, desc);
}

/*
 ******************
 * Function tests *
 ******************
 */

/*
 * selftest functions
 */

/*
 * test_diag_big() - Tests diag_output() with a string larger than BUFSIZ. 
 * Returns nothing.
 */

static void test_diag_big(void)
{
	size_t size;
	char *p, *outp;

	size = BUFSIZ * 2;
	p = malloc(size + 1);
	if (!p) {
		ok(1, "%s(): malloc(%zu) failed", /* gncov */
		       __func__, size + 1);
		return; /* gncov */
	}

	memset(p, 'a', size);
	p[3] = 'b';
	p[4] = 'c';
	p[size] = '\0';

	outp = diag_output("%s", p);
	ok(!outp, "diag_big: diag_output() returns ok");
	ok(!(strlen(outp) == size + 2), "diag_big: String length is correct");
	ok(!!strncmp(outp, "# aaabcaaa", 10), "diag_big: Beginning is ok");
	free(outp);
	free(p);
}

/*
 * test_diag() - Tests the diag_output() function. diag() can't be tested 
 * directly because it would pollute the the test output. Returns nothing.
 */

static void test_diag(void) {
	char *p, *s;

	diag("Test diag()");

	ok(!diag(NULL), "diag(NULL)");
	ok(!(diag_output(NULL) == NULL), "diag_output() receives NULL");

	p = diag_output("Text with\nnewline");
	ok(!p, "diag_output() with newline didn't return NULL");
	s = "# Text with\n# newline";
	ok(p ? !!strcmp(p, s) : 1, "diag_output() with newline, output is ok");
	print_gotexp(p, s);
	free(p);

	p = diag_output("%d = %s, %d = %s, %d = %s",
	                1, "one", 2, "two", 3, "three");
	ok(!p, "diag_output() with %%d and %%s didn't return NULL");
	s = "# 1 = one, 2 = two, 3 = three";
	ok(p ? !!strcmp(p, s) : 1, "diag_output() with %%d and %%s");
	print_gotexp(p, s);
	free(p);

	test_diag_big();
}

/*
 * test_gotexp_output() - Tests the gotexp_output() function. print_gotexp() 
 * can't be tested directly because it would pollute stderr. Returns nothing.
 */

static void test_gotexp_output(void)
{
	char *p, *s;

	diag("Test gotexp_output()");

	ok(!!gotexp_output(NULL, "a"), "gotexp_output(NULL, \"a\")");

	ok(!!strcmp((p = gotexp_output("got this", "expected this")),
	            "         got: 'got this'\n"
	            "    expected: 'expected this'"),
	   "gotexp_output(\"got this\", \"expected this\")");
	free(p);

	ok(!print_gotexp(NULL, "expected this"),
	   "print_gotexp(): Arg is NULL");

	s = "gotexp_output(\"a\", \"a\")";
	ok(!(p = gotexp_output("a", "a")), "%s doesn't return NULL", s);
	ok(!!strcmp(p, "         got: 'a'\n    expected: 'a'"),
	   "%s: Contents is ok", s);
	free(p);

	s = "gotexp_output() with newline";
	ok(!(p = gotexp_output("with\nnewline", "also with\nnewline")),
	   "%s: Doesn't return NULL", s);
	ok(!!strcmp(p, "         got: 'with\nnewline'\n"
	               "    expected: 'also with\nnewline'"),
	   "%s: Contents is ok", s);
	free(p);
}

/*
 * test_valgrind_lines() - Test the behavior of valgrind_lines(). Returns 
 * nothing.
 */

static void test_valgrind_lines(void)
{
	int i;
	const char
	*has[] = {
		"\n==123==",
		"\n==154363456657465745674567456523==maybe",
		"\n==\n==123==maybe",
		"\n==\n==123==maybe==456==",
		"indeed\n==1==",
		NULL
	},
	*hasnot[] = {
		"",
		"==123==",
		"\n=",
		"\n=123== \n234==",
		"\n=123==",
		"\n== 234==",
		"\n==",
		"\n==12.3==",
		"\n==123",
		"\n==123=",
		"\n==jj==",
		"abc",
		"abc\n==",
		NULL
	};

	diag("Test valgrind_lines()");

	i = 0;
	while (has[i]) {
		ok(!valgrind_lines(has[i]),
		   "valgrind_lines(): Has valgrind marker, string %d", i);
		i++;
	}

	i = 0;
	while (hasnot[i]) {
		ok(valgrind_lines(hasnot[i]),
		   "valgrind_lines(): No valgrind marker, string %d", i);
		i++;
	}
}

/*
 * test_allocstr() - Tests the allocstr() function. Returns nothing.
 */

static void test_allocstr(void)
{
	const size_t bufsize = BUFSIZ * 2 + 1;
	char *p, *p2, *p3;
	size_t alen;

	diag("Test allocstr()");
	p = malloc(bufsize);
	if (!p) {
		ok(1, "%s(): malloc() failed", __func__); /* gncov */
		return; /* gncov */
	}
	memset(p, 'a', bufsize - 1);
	p[bufsize - 1] = '\0';
	p2 = allocstr("%s", p);
	if (!p2) {
		ok(1, "%s(): allocstr() failed with BUFSIZ * 2", /* gncov */
		      __func__);
		goto free_p; /* gncov */
	}
	alen = strlen(p2);
	ok(!(alen == BUFSIZ * 2), "allocstr(): strlen is correct");
	p3 = p2;
	while (*p3) {
		if (*p3 != 'a') {
			p3 = NULL; /* gncov */
			break; /* gncov */
		}
		p3++;
	}
	ok(!(p3 != NULL), "allocstr(): Content of string is correct");
	free(p2);
free_p:
	free(p);
}

/*
 * test_streams_exec() - Tests the streams_exec() function. Returns nothing.
 */

static void test_streams_exec(char *execname)
{
	bool orig_valgrind;
	struct streams ss;
	char *s;

	diag("Test streams_exec()");

	diag("Send input to the program");
	streams_init(&ss);
	ss.in.buf = "This is sent to stdin.\n";
	ss.in.len = strlen(ss.in.buf);
	orig_valgrind = opt.valgrind;
	opt.valgrind = false;
	streams_exec(&ss, chp{ execname, NULL });
	opt.valgrind = orig_valgrind;
	s = "streams_exec(execname) with stdin data";
	ok(!!strcmp(ss.out.buf, ""), "%s (stdout)", s);
	ok(!strstr(ss.err.buf, ""), "%s (stderr)", s);
	ok(!(ss.ret == EXIT_SUCCESS), "%s (retval)", s);
	streams_free(&ss);
}

/*
 ****************
 * Option tests *
 ****************
 */

/*
 * test_valgrind_option() - Tests the --valgrind command line option. Returns 
 * nothing.
 */

static void test_valgrind_option(char *execname)
{
	struct streams ss;

	diag("Test --valgrind");

	if (opt.valgrind) {
		opt.valgrind = false; /* gncov */
		streams_init(&ss); /* gncov */
		streams_exec(&ss, chp{"valgrind", "--version", /* gncov */
		                      NULL});
		if (!strstr(ss.out.buf, "valgrind-")) { /* gncov */
			ok(1, "Valgrind is not installed," /* gncov */
			      " disabling Valgrind checks");
		} else {
			ok(0, "Valgrind is installed"); /* gncov */
			opt.valgrind = true; /* gncov */
		}
		streams_free(&ss); /* gncov */
	}

	sc(chp{execname, "--valgrind", "-h", NULL},
	   "Show this",
	   "",
	   EXIT_SUCCESS,
	   "--valgrind -h");
}

/*
 * test_standard_options() - Tests the various generic options available in 
 * most programs. Returns nothing.
 */

static void test_standard_options(char *execname)
{
	char *s;

	diag("Test standard options");

	diag("Test -h/--help");
	sc(chp{ execname, "-h", NULL },
	   "  Show this help",
	   "",
	   EXIT_SUCCESS,
	   "-h");
	sc(chp{ execname, "--help", NULL },
	   "  Show this help",
	   "",
	   EXIT_SUCCESS,
	   "--help");

	diag("Test -v/--verbose");
	sc(chp{ execname, "-h", "--verbose", NULL },
	   "  Show this help",
	   "",
	   EXIT_SUCCESS,
	   "-hv: Help text is displayed");
	sc(chp{ execname, "-hv", NULL },
	   EXEC_VERSION,
	   "",
	   EXIT_SUCCESS,
	   "-hv: Version number is printed along with the help text");
	sc(chp{ execname, "-vvv", "--verbose", "--help", NULL },
	   "  Show this help",
	   ": main(): Using verbose level 4\n",
	   EXIT_SUCCESS,
	   "-vvv --verbose: Using correct verbose level");
	sc(chp{ execname, "-vvvvq", "--verbose", "--verbose", "--help", NULL },
	   "  Show this help",
	   ": main(): Using verbose level 5\n",
	   EXIT_SUCCESS,
	   "--verbose: One -q reduces the verbosity level");

	diag("Test --version");
	s = allocstr("%s %s (%s)\n", execname, EXEC_VERSION, EXEC_DATE);
	if (s) {
		sc(chp{ execname, "--version", NULL },
		   s,
		   "",
		   EXIT_SUCCESS,
		   "--version");
		free(s);
	} else {
		ok(1, "%s(): allocstr() 1 failed", __func__); /* gncov */
	}
	s = EXEC_VERSION "\n";
	tc(chp{ execname, "--version", "-q", NULL },
	   s,
	   "",
	   EXIT_SUCCESS,
	   "--version with -q shows only the version number");

	diag("Test --license");
	sc(chp{ execname, "--license", NULL },
	   "GNU General Public License",
	   "",
	   EXIT_SUCCESS,
	   "--license: It's GPL");
	sc(chp{ execname, "--license", NULL },
	   "either version 2 of the License",
	   "",
	   EXIT_SUCCESS,
	   "--license: It's version 2 of the GPL");

	diag("Unknown option");
	sc(chp{ execname, "--gurgle", NULL },
	   "",
	   ": Option error\n",
	   EXIT_FAILURE,
	   "Unknown option: \"Option error\" message is printed");
	sc(chp{ execname, "--gurgle", NULL },
	   "",
	   " --help\" for help screen. Returning with value 1.\n",
	   EXIT_FAILURE,
	   "Unknown option mentions --help");
}

/*
 * test_functions() - Tests various functions directly. Returns nothing.
 */

static void test_functions(void)
{
	if (!opt.testfunc)
		return; /* gncov */

	diag("Test selftest routines");
	ok(!ok(0, NULL), "ok(0, NULL)");
	test_diag();
	test_gotexp_output();
	test_valgrind_lines();

	diag("Test various routines");
	diag("Test myerror()");
	errno = EACCES;
	ok(!(myerror("errno is EACCES") > 37), "myerror(): errno is EACCES");
	errno = 0;
	diag("Test std_strerror()");
	ok(!(std_strerror(0) != NULL), "std_strerror(0)");
	test_allocstr();
}

/*
 * print_version_info() - Display output from the --version command. Returns 0 
 * if ok, or 1 if streams_exec() failed.
 */

static int print_version_info(char *execname)
{
	struct streams ss;
	int res;

	streams_init(&ss);
	res = streams_exec(&ss, chp{ execname, "--version", NULL });
	if (res) {
		diag("%s(): streams_exec() failed:\n%s", /* gncov */
		     __func__, ss.err.buf ? ss.err.buf : "(null)"); /* gncov */
		return 1; /* gncov */
	}
	diag("========== BEGIN version info ==========\n"
	     "%s"
	     "=========== END version info ===========",
	     ss.out.buf ? ss.out.buf : "(null)");
	streams_free(&ss);

	return 0;
}

/*
 * test_executable() - Run various tests with the executable and verify that 
 * stdout, stderr and the return value are as expected. Returns nothing.
 */

static void test_executable(char *execname)
{
	if (!opt.testexec)
		return; /* gncov */

	diag("Test the executable");
	test_valgrind_option(execname);
	print_version_info(execname);
	test_streams_exec(execname);
	test_standard_options(execname);
	print_version_info(execname);
}

/*
 * opt_selftest() - Run internal testing to check that it works on the current 
 * system. Executed if --selftest is used. Returns `EXIT_FAILURE` if any tests 
 * fail; otherwise, it returns `EXIT_SUCCESS`.
 */

int opt_selftest(char *execname)
{
	diag("Running tests for %s %s (%s)",
	     execname, EXEC_VERSION, EXEC_DATE);

	test_functions();
	test_executable(execname);

	printf("1..%d\n", testnum);
	if (failcount) {
		diag("Looks like you failed %d test%s of %d.", /* gncov */
		     failcount, (failcount == 1) ? "" : "s", /* gncov */
		     testnum);
	}

	return failcount ? EXIT_FAILURE : EXIT_SUCCESS;
}

#undef chp

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
