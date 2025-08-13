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

#define EXECSTR  "__EXSTR__"
#define OPTION_ERROR_STR  EXECSTR ": Option error\n" \
                          EXECSTR ": Type \"" EXECSTR " --help\" for help screen." \
                          " Returning with value 1.\n"
#define chp  (char *[])
#define print_gotexp_nostr(seq, got, exp)  do { \
	char *g = allocstr((seq), (got)), *e = allocstr((seq), (exp)); \
	if (!g || !e) \
		failed_ok("allocstr()"); \
	else \
		print_gotexp(g, e); \
	free(e); \
	free(g); \
} while (0)
#define print_gotexp_int(got, exp)  do { \
	if ((got) != (exp)) \
		print_gotexp_nostr("%d", (got), (exp)); \
} while (0)
#define print_gotexp_size_t(got, exp)  do { \
	if ((got) != (exp)) \
		print_gotexp_nostr("%zu", (got), (exp)); \
} while (0)
#define print_gotexp_ulong(got, exp)  do { \
	if ((got) != (exp)) \
		print_gotexp_nostr("%lu", (got), (exp)); \
} while (0)
/*
 * Main test macros, meant to be a human-friendly frontend against ok(). Unlike 
 * most other testing frameworks that return 1 for success and 0 for error, 
 * these functions and macros return 0 for success and 1 if the test fails. The 
 * reasoning behind this is:
 *
 * We don't look for successful tests, but tests that fail. By returning 1 when 
 * the test fails, the return value can be used to increase a fail counter to 
 * find the total number of failed tests, or take special action based on the 
 * outcome of a single test or a series of previous tests. If the macros or 
 * ok() had returned 0 for failure and non-zero for success, we would need an 
 * additional counter to keep track of the number of executed tests and then 
 * use subtraction to see if any tests failed. Besides, C typically returns 0 
 * for success and non-zero for failure, so this convention should feel natural 
 * to C programmers. The `ok(expr, desc, ...)` function is a frontend to 
 * `ok_va()`, which evaluates `expr`, printing an "ok" line to stdout if `expr` 
 * is 0 (success, returning 0) or "not ok" if `expr` is non-zero (failure, 
 * returning 1), using `desc` with any additional arguments for the test 
 * description.
 *
 * All macros have a description parameter at the end which supports printf() 
 * sequences and additional optional arguments.
 *
 * In addition to the regular macros, the same macros exist as `OK_*_L()` 
 * variants. The functionality is identical, but they have an extra `linenum` 
 * parameter before the `desc` parameter. This is used to communicate to ok() 
 * and ok_va() the line number of the test. If the test is inside a helper 
 * function that's repeated many times, the line number inside the helper 
 * function is sent to ok(), and that's not what's usually wanted. By having a 
 * `const int linenumber` parameter in the helper function, the scopes above 
 * can deliver the actual line the test is executed from.
 *
 * This is a list of the various macros, with a description of which types of 
 * tests they're intended for, and the criteria for success:
 *
 * OK_EQUAL(a, b, desc, ...) - Verifies that the values `a` and `b` are 
 * identical. It uses `==` for comparison and is intended for variables of any 
 * type that supports the `==` operator.
 * Example: OK_EQUAL(num_found, expected, "Found %u elements", expected);
 *
 * OK_ERROR(msg, ...) - Generates a test failure with `msg` as the description. 
 * Used for unexpected errors that can't be ignored, incrementing the failure 
 * counter and failing the test run. Typically used in conditional checks.
 * Example: if (valgrind_lines(stderr_output))
 *                  OK_ERROR("Found Valgrind output in stderr");
 *
 * OK_FAILURE(func, desc, ...) - Used for functions that return 0 for success 
 * and non-zero for failure. Expects the function to fail (return non-zero). 
 * Example: OK_FAILURE(stat(file), "File is unreadable or doesn't exist");
 *
 * OK_FALSE(val, desc, ...) - Used for boolean values or expressions expected 
 * to be false. Negated expressions can be confusing, so `OK_TRUE` is usually a 
 * clearer choice for complex checks.
 * Examples: OK_FALSE(user_exists(user), "User %s doesn't exist", user);
 *           OK_FALSE(result == 5, "Result is not 5");
 *
 * OK_NOTEQUAL(a, b, desc, ...) - Expects the values `a` and `b` to be 
 * different. The `!=` operator is used for the comparison.
 * Example: OK_NOTEQUAL(userid1, userid2, "The users have different IDs");
 *
 * OK_NOTNULL(p, desc, ...) - Succeeds if the pointer `p` is non-NULL.
 * Examples: OK_NOTNULL(strstr(txt, substr), "Substring was found in text");
 *           OK_NOTNULL(fp, "File pointer is not NULL");
 *
 * OK_NULL(p, desc, ...) - Expects the pointer `p` to be NULL.
 * Examples: OK_NULL(getenv(var), "Environment variable %s is undefined", var);
 *           OK_NULL(strchr(file, '/'), "No slash in file name \"%s\"", file);
 *
 * OK_STRCMP(a, b, desc, ...) - Compares the strings `a` and `b` and succeeds 
 * if they're identical.
 * Example: OK_STRCMP(file, "index.html", "File name is correct");
 *
 * OK_STRNCMP(a, b, len, desc, ...) - Compares the first `len` characters of 
 * the strings `a` and `b` and succeeds if the substrings are identical.
 * Example: OK_STRNCMP(file, "tmp", 3, "File name has \"tmp\" prefix");
 *
 * OK_SUCCESS(func, desc, ...) - Used for functions that return 0 for success 
 * and non-zero for failure. Expects the function to succeed (return zero).
 * Example: OK_SUCCESS(rmdir(tempdir), "Delete temporary directory");
 *
 * OK_TRUE(val, desc, ...) - Expects the boolean value `val` to be true. This 
 * macro can also be used for comparisons or expressions not covered by other 
 * macros, like checking if a value is larger or smaller than another.
 * Examples: OK_TRUE(file_exists(file), "File %s was created", file);
 *           OK_TRUE(errcount < 10, "Error count %d is below 10", errcount);
 */

