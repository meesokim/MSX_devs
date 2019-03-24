;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.8.0 #10562 (Linux)
;--------------------------------------------------------
	.module sc2view
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _malloc
	.globl _copyToVRAM
	.globl _color
	.globl _screen
	.globl _cprintf
	.globl _getch
	.globl _read
	.globl _close
	.globl _open
	.globl _getLastDOSError
	.globl _getDOSType
	.globl _data
	.globl _head
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_head::
	.ds 2
_data::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;src/sc2view.c:32: int main(char** argv, int argc) {
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	push	af
;src/sc2view.c:34: byte errCode = 0;
	ld	-2 (ix), #0x00
;src/sc2view.c:38: cprintf("SC2VIEW v1.0\n\rCopyleft 2018 @ishwin74\n\r");
	ld	hl, #___str_0
	push	hl
	call	_cprintf
	pop	af
;src/sc2view.c:40: if (argc == 0) {
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jr	NZ,00102$
;src/sc2view.c:41: cprintf("Usage: sc2view <filename>\n\r");
	ld	hl, #___str_1
	push	hl
	call	_cprintf
	pop	af
;src/sc2view.c:42: return 0;
	ld	hl, #0x0000
	jp	00113$
00102$:
;src/sc2view.c:45: if (getDOSType() == DOSTYPE_MSXDOS1) {
	call	_getDOSType
	dec	l
	jr	NZ,00104$
;src/sc2view.c:46: cprintf("Error: MSXDOS 2.x needed!\n\r");
	ld	hl, #___str_2
	push	hl
	call	_cprintf
	pop	af
;src/sc2view.c:47: return 1;
	ld	hl, #0x0001
	jp	00113$
00104$:
;src/sc2view.c:50: cprintf("Opening %s...\r\n", argv[0]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	pop	hl
	ld	bc, #___str_3+0
	push	hl
	push	de
	push	bc
	call	_cprintf
	pop	af
	pop	af
	pop	hl
;src/sc2view.c:51: h = open(argv[0], O_RDONLY);
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	a, #0x01
	push	af
	inc	sp
	push	bc
	call	_open
	pop	af
	inc	sp
	ld	-1 (ix), l
;src/sc2view.c:52: if (getLastDOSError()) {
	call	_getLastDOSError
	ld	a, l
	or	a, a
	jr	Z,00106$
;src/sc2view.c:53: cprintf("Error opening file!\r\n");
	ld	hl, #___str_4
	push	hl
	call	_cprintf
	pop	af
;src/sc2view.c:54: return 2;
	ld	hl, #0x0002
	jp	00113$
00106$:
;src/sc2view.c:57: head = malloc(sizeof(SC2HEAD));
	ld	hl, #0x0007
	push	hl
	call	_malloc
	pop	af
	ld	(_head), hl
;src/sc2view.c:58: read(h, head, sizeof(SC2HEAD));
	ld	hl, (_head)
	ld	bc, #0x0007
	push	bc
	push	hl
	ld	a, -1 (ix)
	push	af
	inc	sp
	call	_read
	pop	af
	pop	af
	inc	sp
;src/sc2view.c:59: if (getLastDOSError()) {
	call	_getLastDOSError
	ld	a, l
	or	a, a
	jr	Z,00108$
;src/sc2view.c:60: cprintf("Error reading file!\r\n");
	ld	hl, #___str_5
	push	hl
	call	_cprintf
	pop	af
;src/sc2view.c:61: return 2;
	ld	hl, #0x0002
	jp	00113$
00108$:
;src/sc2view.c:64: size = head->end - head->ini;
	ld	de, (_head)
	ld	l, e
	ld	h, d
	inc	hl
	inc	hl
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ex	de,hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, c
	sub	a, e
	ld	c, a
	ld	a, b
	sbc	a, d
	ld	b, a
;src/sc2view.c:65: data = malloc(size);
	push	bc
	push	bc
	call	_malloc
	pop	af
	pop	bc
	ld	(_data), hl
;src/sc2view.c:67: if (head->magic==0xFE && size<=16384) {
	ld	hl, (_head)
	ld	a, (hl)
	sub	a, #0xfe
	jr	NZ,00110$
	xor	a, a
	cp	a, c
	ld	a, #0x40
	sbc	a, b
	jr	C,00110$
;src/sc2view.c:69: screen(2);
	push	bc
	ld	a, #0x02
	push	af
	inc	sp
	call	_screen
	inc	sp
	ld	de, #0x0101
	push	de
	ld	a, #0x0f
	push	af
	inc	sp
	call	_color
	pop	af
	inc	sp
	pop	bc
;src/sc2view.c:72: read(h, data, size);
	ld	hl, (_data)
	push	bc
	push	bc
	push	hl
	ld	a, -1 (ix)
	push	af
	inc	sp
	call	_read
	pop	af
	pop	af
	inc	sp
	pop	bc
;src/sc2view.c:73: copyToVRAM((word)data, head->ini, size);
	ld	hl, (_head)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, (_data)
	push	bc
	push	de
	push	hl
	call	_copyToVRAM
	pop	af
	pop	af
	pop	af
;src/sc2view.c:75: getch();
	call	_getch
;src/sc2view.c:77: color(15, 4, 4);
	ld	de, #0x0404
	push	de
	ld	a, #0x0f
	push	af
	inc	sp
	call	_color
	pop	af
	inc	sp
;src/sc2view.c:78: screen(0);
	xor	a, a
	push	af
	inc	sp
	call	_screen
	inc	sp
	jr	00111$
00110$:
;src/sc2view.c:80: cprintf("Bad SCREEN 2 file format!\n\r");
	ld	hl, #___str_6
	push	hl
	call	_cprintf
	pop	af
;src/sc2view.c:81: errCode = 4;
	ld	-2 (ix), #0x04
00111$:
;src/sc2view.c:84: close(h);
	ld	a, -1 (ix)
	push	af
	inc	sp
	call	_close
	inc	sp
;src/sc2view.c:86: return errCode;
	ld	l, -2 (ix)
	ld	h, #0x00
00113$:
;src/sc2view.c:87: }
	pop	af
	pop	ix
	ret
___str_0:
	.ascii "SC2VIEW v1.0"
	.db 0x0a
	.db 0x0d
	.ascii "Copyleft 2018 @ishwin74"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_1:
	.ascii "Usage: sc2view <filename>"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_2:
	.ascii "Error: MSXDOS 2.x needed!"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_3:
	.ascii "Opening %s..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_4:
	.ascii "Error opening file!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_5:
	.ascii "Error reading file!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_6:
	.ascii "Bad SCREEN 2 file format!"
	.db 0x0a
	.db 0x0d
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
