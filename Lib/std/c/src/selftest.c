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
#define failed_ok(a)  do { \
	if (errno) \
		ok(1, "%s():%d: %s failed: %s", \
		      __func__, __LINE__, (a), std_strerror(errno)); \
	else \
		ok(1, "%s():%d: %s failed", __func__, __LINE__, (a)); \
	errno = 0; \
} while (0)

static char *execname;
static int failcount = 0;
static int testnum = 0;

/******************************************************************************
                             --selftest functions
******************************************************************************/

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
		failed_ok("allocstr()"); /* gncov */

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

static void test_command(const char identical, char *cmd[],
                         const char *exp_stdout, const char *exp_stderr,
                         const int exp_retval, const char *desc, va_list ap)
{
	const struct Options o = opt_struct();
	struct streams ss;
	char *e_stdout, *e_stderr, *descbuf;

	assert(cmd);
	assert(desc);
	if (!cmd) {
		ok(1, "%s(): cmd is NULL", __func__); /* gncov */
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
		ok(tc_cmp(identical, ss.out.buf, e_stdout),
		   "%s (stdout)", descbuf);
		if (tc_cmp(identical, ss.out.buf, e_stdout))
			print_gotexp(ss.out.buf, e_stdout); /* gncov */
	}
	if (e_stderr) {
		ok(tc_cmp(identical, ss.err.buf, e_stderr),
		   "%s (stderr)", descbuf);
		if (tc_cmp(identical, ss.err.buf, e_stderr))
			print_gotexp(ss.err.buf, e_stderr); /* gncov */
	}
	ok(!(ss.ret == exp_retval), "%s (retval)", descbuf);
	free(descbuf);
	free(e_stderr);
	free(e_stdout);
	if (ss.ret != exp_retval) {
		char *g = allocstr("%d", ss.ret), /* gncov */
		     *e = allocstr("%d", exp_retval); /* gncov */
		if (!g || !e) /* gncov */
			failed_ok("allocstr()"); /* gncov */
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
               const int exp_retval, const char *desc, ...)
{
	va_list ap;

	assert(cmd);
	assert(desc);

	va_start(ap, desc);
	test_command(0, cmd, exp_stdout, exp_stderr, exp_retval, desc, ap);
	va_end(ap);
}

/*
 * tc() - Execute command `cmd` and verify that stdout, stderr and the return 
 * value are identical to the expected values. The `exp_*` variables are 
 * strings that must be identical to the actual output. Returns nothing.
 */

static void tc(char *cmd[], const char *exp_stdout, const char *exp_stderr,
               const int exp_retval, const char *desc, ...)
{
	va_list ap;

	assert(cmd);
	assert(desc);

	va_start(ap, desc);
	test_command(1, cmd, exp_stdout, exp_stderr, exp_retval, desc, ap);
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

	p = diag_output("\n\n\n\n\n\n\n\n\n\n");
	ok(!p, "diag_output() with only newlines didn't return NULL");
	s = "# \n# \n# \n# \n# \n# \n# \n# \n# \n# \n# ";
	ok(p ? !!strcmp(p, s) : 1, "diag_output() with only newlines");
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
 * test_std_strerror() - Tests the std_strerror() function. Returns nothing.
 */

static void test_std_strerror(void)
{
	diag("Test std_strerror()");
	ok(!!strcmp(std_strerror(EACCES), "Permission denied"),
	   "std_strerror(EACCES) is as expected");
}

                                /*** io.c ***/

                              /*** strings.c ***/

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
 * chk_cs() - Used by test_count_substr(). Verifies that the number of 
 * non-overlapping substrings `substr` inside string `s` is `count`. `desc` is 
 * the test description. Returns nothing.
 */

static void chk_cs(const char *s, const char *substr, const size_t count,
                   const char *desc)
{
	size_t result;

	result = count_substr(s, substr);
	ok(!(result == count), "count_substr(): %s", desc);
	if (result != count) {
		char *s_result = allocstr("%zu", result), /* gncov */
		     *s_count = allocstr("%zu", count); /* gncov */
		if (s_result && s_count) /* gncov */
			print_gotexp(s_result, s_count); /* gncov */
		else
			failed_ok("allocstr()"); /* gncov */
		free(s_count); /* gncov */
		free(s_result); /* gncov */
	}
}

/*
 * test_count_substr() - Tests the count_substr() function. Returns nothing.
 */

static void test_count_substr(void)
{
	char *s;
	size_t bsize = 10000;

	diag("Test count_substr()");

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
}

/*
 * chk_sr() - Used by test_str_replace(). Verifies that all non-overlapping 
 * occurrences of substring `s1` are replaced with the string `s2` in the 
 * string `s`, resulting in the string `exp`. Returns nothing.
 */

static void chk_sr(const char *s, const char *s1, const char *s2,
                   const char *exp, const char *desc)
{
	char *result;

	assert(desc);

	result = str_replace(s, s1, s2);
	if (!result || !exp) {
		ok(!(result == exp), "str_replace(): %s", desc);
	} else {
		ok(!!strcmp(result, exp), "str_replace(): %s", desc);
		print_gotexp(result, exp);
	}
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
	ok(!!strcmp(ss.out.buf, ""), "%s (stdout)", s);
	ok(!strstr(ss.err.buf, ""), "%s (stderr)", s);
	ok(!(ss.ret == EXIT_SUCCESS), "%s (retval)", s);
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
			ok(1, "Valgrind is not installed," /* gncov */
			      " disabling Valgrind checks");
			set_opt_valgrind(false); /* gncov */
		} else {
			ok(0, "Valgrind is installed"); /* gncov */
		}
		streams_free(&ss); /* gncov */
	}

	sc(chp{ execname, "--valgrind", "-h", NULL },
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
	     "=========== END version info ===========",
	     ss.out.buf ? ss.out.buf : "(null)");
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
	   EXECSTR ": main(): Using verbose level 4\n",
	   EXIT_SUCCESS,
	   "-vvv --verbose: Using correct verbose level");
	sc(chp{ execname, "-vvvvq", "--verbose", "--verbose", "--help", NULL },
	   "  Show this help",
	   EXECSTR ": main(): Using verbose level 5\n",
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
		failed_ok("allocstr()"); /* gncov */
	}
	tc(chp{ execname, "--version", "-q", NULL },
	   EXEC_VERSION "\n",
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
 * test_functions() - Tests various functions directly. Returns nothing.
 */

static void test_functions(const struct Options *o)
{
	assert(o);

	if (!o->testfunc)
		return; /* gncov */

	diag("Test selftest routines");

	/* selftest.c */
	ok(!ok(0, NULL), "ok(0, NULL)");
	test_diag();
	test_gotexp_output();
	test_valgrind_lines();
	test_str_replace();

	diag("Test various routines");

	/* STDexecDTS.c */
	test_std_strerror();

	/* io.c */

	/* strings.c */
	test_allocstr();
	test_count_substr();
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
#undef OPTION_ERROR_STR
#undef chp
#undef failed_ok

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