#define OK_EQUAL_L(a, b, linenum, desc, ...)  ok(!((a) == (b)), (linenum), (desc), ##__VA_ARGS__)
#define OK_ERROR_L(linenum, msg, ...)  ok(1, (linenum), (msg), ##__VA_ARGS__)
#define OK_FAILURE_L(func, linenum, desc, ...)  ok(!(func), (linenum), (desc), ##__VA_ARGS__)
#define OK_FALSE_L(val, linenum, desc, ...)  ok(!!(val), (linenum), (desc), ##__VA_ARGS__)
#define OK_NOTEQUAL_L(a, b, linenum, desc, ...)  ok(!((a) != (b)), (linenum), (desc), ##__VA_ARGS__)
#define OK_NOTNULL_L(p, linenum, desc, ...)  ok(!(p), (linenum), (desc), ##__VA_ARGS__)
#define OK_NULL_L(p, linenum, desc, ...)  ok(!!(p), (linenum), (desc), ##__VA_ARGS__)
#define OK_STRCMP_L(a, b, linenum, desc, ...)  ok(!!strcmp((a), (b)), (linenum), (desc), ##__VA_ARGS__)
#define OK_STRNCMP_L(a, b, len, linenum, desc, ...)  ok(!!strncmp((a), (b), (len)), (linenum), (desc), ##__VA_ARGS__)
#define OK_SUCCESS_L(func, linenum, desc, ...)  ok(!!(func), (linenum), (desc), ##__VA_ARGS__)
#define OK_TRUE_L(val, linenum, desc, ...)  ok(!(val), (linenum), (desc), ##__VA_ARGS__)

#define OK_EQUAL(a, b, desc, ...)  OK_EQUAL_L((a), (b), __LINE__, (desc), ##__VA_ARGS__)
#define OK_ERROR(msg, ...)  OK_ERROR_L(__LINE__, (msg), ##__VA_ARGS__)
#define OK_FAILURE(func, desc, ...)  OK_FAILURE_L((func), __LINE__, (desc), ##__VA_ARGS__)
#define OK_FALSE(val, desc, ...)  OK_FALSE_L((val), __LINE__, (desc), ##__VA_ARGS__)
#define OK_NOTEQUAL(a, b, desc, ...)  OK_NOTEQUAL_L((a), (b), __LINE__, (desc), ##__VA_ARGS__)
#define OK_NOTNULL(p, desc, ...)  OK_NOTNULL_L((p), __LINE__, (desc), ##__VA_ARGS__)
#define OK_NULL(p, desc, ...)  OK_NULL_L((p), __LINE__, (desc), ##__VA_ARGS__)
#define OK_STRCMP(a, b, desc, ...)  OK_STRCMP_L((a), (b), __LINE__, (desc), ##__VA_ARGS__)
#define OK_STRNCMP(a, b, len, desc, ...)  OK_STRNCMP_L((a), (b), (len), __LINE__, (desc), ##__VA_ARGS__)
#define OK_SUCCESS(func, desc, ...)  OK_SUCCESS_L((func), __LINE__, (desc), ##__VA_ARGS__)
#define OK_TRUE(val, desc, ...)  OK_TRUE_L((val), __LINE__, (desc), ##__VA_ARGS__)

#define failed_ok(a)  do { \
	if (errno) \
		OK_ERROR("%s():%d: %s failed: %s", \
		         __func__, __LINE__, (a), strerror(errno)); \
	else \
		OK_ERROR("%s():%d: %s failed", __func__, __LINE__, (a)); \
	errno = 0; \
} while (0)

#define TMPDIR  ".STDexecDTS-test.tmp"

