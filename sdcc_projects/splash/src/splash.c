/**
    slpash.c
    Purpose: MSX1 Screen 2 Viewer

    @author Miso Kim
    @version 1.0 06/02/2019
*/
#include "msx.h"
#include "types.h"
#include "vdp_tms9918.h"
#include "heap.h"

extern byte data[];

#define BUFFER_SIZE		2048

/**
	ROM entry point
*/
void main(void) {

	int a = 0x1800;
	int i = 0;
	int scr = (int)(data);
	scr = scr + 2;
	screen(2);
	color(15, 1, 1);
	copyToVRAM((int)scr, 0x2000, a);
	copyToVRAM((int)(scr+a), 0x000, a);

	getch();

	__asm__ ("call 0");
	return;
}
 