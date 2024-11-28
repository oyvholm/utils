/*
 * binbuf.c
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
 * binbuf_init() - Prepare a `struct binbuf` for use, returns nothing.
 */

void binbuf_init(struct binbuf *sb)
{
	assert(sb);
	sb->alloc = sb->len = 0;
	sb->buf = NULL;
}

/*
 * binbuf_free() - Deallocate a `struct binbuf` and set struct values to 
 * initial state.
 */

void binbuf_free(struct binbuf *sb)
{
	assert(sb);
	if (sb->alloc)
		free(sb->buf);
	binbuf_init(sb);
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