#define sc(cmd, num_stdout, num_stderr, desc, ...)  \
        sc_func(__LINE__, (cmd), (num_stdout), (num_stderr), \
                (desc), ##__VA_ARGS__);
#define tc(cmd, num_stdout, num_stderr, desc, ...)  \
        tc_func(__LINE__, (cmd), (num_stdout), (num_stderr), \
                (desc), ##__VA_ARGS__);

static char *execname;
static int failcount = 0;
static int testnum = 0;

/******************************************************************************
                             --selftest functions
******************************************************************************/

/*
 * bail_out() - Aborts the test suite with an optional message written to 
 * stdout. To abort without a message, use NULL in `msg`. Returns nothing.
 */

static void bail_out(const char *msg, ...) /* gncov */
{
	va_list ap;

	fputs("Bail out!", stdout); /* gncov */
	if (msg) { /* gncov */
		fputs("  ", stdout); /* gncov */
		va_start(ap, msg); /* gncov */
		vprintf(msg, ap); /* gncov */
		va_end(ap); /* gncov */
	}
	fputc('\n', stdout); /* gncov */

	exit(EXIT_FAILURE); /* gncov */
}

/*
 * ok_va() - Print a log line to stdout. If `i` is 0, an "ok" line is printed, 
 * otherwise a "not ok" line is printed. `desc` is the test description and can 
 * use printf sequences.
 *
 * Returns 0 if `i` is 0, otherwise it returns 1.
 */

static int ok_va(const int i, const int linenum, const char *desc, va_list ap)
{
	va_list ap_copy;
	char *s, *s2;

	assert(desc);

	if (!desc)
		bail_out("%s(): desc is NULL", __func__); /* gncov */

	printf("%sok %d - %d: ", (i ? "not " : ""), ++testnum, linenum);
	va_copy(ap_copy, ap);
	s = allocstr_va(desc, ap_copy);
	va_end(ap_copy);
	if (!s)
		bail_out("allocstr_va() failed: %s", /* gncov */
		         strerror(errno)); /* gncov */
	s2 = str_replace(s, "\n", "\\n");
	if (!s2) {
		free(s); /* gncov */
		bail_out("str_replace() failed: %s", /* gncov */
		         strerror(errno)); /* gncov */
	}
	puts(s2);
	free(s2);
	free(s);
	fflush(stdout);
	failcount += !!i;

	return !!i;
}

/*
 * ok() - Frontend against ok_va(). Refer to the description for that function 
 * for more info. Returns 0 if `i` is 0, otherwise it returns 1.
 */

static int ok(const int i, const int linenum, const char *desc, ...)
{
	va_list ap;

	assert(desc);

	if (!desc)
		bail_out("%s(): desc is NULL", __func__); /* gncov */

	va_start(ap, desc);
	ok_va(i, linenum,  desc, ap);
	va_end(ap);

	return !!i;
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
	size_t converted_size;

	assert(format);
	if (!format)
		return NULL; /* gncov */

	buffer = allocstr_va(format, ap);
	if (!buffer) {
		failed_ok("allocstr_va()"); /* gncov */
		return NULL; /* gncov */
	}

	/* Prepare for worst case, every char is a newline. */
	converted_size = strlen("# ") + strlen(buffer) * 3 + 1;
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
 * diag() - Prints a diagnostic message prefixed with "# " to stderr. `printf` 
 * sequences can be used. All `\n` characters are converted to "\n# ".
 *
 * A terminating `\n` is automatically added to the string. Returns 0 if 
 * successful, or 1 if `format` is NULL or diag_output_va() failed.
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
		failed_ok("diag_output_va()"); /* gncov */
		return 1; /* gncov */
	}
	fprintf(stderr, "%s\n", converted_buffer);
	fflush(stderr);
	free(converted_buffer);

	return 0;
}

/*
 * gotexp_output() - Generate the output used by print_gotexp(). Returns NULL 
 * if allocstr() or mystrdup() fails. Otherwise, it returns a pointer to an 
 * allocated string with the output.
 */

static char *gotexp_output(const char *got, const char *exp)
{
	char *s;

	if (got == exp || (got && exp && !strcmp(got, exp))) {
		s = mystrdup("");
		if (!s)
			failed_ok("mystrdup()"); /* gncov */
	} else {
		s = allocstr("         got: '%s'\n"
		             "    expected: '%s'",
		             no_null(got), no_null(exp));
		if (!s)
			failed_ok("allocstr()"); /* gncov */
	}

	return s;
}

/*
 * print_gotexp() - Print the value of the actual and exepected data. Used when 
 * a test fails. Returns 1 if `got` or `exp` are different, otherwise 0.
 */

static int print_gotexp(const char *got, const char *exp)
{
	char *s;

	s = gotexp_output(got, exp);
	if (s && *s)
		diag(s); /* gncov */
	free(s);

	return 0;
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
		return OK_ERROR("%s(): s == NULL", __func__); /* gncov */

	while (*p) {
		p = strstr(p, "\n==");
		if (!p)
			return 0;
		p += 3;
		if (!*p)
			return 0;
		if (!isdigit((unsigned char)*p))
			continue;
		while (isdigit((unsigned char)*p))
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

	if (identical || !*exp)
		return !!strcmp(got, exp);

	return !strstr(got, exp);
}

/*
 * test_command() - Run the executable with arguments in `cmd` and verify 
 * stdout, stderr and the return value against `exp_stdout`, `exp_stderr` and 
 * `exp_retval`. Returns nothing.
 */

static void test_command(const int linenum, const char identical, char *cmd[],
                         const char *exp_stdout, const char *exp_stderr,
                         const int exp_retval, const char *desc, va_list ap)
{
	const struct Options o = opt_struct();
	struct streams ss;
	char *e_stdout, *e_stderr, *descbuf;

	assert(cmd);
	assert(desc);
	if (!cmd) {
		OK_ERROR_L(linenum, "%s(): cmd is NULL", __func__); /* gncov */
		return; /* gncov */
	}

	if (o.verbose >= 4) {
		int i = -1; /* gncov */
		fprintf(stderr, "# %s(", __func__); /* gncov */
		while (cmd[++i]) /* gncov */
			fprintf(stderr, "%s\"%s\"", /* gncov */
			                i ? ", " : "", cmd[i]); /* gncov */
		fprintf(stderr, ")\n"); /* gncov */
	}

	e_stdout = str_replace(exp_stdout, EXECSTR, execname);
	e_stderr = str_replace(exp_stderr, EXECSTR, execname);
	descbuf = allocstr_va(desc, ap);
	if (!descbuf) {
		failed_ok("allocstr_va()"); /* gncov */
		return; /* gncov */
	}
	streams_init(&ss);
	streams_exec(&o, &ss, cmd);
	if (e_stdout) {
		OK_FALSE_L(tc_cmp(identical, ss.out.buf, e_stdout), linenum,
		         "%s (stdout)", descbuf);
		if (tc_cmp(identical, ss.out.buf, e_stdout))
			print_gotexp(ss.out.buf, e_stdout); /* gncov */
	}
	if (e_stderr) {
		OK_FALSE_L(tc_cmp(identical, ss.err.buf, e_stderr), linenum,
		                  "%s (stderr)", descbuf);
		if (tc_cmp(identical, ss.err.buf, e_stderr))
			print_gotexp(ss.err.buf, e_stderr); /* gncov */
	}
	OK_EQUAL_L(ss.ret, exp_retval, linenum, "%s (retval)", descbuf);
	print_gotexp_int(ss.ret, exp_retval);
	free(descbuf);
	free(e_stderr);
	free(e_stdout);
	print_gotexp_int(ss.ret, exp_retval);
	if (valgrind_lines(ss.err.buf))
		OK_ERROR_L(linenum, "Found valgrind output"); /* gncov */
	streams_free(&ss);
}

/*
 * sc_func() - Execute command `cmd` and verify that stdout, stderr and the 
 * return value corresponds to the expected values. The `exp_*` variables are 
 * substrings that must occur in the actual output. Not meant to be called 
 * directly, but via the uc() macro that logs the line number automatically. 
 * Returns nothing.
 */

static void sc_func(const int linenum, char *cmd[], const char *exp_stdout,
                    const char *exp_stderr, const int exp_retval,
                    const char *desc, ...)
{
	va_list ap;

	assert(cmd);
	assert(desc);

	va_start(ap, desc);
	test_command(linenum, 0, cmd, exp_stdout, exp_stderr, exp_retval,
	             desc, ap);
	va_end(ap);
}

/*
 * tc_func() - Execute command `cmd` and verify that stdout, stderr and the 
 * return value are identical to the expected values. The `exp_*` variables are 
 * strings that must be identical to the actual output. Not meant to be called 
 * directly, but via the tc() macro that logs the line number automatically. 
 * Returns nothing.
 */

static void tc_func(const int linenum, char *cmd[], const char *exp_stdout,
                    const char *exp_stderr, const int exp_retval,
                    const char *desc, ...)
{
	va_list ap;

	assert(cmd);
	assert(desc);

	va_start(ap, desc);
	test_command(linenum, 1, cmd, exp_stdout, exp_stderr, exp_retval,
	             desc, ap);
	va_end(ap);
}

/******************************************************************************
                    STDexecDTS-specific selftest functions
******************************************************************************/

/******************************************************************************
                 Function tests, no temporary directory needed
******************************************************************************/

                             /*** selftest.c ***/

/*
 * test_ok_macros() - Tests the OK_*() macros. Returns nothing.
 */

static void test_ok_macros(void)
{
	diag("Test the OK_*() macros");

	OK_EQUAL(3.14, 3.14, "OK_EQUAL(%.2f, %.2f, ...)", 3.14, 3.14);
	/* OK_ERROR("OK_ERROR(...), can't be tested"); */
	OK_FAILURE(1, "OK_FAILURE(1, ...)");
	OK_FALSE(5 == 9, "OK_FALSE(5 == 9, ...)");
	OK_NOTEQUAL(19716, 1916, "OK_NOTEQUAL(%u, %u, ...)", 19716, 1916);
	OK_NOTNULL(strstr("abcdef", "cde"), "OK_NOTNULL(strstr(\"abcdef\", \"cde\"), ...)");
	OK_NULL(strstr("abcdef", "notfound"), "OK_NULL(strstr(\"abcdef\", \"notfound\"), ...)");
	OK_STRCMP("str", "str", "OK_STRCMP(\"%s\", \"%s\", ...)", "str", "str");
	OK_STRNCMP("abcde", "abcyz", 3, "OK_STRNCMP(\"abcde\", \"abcyz\", 3, ...)");
	OK_SUCCESS(0, "OK_SUCCESS(0, ...)");
	OK_TRUE(9 > -4, "OK_TRUE(%d > %d, ...)", 9, -4);
}

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
		failed_ok("malloc()"); /* gncov */
		return; /* gncov */
	}

	memset(p, 'a', size);
	p[3] = 'b';
	p[4] = 'c';
	p[size] = '\0';

	outp = diag_output("%s", p);
	OK_NOTNULL(outp, "diag_big: diag_output() returns ok");
	OK_EQUAL(strlen(outp), size + 2, "diag_big: String length is correct");
	OK_STRNCMP(outp, "# aaabcaaa", 10, "diag_big: Beginning is ok");
	free(outp);
	free(p);
}

