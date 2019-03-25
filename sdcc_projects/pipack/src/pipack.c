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
#include <stdio.h>
#include <string.h>

static int cprintf(const char *format, ...);
static void _printf(const char *format, va_list va);
extern const unsigned char src_msx_alf[];
extern int src_msx_alf_len;
extern int WaitForKey();
#define CGFNT 0xf920
#define CSRSW 0xFCA9
#define KEY_UP 30
#define KEY_DOWN 31
#define KEY_ENTER 13
#define KEY_TAB 8
#define poke(a, b) *(unsigned char *)a = b
#define pokew(a, b) *(unsigned int *)a = b

#define BUFFER_SIZE		2048

void run0(int a)
{
	a;
	__asm
	jp 0xd000
	call 0
	ret
	__endasm;
}
void easyrun(int i)
{
	i;
	__asm
	push ix
	ld   ix, #4
	add  ix, sp
	ld   a, #0x80
	ld   b, a
	ld   c, #0x21
	ld   a, (ix)
	out (c), a
	ld   a, 1(ix)
	out (c), a
	pop  ix
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld  hl,#0x4000
	ld a, (hl)
	cp #0x41
	jr nz, next
	ld  hl,(#0x4008)
	ld a, h
	or l
	jr nz, basic
	ld	hl,(#0x400e)
	jp (hl)
	ret
next:
	ld  hl,(#0x8008)
	ld a, h
	or l
	jr nz, basic
	ld hl,(#0x800e)
	jp (hl)
basic:
	jp 0
	ret
	__endasm;
}

/**
	ROM entry point
*/
void main(void) {

	char a = 0, c = 0;
	int i = 0, j =0, cmax, cstart, cpos;
	int  cursor = 0;
	char string[256];
#if 0	
	unsigned char title[400*40];
#else
	unsigned char *title;
#endif
	const unsigned char *str = (unsigned char *)0x6000;
	const unsigned char *empty = "\x16                                      \x16";
	unsigned int scr = (unsigned int)(src_msx_alf);
	color(15, 4, 0);
	screen(0);
	scr = scr + 7;
	copyToVRAM(scr, 0x800, 0x800);
	locate(0,0);
	for(i=0;i<40;i++)
		printf("\1W");
	vpoke(0,0x18);
	vpoke(39,0x19);
	locate(2,0);
#if 0	
	while(1)
	{
		cstart = 40*i;
		a = 38;
		title[cstart++] = 0x16;
		while(str[j])
		{
			if (a-- > 0)
			{
				title[cstart++] = str[j];
			} 
			j++;
		}
		if (a == 0)
			title[cstart-1] = '.';
		else
		{
			while(a--)
				title[cstart++] = ' ';
		}
		title[cstart] = 0x16;
		if (!str[j+1] || i > 799)
			break;
		j++;
		i++;
	};
	for(;i < 23; i++)
	{
		cstart = 40 * i;
		a = 38;
		title[cstart++] = 0x16;
		while(a--)
			title[cstart++] = ' ';
		title[cstart] = 0x16;
	}
	cmax = i - 1;
#else
	cmax = str[0] + str[1] * 256;
	cursor = str[2] + str[3] * 256;
	title = str + 4;
	copyToVRAM((int)" \x89\x8a\x8b Pi Super Pack : ", 3, 20);
#endif
//	*(int *)CGFNT=scr;
	vpoke(40*23,0x1a);
	locate(0,23);
	for(i=0;i<38;i++)
		printf("\1W");
	locate(8,23);
	printf(" meeso.kim@gmail.com ");
	vpoke(0x3bf,0x1b);
	if (cursor > 11)
		cstart = cursor - 11;
	else
		cstart = 0;
	cpos = 0;
	poke(CSRSW, 1);
	memcpy((void*)0xd000, easyrun, 100);
	while(1)
	{
		j = cmax - cstart + 1;
		sprintf(string, "%d/%d \x17\x17\x17", cursor+1, cmax+1);
		copyToVRAM((int)string, 23, 9);
		if (j > 22) j = 22;
		copyToVRAM((int)title+cstart*40, 40, 40*j);
		if (j < 22)
			for(i=j+1;i<23;i++)
				copyToVRAM((int)empty, 40*i, 40);
		i = cursor-cstart;
		str = title + cursor * 40 + 1;
		for(a=0;a<39;a++)
			string[a] = str[a] + 0x70;
		copyToVRAM((int)string, 40*(i+1)+1, 38);

		a = getch();
		if (a == KEY_UP && cursor > 0)
		{
			cursor--;
			if (cstart > cursor)
				cstart--;
		}
		else if (a == KEY_DOWN && cursor < cmax)
		{
			cursor++;
			if (cursor > cstart + 21)
				cstart++;
		}
		else if (a == '2')
		{
			
			if (cursor - cstart < 21)
			{
				cursor = cstart + 21;
			}
			else
			{
				cursor += 22;
				cstart += 22;
			}
			if (cursor > cmax)
				cursor = cmax;
			if (cstart > cmax)
				cstart = cmax;
		}
		else if (a == '1')
		{
			if (cursor > cstart)
				cursor = cstart;
			else if (cursor == cstart)
			{
				cursor -= 22;
				cstart -= 22;
			}
			if (cursor < 0)
				cursor = 0;
			if (cstart < 0)
				cstart = 0;
		}
		else if (a == KEY_ENTER)
		{
			run0(cursor);
		}
	}
	return;
}

static char inv = 0;

static void putch(unsigned char c)
{
	if (c == '\2')
	{	
		inv = 1;
		return;
	}
	else if (c == '\3')
	{
		inv = 0;
		return;
	}
	else if (c == '\n')
		putchar('\r');
	if (c >= ' ' && c <= '~' && inv)
		c += 0x70;
	putchar(c);
}

/**
	Simple cprintf implementation.
	Supports %c %s %u %d %x %b
 */
int cprintf(const char *format, ...)
{
	va_list va;
	va_start(va, format);

	_printf(format, va);

	/* return printed chars */
	return 0;
}


static void _printn(unsigned u, unsigned base, char issigned)
{
	const char *_hex = "0123456789ABCDEF";
	if (issigned && ((int)u < 0)) {
		putch('-');
		u = (unsigned)-((int)u);
	}
	if (u >= base)
		_printn(u/base, base, 0);
	putch(_hex[u%base]);
}

static void _printf(const char *format, va_list va)
{
	inv = 0;
	while (*format) {
		if (*format == '%') {
			switch (*++format) {
				case 'c': {
					char c = (char)va_arg(va, int);
					putch(c);
					break;
				}
				case 'u': {
					unsigned u = va_arg(va, unsigned);
					_printn(u, 10, 0);
					break;
				}
				case 'd': {
					unsigned u = va_arg(va, unsigned);
					_printn(u, 10, 1);
					break;
				}
				case 'x': {
					unsigned u = va_arg(va, unsigned);
					_printn(u, 16, 0);
					break;
				}
				case 'b': {
					unsigned u = va_arg(va, unsigned);
					_printn(u, 2, 0);
					break;
				}
				case 's': {
					char *s = va_arg(va, char *);
					while (*s) {
						putch(*s);
						s++;
					}
				}
			}
		} else {
			putch(*format);
		}
	format++;
	}
}



void puthex(int8_t nibbles, uint16_t v) {
	int8_t i = nibbles - 1;
	while (i >= 0) {
		uint16_t aux = (v >> (i << 2)) & 0x000F;
		uint8_t n = aux & 0x000F;
		if (n > 9)
			putch('A' + (n - 10));
		else
			putch('0' + n);
		i--;
	}
}

void puthex8(uint8_t v) {
	puthex(2, (uint16_t) v);
}


void puthex16(uint16_t v) {
	puthex(4, v);
}

void putdec(int16_t digits, uint16_t v) {
	while (digits > 0) {
		uint16_t aux = v / digits;
		uint8_t n = aux % 10;
		putch('0' + n);
		digits /= 10;
	}
}

void putdec8(uint8_t v) {
	putdec(100, (uint16_t) v);
}


void putdec16(uint16_t v) {
	putdec(10000, v);
} 