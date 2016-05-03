;	Static Name Aliases
;
;	$S13_a	EQU	a
;	$S19_A	EQU	A
	TITLE   modulo

	.286p
	.287
MODULO_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
MODULO_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: MODULO_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__aulrem:FAR
EXTRN	__ulrem:FAR
EXTRN	__alrem:FAR
EXTRN	__lrem:FAR
EXTRN	__blrem:FAR
_DATA      SEGMENT
$SG22	DB	'%d %d %d %d   %d %d',  0aH, '%d %d %d %d   %d    %d %d',  0aH
	DB	00H
	EVEN
$S13_a	DB	01H
	DB	02H
	DB	03H
	DB	04H
	DB	05H
	DB	06H
	DB	07H
	EVEN
$S19_A	DD	08H
	DD	09H
	DD	0aH
	DD	0bH
	DD	0cH
	DD	01H
	DD	02H
	DD	03H
	DD	04H
	DD	05H
	DD	06H
_DATA      ENDS
MODULO_TEXT      SEGMENT
; Line 4
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,32
	call	FAR PTR __chkstk
;	c = -2
;	C = -4
;	p = -8
;	P = -12
;	s = -14
;	S = -16
;	i = -20
;	I = -24
;	l = -28
;	L = -32
; Line 5
	mov	BYTE PTR [bp-2],25	;c
; Line 6
	mov	WORD PTR [bp-14],932	;s
; Line 7
	mov	WORD PTR [bp-20],-22062	;i
	mov	WORD PTR [bp-18],-157
; Line 8
	mov	WORD PTR [bp-28],7607	;l
	mov	WORD PTR [bp-26],431
; Line 10
	mov	ax,OFFSET DGROUP:$S13_a+5
	mov	[bp-8],ax	;p
	mov	[bp-6],ds
; Line 11
	mov	BYTE PTR [bp-4],123	;C
; Line 12
	mov	WORD PTR [bp-16],117	;S
; Line 13
	mov	WORD PTR [bp-24],14392	;I
	mov	WORD PTR [bp-22],690
; Line 14
	mov	WORD PTR [bp-32],2344	;L
	mov	WORD PTR [bp-30],0
; Line 16
	mov	ax,OFFSET DGROUP:$S19_A+4
	mov	[bp-12],ax	;P
	mov	[bp-10],ds
; Line 18
	mov	cl,7
	mov	al,[bp-2]	;c
	sub	ah,ah
	div	cl
	mov	[bp-2],ah	;c
; Line 19
	mov	al,ah
	sub	ah,ah
	mov	cl,8
	div	cl
	mov	cl,ah
	mov	al,[bp-2]	;c
	sub	ah,ah
	div	cl
	mov	[bp-2],ah	;c
; Line 20
	mov	cx,15535
	mov	ax,[bp-14]	;s
	sub	dx,dx
	div	cx
	mov	[bp-14],dx	;s
; Line 21
	mov	ax,dx
	sub	dx,dx
	mov	cx,24
	div	cx
	mov	cx,dx
	mov	ax,[bp-14]	;s
	sub	dx,dx
	div	cx
	mov	[bp-14],dx	;s
; Line 22
	push	WORD PTR 0
	push	WORD PTR 468
	lea	ax,[bp-20]	;i
	push	ss
	push	ax
	call	FAR PTR __aulrem
; Line 23
	push	WORD PTR 0
	push	WORD PTR 245
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;i
	call	FAR PTR __ulrem
	push	dx
	push	ax
	lea	ax,[bp-20]	;i
	push	ss
	push	ax
	call	FAR PTR __aulrem
; Line 24
	push	WORD PTR 0
	push	WORD PTR 83
	lea	ax,[bp-28]	;l
	push	ss
	push	ax
	call	FAR PTR __aulrem
; Line 25
	push	WORD PTR 0
	push	WORD PTR 246
	push	WORD PTR [bp-26]
	push	WORD PTR [bp-28]	;l
	call	FAR PTR __ulrem
	push	dx
	push	ax
	lea	ax,[bp-28]	;l
	push	ss
	push	ax
	call	FAR PTR __aulrem