/*
 * test_diag() - Tests the diag_output() function. diag() can't be tested 
 * directly because it would pollute the the test output. Returns nothing.
 */

static void test_diag(void) {
	char *p, *s;
	const char *desc;

	diag("Test diag()");

	OK_EQUAL(diag(NULL), 1, "diag(NULL)");
	OK_NULL(diag_output(NULL), "diag_output() receives NULL");

	p = diag_output("Text with\nnewline");
	OK_NOTNULL(p, "diag_output() with newline didn't return NULL");
	s = "# Text with\n# newline";
	desc = "diag_output() with newline, output is ok";
	if (p)
		OK_STRCMP(p, s, desc);
	else
		OK_ERROR(desc); /* gncov */
	print_gotexp(p, s);
	free(p);

	p = diag_output("\n\n\n\n\n\n\n\n\n\n");
	OK_NOTNULL(p, "diag_output() with only newlines didn't return NULL");
	s = "# \n# \n# \n# \n# \n# \n# \n# \n# \n# \n# ";
	desc = "diag_output() with only newlines";
	if (p)
		OK_STRCMP(p, s, desc);
	else
		OK_ERROR(desc); /* gncov */
	print_gotexp(p, s);
	free(p);

	p = diag_output("%d = %s, %d = %s, %d = %s",
	                1, "one", 2, "two", 3, "three");
	OK_NOTNULL(p, "diag_output() with %%d and %%s didn't return NULL");
	s = "# 1 = one, 2 = two, 3 = three";
	desc = "diag_output() with %%d and %%s";
	if (p)
		OK_STRCMP(p, s, desc);
	else
		OK_ERROR(desc); /* gncov */
	print_gotexp(p, s);
	free(p);

	test_diag_big();
}

