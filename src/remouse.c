
/* $Id: remouse.c,v 1.1 2000/07/08 11:02:49 sunny Exp $ 
 * Reload av gpm. Skal kjøres setuid root. 
 */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
	return system("/etc/rc.d/init.d/gpm reload");
}
