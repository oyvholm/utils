
/*
 * $Id: kbd.c,v 1.1 2001/10/12 23:01:49 sunny Exp $
 * Setuid program som setter til min type tastaturhastighet.
 * Store ting.
 */

#include <stdlib.h>

static char rcs_id[] = "$Id: kbd.c,v 1.1 2001/10/12 23:01:49 sunny Exp $";

int main(void) {
	setenv("IFS", "", 1);
	system("/sbin/kbdrate -r 30 -d 250");
	return(0);
}