/*
 * chk_go() - Used by test_gotexp_output(). Verifies that `gotexp_output(got, 
 * exp)` returns the correct output with the correct `exp_got` and `exp_exp` 
 * values, or an empty string if the strings are identical. Returns nothing.
 */

static void chk_go(const int linenum, const char *got, const char *exp,
                   const char *exp_got, const char *exp_exp)
{
	char *s, *exp_str;

	assert(exp_got);
	assert(exp_exp);

	s = gotexp_output(got, exp);
	if (!s) {
		failed_ok("gotexp_output()"); /* gncov */
		return; /* gncov */
	}
	if (exp_got == exp_exp
	    || (exp_got && exp_exp && !strcmp(exp_got, exp_exp))) {
		exp_str = mystrdup("");
	} else {
		exp_str = allocstr("         got: '%s'\n"
		                   "    expected: '%s'", exp_got, exp_exp);
	}
	if (!exp_str) {
		failed_ok("mystrdup() or allocstr()"); /* gncov */
		free(s); /* gncov */
		return; /* gncov */
	}
	OK_STRCMP_L(s, exp_str, linenum, "gotexp_output(\"%s\", \"%s\")",
	            no_null(got), no_null(exp));
	if (strcmp(s, exp_str))
		diag("Got:\n%s\nExpected:\n%s", s, exp_str); /* gncov */
	free(exp_str);
	free(s);
}

/*
 * test_gotexp_output() - Tests the gotexp_output() function. print_gotexp() 
 * can't be tested directly because it would pollute stderr. Returns nothing.
 */

static void test_gotexp_output(void)
{
	diag("Test gotexp_output()");

#define chk_go(got, exp, exp_got, exp_exp)  chk_go(__LINE__, (got), (exp), \
                                                   (exp_got), (exp_exp))
	chk_go("", "", "", "");
	chk_go("a", "a", "", "");
	chk_go("a", "b", "a", "b");
	chk_go("got this", "expected this", "got this", "expected this");
	chk_go("with\nnewline", "also with\nnewline",
	       "with\nnewline", "also with\nnewline");

	chk_go("a", NULL, "a", "(null)");
	chk_go(NULL, "b", "(null)", "b");
	chk_go(NULL, NULL, "", "");
#undef chk_go
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
		OK_TRUE(valgrind_lines(has[i]),
		        "valgrind_lines(): Has valgrind marker, string %d", i);
		i++;
	}

	i = 0;
	while (hasnot[i]) {
		OK_FALSE(valgrind_lines(hasnot[i]),
		         "valgrind_lines(): No valgrind marker, string %d", i);
		i++;
	}
}

/*
 * test_std_strerror() - Tests the std_strerror() function. Returns nothing.
 */

static void test_std_strerror(void)
{
	diag("Test std_strerror()");
	OK_STRCMP(std_strerror(EACCES), "Permission denied",
	          "std_strerror(EACCES) is as expected");
}

                                /*** io.c ***/

                              /*** strings.c ***/

/*
 * test_mystrdup() - Tests the mystrdup() function. Returns nothing.
 */

static void test_mystrdup(void)
{
	const char *txt = "Test string";
	char *s;

	diag("Test mystrdup()");
	OK_NULL(mystrdup(NULL), "mystrdup(NULL) == NULL");

	s = mystrdup(txt);
	if (!s) {
		failed_ok("mystrdup()"); /* gncov */
		return; /* gncov */
	}
	OK_STRCMP(s, txt, "mystrdup(): Strings are identical");
	free(s);
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
		failed_ok("malloc()"); /* gncov */
		return; /* gncov */
	}
	memset(p, 'a', bufsize - 1);
	p[bufsize - 1] = '\0';
	p2 = allocstr("%s", p);
	if (!p2) {
		failed_ok("allocstr() with BUFSIZ * 2"); /* gncov */
		goto free_p; /* gncov */
	}
	alen = strlen(p2);
	OK_EQUAL(alen, BUFSIZ * 2, "allocstr(): strlen is correct");
	p3 = p2;
	while (*p3) {
		if (*p3 != 'a') {
			p3 = NULL; /* gncov */
			break; /* gncov */
		}
		p3++;
	}
	OK_NOTNULL(p3, "allocstr(): Content of string is correct");
	free(p2);
free_p:
	free(p);
}