; Line 26
	mov	al,BYTE PTR $S13_a+2
	cbw	
	idiv	BYTE PTR $S13_a+4
	mov	BYTE PTR $S13_a+2,ah
; Line 27
	les	bx,[bp-8]	;p
	mov	al,es:[bx-1]
	cbw	
	mov	cl,3
	idiv	cl
	mov	cl,ah
	mov	al,es:[bx+1]
	cbw	
	idiv	cl
	mov	es:[bx+1],ah
; Line 28
	mov	cl,18
	mov	al,[bp-4]	;C
	cbw	
	idiv	cl
	mov	[bp-4],ah	;C
; Line 29
	mov	al,ah
	cbw	
	mov	cl,2
	idiv	cl
	mov	cl,ah
	mov	al,[bp-4]	;C
	cbw	
	idiv	cl
	mov	[bp-4],ah	;C
; Line 30
	mov	cx,7
	mov	ax,[bp-16]	;S
	cwd	
	idiv	cx
	mov	[bp-16],dx	;S
; Line 31
	mov	ax,dx
	cwd	
	mov	cx,4
	idiv	cx
	mov	cx,dx
	mov	ax,[bp-16]	;S
	cwd	
	idiv	cx
	mov	[bp-16],dx	;S
; Line 32
	push	WORD PTR 0
	push	WORD PTR 932
	lea	ax,[bp-24]	;I
	push	ss
	push	ax
	call	FAR PTR __alrem
; Line 33
	push	WORD PTR 0
	push	WORD PTR 63
	push	WORD PTR [bp-22]
	push	WORD PTR [bp-24]	;I
	call	FAR PTR __lrem
	push	dx
	push	ax
	lea	ax,[bp-24]	;I
	push	ss
	push	ax
	call	FAR PTR __alrem
; Line 34
	push	WORD PTR 0
	push	WORD PTR 44
	lea	ax,[bp-32]	;L
	push	ss
	push	ax
	call	FAR PTR __alrem
; Line 35
	push	WORD PTR 0
	push	WORD PTR 23
	push	WORD PTR [bp-30]
	push	WORD PTR [bp-32]	;L
	call	FAR PTR __lrem
	push	dx
	push	ax
	lea	ax,[bp-32]	;L
	push	ss
	push	ax
	call	FAR PTR __alrem
; Line 36
	push	WORD PTR $S19_A+2
	push	WORD PTR $S19_A
	push	OFFSET DGROUP:WORD PTR $S19_A+4
	call	FAR PTR __blrem
; Line 37
	les	bx,[bp-12]	;P
	push	WORD PTR es:[bx+14]
	push	WORD PTR es:[bx+12]
	mov	ax,bx
	mov	dx,es
	sub	ax,4
	push	dx
	push	ax
	call	FAR PTR __alrem
; Line 39
	les	bx,[bp-12]	;P
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	push	WORD PTR $S19_A+6
	push	WORD PTR $S19_A+4
	push	WORD PTR $S19_A+2
	push	WORD PTR $S19_A
	push	WORD PTR [bp-30]
	push	WORD PTR [bp-32]	;L
	push	WORD PTR [bp-22]
	push	WORD PTR [bp-24]	;I
	push	WORD PTR [bp-16]	;S
	mov	al,[bp-4]	;C
	cbw	
	push	ax
	les	bx,[bp-8]	;p
	mov	al,es:[bx]
	cbw	
	push	ax
	mov	al,BYTE PTR $S13_a+3
	cbw	
	push	ax
	push	WORD PTR [bp-26]
	push	WORD PTR [bp-28]	;l
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;i
	push	WORD PTR [bp-14]	;s
	mov	al,[bp-2]	;c
	sub	ah,ah
	push	ax
	mov	ax,OFFSET DGROUP:$SG22
	push	ds
	push	ax
	call	FAR PTR _printf
; Line 40
	leave	
	ret	

_main	ENDP
MODULO_TEXT	ENDS
END
