
/*

   NB! Husk å forandre navn på rcs_id_std_h til det den skal være.

 * Main header file
 * $Id$
 *
 * (C)opyleft Øyvind A. Holm <sunny@sunbase.org>
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
 * along with this program; if not, write to the Free Software 
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
 * USA
 */

#ifndef _STD_H
#define _STD_H

/*
 * Defines
 */

#define FALSE  0
#define TRUE   1

#define EXIT_OK     0
#define EXIT_ERROR  1

#define ENGLISH    1

#ifndef C_LANG
#  define C_LANG  ENGLISH
#endif

#if C_LANG == ENGLISH
#  define MSG_LANGUAGE  "English"
#else
#  error C_LANG is not correctly defined
#endif

#ifdef C_ASSERT
#  ifdef NDEBUG
#    undef NDEBUG
#  endif            /* ifdef NDEBUG        */
#else               /* ifdef C_ASSERT      */
#  define NDEBUG  1
#endif              /* ifdef C_ASSERT else */

#ifdef C_SKIP_LICENSE /* If C_SKIP_LICENSE, the --license option is disabled. */
#  ifdef C_LICENSE
#    undef C_LICENSE
#  endif
#else
#  define C_LICENSE  1
#endif

/*
 * Macros
 */

#define in_range(a,b,c)  ((a) >= (b) && (a) <= (c) ? TRUE : FALSE)
#define myerror(a)       { fprintf(stderr, "%s: ", progname); perror(a); }

#define debpr0(a)              if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a)); }
#define debpr1(a,b)            if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b)); }
#define debpr2(a,b,c)          if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c)); }
#define debpr3(a,b,c,d)        if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d)); }
#define debpr4(a,b,c,d,e)      if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d),(e)); }
#define debpr5(a,b,c,d,e,f)    if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d),(e),(f)); }
#define debpr6(a,b,c,d,e,f,g)  if (debug) { fprintf(stddebug, "%s: debug: ", progname); fprintf(stddebug, (a),(b),(c),(d),(e),(f),(g)); }

/*
 * Typedefs
 */

typedef unsigned char bool;

/*
 * Function prototypes
 */

extern void print_version(void);
extern void usage(int);

/*
 * Global variables
 */

static char rcs_id_std_h[] = "$Id$";
extern char *progname;
extern int  debug;
extern FILE *stddebug;

#endif /* ifndef _STD_H */

/* vim: set ts=4 sw=4 sts=4 et fo+=w fenc=UTF-8 : */
/***** End of file $Id$ *****/