/*
 * chk_cs() - Used by test_count_substr(). Verifies that the number of 
 * non-overlapping substrings `substr` inside string `s` is `count`. `desc` is 
 * the test description. Returns nothing.
 */

static void chk_cs(const int linenum, const char *s, const char *substr,
                   const size_t count, const char *desc)
{
	size_t result;

	result = count_substr(s, substr);
	OK_EQUAL_L(result, count, linenum, "count_substr(): %s", desc);
	print_gotexp_size_t(result, count);
}

/*
 * test_count_substr() - Tests the count_substr() function. Returns nothing.
 */

static void test_count_substr(void)
{
	char *s;
	size_t bsize = 10000;

	diag("Test count_substr()");

#define chk_cs(s, substr, count, desc)  chk_cs(__LINE__, (s), (substr), \
                                               (count), (desc))
	chk_cs("", "", 0, "s and substr are empty");
	chk_cs("", "a", 0, "s is empty");
	chk_cs("aaa", "", 0, "substr is empty");

	chk_cs("", NULL, 0, "substr is NULL");
	chk_cs(NULL, "abcdef", 0, "s is NULL");
	chk_cs(NULL, NULL, 0, "s and substr is NULL");

	chk_cs("Abc", "abc", 0, "Case sensitivity");
	chk_cs("a", "aa", 0, "substr is longer than s");
	chk_cs("aaa", "a", 3, "3 \"a\" in \"aaa\"");
	chk_cs("aaa", "aa", 1, "Non-overlapping \"aa\" in \"aaa\"");
	chk_cs("aaabaaa", "aaa", 2, "Non-overlapping \"aaa\" split by \"b\"");
	chk_cs("abababab", "ab", 4, "4 \"ab\" in s");
	chk_cs("abc", "b", 1, "Single character substring");
	chk_cs("abc", "d", 0, "Substring not found");
	chk_cs("abcdeabc", "abc", 2, "Substring at start and end");
	chk_cs("abcdef" "abcdef" "abcdef", "abc", 3, "3 \"abc\" in s");
	chk_cs("abcdef", "abcdef", 1, "s and substr are identical");
	chk_cs("zzzGHJ\nabc\nGHJ\nabcGHJ", "GHJ", 3, "s with newlines");
	chk_cs("Ḡṹṛḡḷḗ", "ḡ", 1, "UTF-8, U+1Exx area");

	s = malloc(bsize + 1);
	if (!s) {
		failed_ok("malloc()"); /* gncov */
		return; /* gncov */
	}
	memset(s, '!', bsize);
	s[bsize] = '\0';
	chk_cs(s, "!!!!!!!!!!", bsize / 10, "Large buffer");
	free(s);
#undef chk_cs
}

/*
 * chk_sr() - Used by test_str_replace(). Verifies that all non-overlapping 
 * occurrences of substring `s1` are replaced with the string `s2` in the 
 * string `s`, resulting in the string `exp`. Returns nothing.
 */

static void chk_sr(const int linenum, const char *s, const char *s1,
                   const char *s2, const char *exp, const char *desc)
{
	char *result;

	assert(desc);

	result = str_replace(s, s1, s2);
	if (!result || !exp)
		OK_EQUAL_L(result, exp, linenum, "str_replace(): %s", desc);
	else
		OK_STRCMP_L(result, exp, linenum, "str_replace(): %s", desc);
	print_gotexp(result, exp);
	free(result);
}

/*
 * test_str_replace() - Tests the str_replace() function. Returns nothing.
 */

static void test_str_replace(void)
{
	char *s;
	size_t bsize = 10000;

	diag("Test str_replace()");

#define chk_sr(s, s1, s2, exp, desc)  chk_sr(__LINE__, (s), (s1), (s2), (exp), (desc))
	chk_sr("", "", "", "", "s, s1, and s2 are empty");
	chk_sr("abc", "", "b", "abc", "s1 is empty");
	chk_sr("", "a", "b", "", "s is empty");
	chk_sr("", "a", "", "", "s and s2 is empty");

	chk_sr(NULL, "a", "b", NULL, "s is NULL");
	chk_sr("abc", NULL, "b", NULL, "s1 is NULL");
	chk_sr("abc", "a", NULL, NULL, "s2 is NULL");
	chk_sr(NULL, NULL, NULL, NULL, "s, s1, and s2 is NULL");

	chk_sr("test", "test", "test", "test", "s, s1, and s2 are identical");
	chk_sr("abc", "b", "DEF", "aDEFc", "abc, replace b with DEF");
	chk_sr("abcabcabc", "b", "DEF", "aDEFcaDEFcaDEFc",
	       "abcabcabc, replace all b with DEF");
	chk_sr("abcdefgh", "defg", "", "abch", "Replace defg with nothing");
	chk_sr("abcde", "bcd", "X", "aXe", "Replace bcd with X");
	chk_sr("abc", "d", "X", "abc", "d not in abc");
	chk_sr("ababab", "aba", "X", "Xbab", "Replace aba in ababab");
	chk_sr("abc", "b", "", "ac", "Replace b with nothing");
	chk_sr("abc", "", "X", "abc", "Replace empty with X");
	chk_sr("Ḡṹṛḡḷḗ", "ḡ", "X", "ḠṹṛXḷḗ", "Replace UTF-8 character with X");

	s = malloc(bsize + 1);
	if (!s) {
		failed_ok("malloc()"); /* gncov */
		return; /* gncov */
	}
	memset(s, '!', bsize);
	s[bsize] = '\0';
	chk_sr(s, "!!!!!!!!!!", "", "", "Replace all text in large buffer");
	free(s);

	s = malloc(bsize + 1);
	if (!s) {
		failed_ok("malloc()"); /* gncov */
		return; /* gncov */
	}
	memset(s, '!', bsize);
	s[1234] = 'y';
	s[bsize - 1] = 'z';
	s[bsize] = '\0';
	chk_sr(s, "!!!!!!!!!!", "", "!!!!y!!!!z",
	       "Large buffer with y and z");
	free(s);
#undef chk_sr
}

