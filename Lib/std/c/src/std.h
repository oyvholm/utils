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
#include <errno.h>
#include <getopt.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "binbuf.h"

#if 1
#  define DEBL  msg(VERBOSE_TRACE, "DEBL: %s, line %u in %s()", \
                                   __FILE__, __LINE__, __func__)
#else
#  define DEBL  ;
#endif

/*
 * Verbose levels:
 *
 * VERBOSE_QUIET:
 *   - Used when the program should be as quiet as possible.
 *   - Only the most essential output, such as the version number or critical 
 *     error messages, should be displayed at this level.
 *   - This level is typically used when the program is invoked by scripts or 
 *     other automated processes that require minimal output.
 *
 * VERBOSE_NONE:
 *   - Default level when no verbose flags are set.
 *   - Only critical error messages that prevent the program from running 
 *     should be displayed at this level.
 *
 * VERBOSE_ERROR:
 *   - Used to display error messages indicating that something has gone wrong, 
 *     but not necessarily stopping the program.
 *   - Example: Errors when opening a file, invalid input, etc.
 *
 * VERBOSE_WARN:
 *   - For warnings about potential problems or unexpected situations.
 *   - These messages indicate something that might be problematic, but not 
 *     necessarily an error.
 *   - Example: Use of deprecated functions, unexpected input format that can 
 *     still be handled, etc.
 *
 * VERBOSE_INFO:
 *   - General information about the program's progress or state.
 *   - Used to give the user insight into what the program is doing without 
 *     going into technical details.
 *   - Example: "Calculation started", "File loaded", "Result saved", etc.
 *
 * VERBOSE_DEBUG:
 *   - Detailed messages for debugging.
 *   - Includes information such as variable values, intermediate results, and 
 *     function calls.
 *   - Primarily used by developers to understand the program's internal state.
 *
 * VERBOSE_TRACE:
 *   - Extremely detailed messages that trace the program's flow.
 *   - Includes entry and exit from functions, loop iterations, etc.
 *   - Used for in-depth debugging and analysis of program flow.
 */

typedef enum {
	VERBOSE_QUIET = -1,
	VERBOSE_NONE,
	VERBOSE_ERROR,
	VERBOSE_WARN,
	VERBOSE_INFO,
	VERBOSE_DEBUG,
	VERBOSE_TRACE
} VerboseLevel;

struct Options {
	bool help;
	bool license;
	bool selftest;
	bool valgrind;
	VerboseLevel verbose;
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
int msg(const VerboseLevel verbose, const char *format, ...);
int myerror(const char *format, ...);

/* io.c */
void streams_init(struct streams *dest);
void streams_free(struct streams *dest);
int streams_exec(struct streams *dest, char *cmd[]);

/* selftest.c */
int opt_selftest(void);

/* strings.c */
char *allocstr(const char *format, ...);

/*
 * Global variables
 */

extern char *progname;
extern struct Options opt;

#endif /* ifndef _STDUexecUDTS_H */

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
