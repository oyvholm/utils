
/*
 * $Id$
 * Setuid program som setter til min type tastaturhastighet.
 * Store ting.
 */

#include <stdlib.h>

static char rcs_id[] = "$Id$";

int main(void) {
	setenv("IFS", "", 1);
	system("/sbin/kbdrate -r 30 -d 250");
	return(0);
}
