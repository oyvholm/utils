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
 * selftest() - Run internal testing to check that it works on the current 
 * system. Executed if --selftest is used. Returns EXIT_FAILURE any tests fail; 
 * otherwise, return EXIT_SUCCESS.
 */

int selftest(void)
{
	unsigned int errcount = 0;

	errno = EACCES;
	puts("# myerror(\"errno is EACCES\")");
	myerror("errno is EACCES");
	errno = 0;

	return errcount ? EXIT_FAILURE : EXIT_SUCCESS;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
