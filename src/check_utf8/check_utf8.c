
/*
 * $Id$
 * Small tool to figure whenever a tty runs in UTF-8 mode or not.
 * Writes a UTF-8 multibyte sequence and then checks how far the
 * cursor has been moved.
 *
 * Return codes:
 *      0 - don’t know (stdin isn’t a terminal, timeout, some error, ...)
 *      1 - not in utf8
 *      2 - utf-8
 *
 * Written by Gerd Krorr, unknown email address. Minor modifications by
 * Øyvind A. Holm <sunny@sunbase.org>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <termios.h>

static char rcs_id[] = "$Id$";

struct termios  saved_attributes;
int             saved_fl;

void
tty_raw()
{
	struct termios tattr;

	fcntl(0,F_GETFL,&saved_fl);
	tcgetattr (0, &saved_attributes);

	fcntl(0,F_SETFL,O_NONBLOCK);
	memcpy(&tattr,&saved_attributes,sizeof(struct termios));
	tattr.c_lflag &= ~(ICANON|ECHO);
	tattr.c_cc[VMIN] = 1;
	tattr.c_cc[VTIME] = 0;
	tcsetattr (0, TCSAFLUSH, &tattr);
}

void
tty_restore()
{
	fcntl(0,F_SETFL,saved_fl);
	tcsetattr (0, TCSANOW, &saved_attributes);
}

int
select_wait()
{
	struct timeval  tv;
	fd_set          se;

	FD_ZERO(&se);
	FD_SET(0,&se);
	tv.tv_sec = 3;
	tv.tv_usec = 0;
	return select(1,&se,NULL,NULL,&tv);
}

int
main(int argc, char **argv)
{
	static char *teststr = "\r\xc3\xb6";
	static char *cleanup = "\r  \r";
	static char *getpos  = "\033[6n";
	char retstr[16];
	int pos,rc,row,col;
	ssize_t ss;

	(void)(rcs_id); /* Avoid compiler warning */
	if (!isatty(0))
		exit(0);

	tty_raw();
	ss = write(1,teststr,strlen(teststr));
	ss = write(1,getpos,strlen(getpos));
	for (pos = 0; pos < sizeof(retstr)-1;) {
		if (0 == select_wait())
			break;
		if (-1 == (rc = read(0,retstr+pos,sizeof(retstr)-1-pos))) {
			perror("read");
			exit(0);
		}
		pos += rc;
		if (retstr[pos-1] == 'R')
			break;
	}
	retstr[pos] = 0;
	ss = write(1,cleanup,strlen(cleanup));
	if (ss == -1)
		perror("Error when writing to stdout");
	tty_restore();

	rc = sscanf(retstr,"\033[%d;%dR",&row,&col);
	if (2 == rc && 2 == col) {
		/* fprintf(stderr,"Terminal is in UTF-8 mode.\n"); */
		exit(2);
	}
	exit(1);
}