/*
 * test_streams_exec() - Tests the streams_exec() function. Returns nothing.
 */

static void test_streams_exec(const struct Options *o)
{
	struct Options mod_opt;
	struct streams ss;
	char *s;

	assert(o);
	diag("Test streams_exec()");

	diag("Send input to the program");
	streams_init(&ss);
	ss.in.buf = "This is sent to stdin.\n";
	ss.in.len = strlen(ss.in.buf);
	mod_opt = *o;
	mod_opt.valgrind = false;
	streams_exec(&mod_opt, &ss, chp{ execname, NULL });
	s = "streams_exec() with stdin data";
	OK_STRCMP(ss.out.buf, "", "%s (stdout)", s);
	OK_STRCMP(ss.err.buf, "", "%s (stderr)", s);
	OK_EQUAL(ss.ret, EXIT_SUCCESS, "%s (retval)", s);
	streams_free(&ss);
}

/******************************************************************************
                   Function tests, use a temporary directory
******************************************************************************/

                                /*** io.c ***/

/******************************************************************************
            Test the executable file, no temporary directory needed
******************************************************************************/

/*
 * test_valgrind_option() - Tests the --valgrind command line option. Returns 
 * nothing.
 */

static void test_valgrind_option(const struct Options *o)
{
	struct streams ss;

	assert(o);
	diag("Test --valgrind");

	if (o->valgrind) {
		struct Options mod_opt = *o; /* gncov */

		mod_opt.valgrind = false; /* gncov */
		streams_init(&ss); /* gncov */
		streams_exec(&mod_opt, &ss, chp{ "valgrind", /* gncov */
		                                 "--version", NULL });
		if (!strstr(ss.out.buf, "valgrind-")) { /* gncov */
			OK_ERROR("Valgrind is not installed," /* gncov */
			         " disabling Valgrind checks");
			set_opt_valgrind(false); /* gncov */
		} else {
			OK_SUCCESS(0, "Valgrind is installed"); /* gncov */
		}
		streams_free(&ss); /* gncov */
	}

	sc((chp{ execname, "--valgrind", "-h", NULL }),
	   "Show this",
	   "",
	   EXIT_SUCCESS,
	   "--valgrind -h");
}

/*
 * print_version_info() - Display output from the --version command. Returns 0 
 * if ok, or 1 if streams_exec() failed.
 */

static int print_version_info(const struct Options *o)
{
	struct streams ss;
	int res;

	assert(o);
	streams_init(&ss);
	res = streams_exec(o, &ss, chp{ execname, "--version", NULL });
	if (res) {
		failed_ok("streams_exec()"); /* gncov */
		if (ss.err.buf) /* gncov */
			diag(ss.err.buf); /* gncov */
		return 1; /* gncov */
	}
	diag("========== BEGIN version info ==========\n"
	     "%s"
	     "=========== END version info ===========", no_null(ss.out.buf));
	streams_free(&ss);

	return 0;
}

/*
 * test_standard_options() - Tests the various generic options available in 
 * most programs. Returns nothing.
 */

static void test_standard_options(void)
{
	char *s;

	diag("Test standard options");

	diag("Test -h/--help");
	sc((chp{ execname, "-h", NULL }),
	   "  Show this help",
	   "",
	   EXIT_SUCCESS,
	   "-h");
	sc((chp{ execname, "--help", NULL }),
	   "  Show this help",
	   "",
	   EXIT_SUCCESS,
	   "--help");

	diag("Test -v/--verbose");
	sc((chp{ execname, "-h", "--verbose", NULL }),
	   "  Show this help",
	   "",
	   EXIT_SUCCESS,
	   "-hv: Help text is displayed");
	sc((chp{ execname, "-hv", NULL }),
	   EXEC_VERSION,
	   "",
	   EXIT_SUCCESS,
	   "-hv: Version number is printed along with the help text");
	sc((chp{ execname, "-vvv", "--verbose", "--help", NULL }),
	   "  Show this help",
	   EXECSTR ": main(): Using verbose level 4\n",
	   EXIT_SUCCESS,
	   "-vvv --verbose: Using correct verbose level");
	sc((chp{ execname, "-vvvvq", "--verbose", "--verbose", "--help", NULL }),
	   "  Show this help",
	   EXECSTR ": main(): Using verbose level 5\n",
	   EXIT_SUCCESS,
	   "--verbose: One -q reduces the verbosity level");

	diag("Test --version");
	s = allocstr("%s %s (%s)\n", execname, EXEC_VERSION, EXEC_DATE);
	if (s) {
		sc((chp{ execname, "--version", NULL }),
		   s,
		   "",
		   EXIT_SUCCESS,
		   "--version");
		free(s);
	} else {
		failed_ok("allocstr()"); /* gncov */
	}
	tc((chp{ execname, "--version", "-q", NULL }),
	   EXEC_VERSION "\n",
	   "",
	   EXIT_SUCCESS,
	   "--version with -q shows only the version number");

	diag("Test --license");
	sc((chp{ execname, "--license", NULL }),
	   "GNU General Public License",
	   "",
	   EXIT_SUCCESS,
	   "--license: It's GPL");
	sc((chp{ execname, "--license", NULL }),
	   "either version 2 of the License",
	   "",
	   EXIT_SUCCESS,
	   "--license: It's version 2 of the GPL");

	diag("Unknown option");
	sc((chp{ execname, "--gurgle", NULL }),
	   "",
	   OPTION_ERROR_STR,
	   EXIT_FAILURE,
	   "Unknown option: \"Option error\" message is printed");
}

