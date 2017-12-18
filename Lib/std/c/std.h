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

#define FALSE  0
#define TRUE   1

#define T_RESET  "\x1b[m\x0f"
#define T_RED    "\x1b[31m"
#define T_GREEN  "\x1b[32m"

#define stddebug  stderr

#include <assert.h>
#include <errno.h>
#include <getopt.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEBL  msg(2, "%s, line %u in %s()", __FILE__, __LINE__, __func__)
#define in_range(a,b,c)  ((a) >= (b) && (a) <= (c) ? TRUE : FALSE)

typedef unsigned char bool;
struct Options {
	bool help;
	bool license;
	int verbose;
	bool version;
};

/*
 * Public function prototypes
 */

/* STDexecDTS.c */

/*
 * Global variables
 */

extern char *progname;

#endif /* ifndef _STDUexecUDTS_H */

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
