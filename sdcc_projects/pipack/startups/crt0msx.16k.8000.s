; crt0 for MSX ROM of 32KB, starting at 0x4000
; includes detection and set of ROM page 2 (0x8000 - 0xbfff)
; suggested options: --code-loc 0x8020 --data-loc 0xc000

.globl	_main
.globl _putchar
.globl _getchar
.globl _WaitForKey

.area _HEADER (ABS)
; Reset vector
	.org 0x8000
	.db  0x41
	.db  0x42
	.dw  init
	.dw  0x0000
	.dw  0x0000
	.dw  0x0000
	.dw  0x0000
	.dw  0x0000
	.dw  0x0000

init:
	ld      sp,(0xfc4a) ; Stack at the top of memory.
	call    _main ; Initialise global variables
	call    #0x0000; call CHKRAM

; Ordering of segments for the linker.
	.area	_CODE

;char.c:3: void putchar(char chr) {
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar_start::
_putchar:
	push ix
	ld   ix, #0
	add  ix, sp
;char.c:7: __endasm;
	ld   a, 4(ix)
	cp   a, #0x0a
	jr   nz, 2$
1$:	ld   a, #0x0d
	call 0x00A2 ; call CHPUT
	ld   a, #0x0a
2$:	call 0x00A2 ; call CHPUT
	pop  ix
	ret
_putchar_end::

;char.c:10: char getchar(void) {
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar_start::
_getchar:
;char.c:15: __endasm;
	call 0x009F
	ld h,#0x00
	ld l,a
	ret
_getchar_end::

	.area   _GSINIT
	.area   _GSFINAL

	.area   _DATA
	.area   _BSS
	.area   _CODE

; ------------------------------------------
; Special RLE decoder used for initing global data

__initrleblock::
	; Pull the destination address out
	ld      c,l
	ld      b,h
	; Pop the return address
	pop     hl
1$:	; Fetch the run
	ld      e,(hl)
	inc     hl
	; Negative means a run
	bit     7,e
	jp      z,2$
	; Code for expanding a run
	ld      a,(hl)
	inc     hl
3$:	ld      (bc),a
	inc     bc
	inc     e
	jp      nz,3$
	jp      1$
2$:	; Zero means end of a block
	xor     a
	or      e
	jp      z,4$
	; Code for expanding a block
5$:	ld      a,(hl)
	inc     hl
	ld      (bc),a
	inc     bc
	dec     e
	jp      nz,5$
	jp      1$
4$:	; Push the return address back onto the stack
	push    hl
	ret

_WaitForKey::
	call	_waitakey
	ld	l,a
	ld	h,#0
	ret
	
_waitakey:
		; wait for keypress
	di
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x009f
	ei
;-----------------------------------------------
_ClearKeyBuffer::
		; clear key buffer after
	di
	push	af
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0156
	pop	af
	ei
	ret	

	.area   _GSINIT

gsinit::
	.area   _GSFINAL
	ret