/******************************************************************************
              Test the executable file with a temporary directory
******************************************************************************/

/******************************************************************************
                        Top-level --selftest functions
******************************************************************************/

/*
 * functests_with_tempdir() - Tests functions that need a temporary directory 
 * to store the output from stderr and stdout. Returns nothing.
 */

static void functests_with_tempdir(void)
{
	int result;

	diag("Test functions that need a temporary directory for stdout and"
	     " stderr");
	result = mkdir(TMPDIR, 0755);
	OK_SUCCESS(result, "mkdir " TMPDIR " for function tests");
	if (result) {
		diag("test %d: %s, skipping tests", /* gncov */
		     testnum, strerror(errno)); /* gncov */
		errno = 0; /* gncov */
		return; /* gncov */
	}

	result = rmdir(TMPDIR);
	OK_SUCCESS(result, "rmdir " TMPDIR " after function tests");
	if (result) {
		diag("test %d: %s", testnum, strerror(errno)); /* gncov */
		errno = 0; /* gncov */
		return; /* gncov */
	}
}

/*
 * tests_with_tempdir() - Executes tests on the executable with a temporary 
 * directory. The temporary directory uses a standard name, defined in TMPDIR. 
 * If the directory already exists or it's unable to create it, it aborts. 
 * Returns nothing.
 */

static void tests_with_tempdir(void)
{
	int result;

	result = mkdir(TMPDIR, 0777);
	OK_SUCCESS(result, "%s(): Create temporary directory %s",
	                   __func__, TMPDIR);
	if (result) {
		diag("Cannot create directory \"%s\", skipping" /* gncov */
		     " tests: %s", TMPDIR, strerror(errno)); /* gncov */
		errno = 0; /* gncov */
		return; /* gncov */
	}

	OK_SUCCESS(rmdir(TMPDIR), "Delete temporary directory %s", TMPDIR);
}

/*
 * test_functions() - Tests various functions directly. Returns nothing.
 */

static void test_functions(const struct Options *o)
{
	assert(o);

	if (!o->testfunc)
		return; /* gncov */

	diag("Test selftest routines");

	/* selftest.c */
	test_diag();
	test_gotexp_output();
	test_valgrind_lines();
	test_str_replace();

	diag("Test various routines");

	/* STDexecDTS.c */
	test_std_strerror();

	/* io.c */

	/* strings.c */
	test_mystrdup();
	test_allocstr();
	test_count_substr();

	functests_with_tempdir();
}

/*
 * test_executable() - Run various tests with the executable and verify that 
 * stdout, stderr and the return value are as expected. Returns nothing.
 */

static void test_executable(const struct Options *o)
{
	assert(o);
	if (!o->testexec)
		return; /* gncov */

	diag("Test the executable");
	test_valgrind_option(o);
	print_version_info(o);
	test_streams_exec(o);
	test_standard_options();
	tests_with_tempdir();
	print_version_info(o);
}

/*
 * opt_selftest() - Run internal testing to check that it works on the current 
 * system. Executed if --selftest is used. Returns `EXIT_FAILURE` if any tests 
 * fail; otherwise, it returns `EXIT_SUCCESS`.
 */

int opt_selftest(char *main_execname, const struct Options *o)
{
	assert(main_execname);
	assert(o);

	execname = main_execname;
	diag("Running tests for %s %s (%s)",
	     execname, EXEC_VERSION, EXEC_DATE);

	test_ok_macros();
	test_functions(o);
	test_executable(o);

	printf("1..%d\n", testnum);
	if (failcount) {
		diag("Looks like you failed %d test%s of %d.", /* gncov */
		     failcount, (failcount == 1) ? "" : "s", /* gncov */
		     testnum);
	}

	return failcount ? EXIT_FAILURE : EXIT_SUCCESS;
}

#undef EXECSTR
#undef OK_EQUAL
#undef OK_EQUAL_L
#undef OK_ERROR
#undef OK_ERROR_L
#undef OK_FAILURE
#undef OK_FAILURE_L
#undef OK_FALSE
#undef OK_FALSE_L
#undef OK_NOTEQUAL
#undef OK_NOTEQUAL_L
#undef OK_NOTNULL
#undef OK_NOTNULL_L
#undef OK_NULL
#undef OK_NULL_L
#undef OK_STRCMP
#undef OK_STRCMP_L
#undef OK_STRNCMP
#undef OK_STRNCMP_L
#undef OK_SUCCESS
#undef OK_SUCCESS_L
#undef OK_TRUE
#undef OK_TRUE_L
#undef OPTION_ERROR_STR
#undef TMPDIR
#undef chp
#undef failed_ok
#undef print_gotexp_int
#undef print_gotexp_nostr
#undef print_gotexp_size_t
#undef print_gotexp_ulong
#undef sc
#undef tc

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
