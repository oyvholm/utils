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

#ifndef _STDUexecUDTS_H
#define _STDUexecUDTS_H

#include "version.h"

#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <getopt.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "binbuf.h"

#if 1
#  define DEBL  msg(2, "DEBL: %s, line %u in %s()", \
                       __FILE__, __LINE__, __func__)
#else
#  define DEBL  ;
#endif

#ifdef CHECK_ERRNO
#define check_errno  do { \
	if (errno) { \
		myerror("%s():%s:%d: errno = %d", \
		        __func__, __FILE__, __LINE__, errno); \
	} \
} while (0)
#else
#define check_errno  do { } while (0)
#endif

#define failed(a)  myerror("%s():%d: %s failed", __func__, __LINE__, (a))
#define no_null(a)  ((a) ? (a) : "(null)")

struct Options {
	/* sort -d -k2 */
	bool help;
	bool license;
	bool selftest;
	bool testexec;
	bool testfunc;
	bool valgrind;
	int verbose;
	bool version;
};

struct streams {
	struct binbuf in;
	struct binbuf out;
	struct binbuf err;
	int ret;
};

/*
 * Public function prototypes
 */

/* STDexecDTS.c */
struct Options opt_struct(void);
int msg(const int verbose, const char *format, ...);
const char *std_strerror(const int errnum);
int myerror(const char *format, ...);
void init_opt(struct Options *dest);
void set_opt_valgrind(bool b);

/* io.c */
void streams_init(struct streams *dest);
void streams_free(struct streams *dest);
char *read_from_fp(FILE *fp, struct binbuf *dest);
int streams_exec(const struct Options *o, struct streams *dest, char *cmd[]);

/* selftest.c */
int opt_selftest(char *execname, const struct Options *o);

/* strings.c */
char *mystrdup(const char *s);
char *allocstr_va(const char *format, va_list ap);
char *allocstr(const char *format, ...);
size_t count_substr(const char *s, const char *substr);
char *str_replace(const char *s, const char *s1, const char *s2);

#endif /* ifndef _STDUexecUDTS_H */

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
