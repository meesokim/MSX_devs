;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (MINGW64)
;--------------------------------------------------------
	.module splash
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _copyToVRAM
	.globl _color
	.globl _screen
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
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
;src/splash.c:20: void main(void) {
;	---------------------------------
; Function main
; ---------------------------------
_main::
;src/splash.c:24: int scr = (int)(data);
	ld	bc,#_data+0
;src/splash.c:25: scr = scr + 2;
	inc	bc
	inc	bc
;src/splash.c:26: screen(2);
	push	bc
	ld	a,#0x02
	push	af
	inc	sp
	call	_screen
	inc	sp
	ld	hl,#0x0101
	push	hl
	ld	a,#0x0f
	push	af
	inc	sp
	call	_color
	pop	af
	inc	sp
	pop	bc
;src/splash.c:28: copyToVRAM((int)scr, 0x2000, a);
	push	bc
	ld	hl,#0x1800
	push	hl
	ld	h, #0x20
	push	hl
	push	bc
	call	_copyToVRAM
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	bc
;src/splash.c:29: copyToVRAM((int)(scr+a), 0x000, a);
	ld	hl,#0x1800
	add	hl,bc
	ld	bc,#0x1800
	push	bc
	ld	bc,#0x0000
	push	bc
	push	hl
	call	_copyToVRAM
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;src/splash.c:31: getch();
	call	0x9f
;src/splash.c:33: __asm__ ("call 0");
	call	0
;src/splash.c:34: return;
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
