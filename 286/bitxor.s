;	Static Name Aliases
;
;	$S13_a	EQU	a
;	$S19_A	EQU	A
	TITLE   bitxor

	.286p
	.287
BITXOR_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
BITXOR_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: BITXOR_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
_DATA      SEGMENT
$SG22	DB	'%d %d %d %d %d %d',  0aH, '%d %d %d %d %d %d',  0aH,  00H
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
_DATA      ENDS
BITXOR_TEXT      SEGMENT
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
	mov	WORD PTR [bp-28],2823	;l
	mov	WORD PTR [bp-26],0
; Line 10
	mov	ax,OFFSET DGROUP:$S13_a+5
	mov	[bp-8],ax	;p
	mov	[bp-6],ds
; Line 11
	mov	BYTE PTR [bp-4],128	;C
; Line 12
	mov	WORD PTR [bp-16],117	;S
; Line 13
	mov	WORD PTR [bp-24],232	;I
	mov	WORD PTR [bp-22],0
; Line 14
	mov	WORD PTR [bp-32],2344	;L
	mov	WORD PTR [bp-30],0
; Line 16
	mov	ax,OFFSET DGROUP:$S19_A+12
	mov	[bp-12],ax	;P
	mov	[bp-10],ds
; Line 18
	xor	BYTE PTR [bp-2],5	;c
; Line 19
	mov	al,[bp-2]	;c
	xor	al,98
	xor	[bp-2],al	;c
; Line 20
	xor	WORD PTR [bp-14],15535	;s
; Line 21
	mov	ax,[bp-14]	;s
	xor	ax,2346
	xor	[bp-14],ax	;s
; Line 22
	xor	WORD PTR [bp-20],-22858	;i
; Line 23
	mov	ax,[bp-20]	;i
	mov	dx,[bp-18]
	xor	ax,2345
	xor	[bp-20],ax	;i
	xor	[bp-18],dx
; Line 24
	xor	WORD PTR [bp-28],893	;l
; Line 25
	mov	ax,[bp-28]	;l
	mov	dx,[bp-26]
	xor	ax,-1234
	xor	dx,-1
	xor	[bp-28],ax	;l
	xor	[bp-26],dx
; Line 26
	mov	al,BYTE PTR $S13_a+4
	xor	al,138
	xor	BYTE PTR $S13_a+2,al
; Line 27
	les	bx,[bp-8]	;p
	mov	al,es:[bx-1]
	xor	al,6
	xor	es:[bx+2],al
; Line 28
	xor	BYTE PTR [bp-4],99	;C
; Line 29
	mov	al,[bp-4]	;C
	xor	al,169
	xor	[bp-4],al	;C
; Line 30
	xor	BYTE PTR [bp-16],67	;S
; Line 31
	mov	ax,[bp-16]	;S
	xor	ax,4234
	xor	[bp-16],ax	;S
; Line 32
	xor	WORD PTR [bp-24],-9342	;I
	xor	WORD PTR [bp-22],-1
; Line 33
	mov	ax,[bp-24]	;I
	mov	dx,[bp-22]
	xor	ax,8907
	xor	dl,1
	xor	[bp-24],ax	;I
	xor	[bp-22],dx
; Line 34
	xor	WORD PTR [bp-32],-454	;L
	xor	WORD PTR [bp-30],-1
; Line 35
	mov	ax,[bp-32]	;L
	mov	dx,[bp-30]
	xor	ax,12356
	xor	[bp-32],ax	;L
	xor	[bp-30],dx
; Line 36
	mov	ax,WORD PTR $S19_A
	mov	dx,WORD PTR $S19_A+2
	xor	ax,2839
	xor	WORD PTR $S19_A+4,ax
	xor	WORD PTR $S19_A+6,dx
; Line 37
	les	bx,[bp-12]	;P
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	xor	ax,346
	xor	es:[bx-4],ax
	xor	es:[bx-2],dx
; Line 39
	les	bx,[bp-12]	;P
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	push	WORD PTR $S19_A+10
	push	WORD PTR $S19_A+8
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
BITXOR_TEXT	ENDS
END
