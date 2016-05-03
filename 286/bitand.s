;	Static Name Aliases
;
;	$S13_a	EQU	a
;	$S19_A	EQU	A
	TITLE   bitand

	.286p
	.287
BITAND_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
BITAND_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: BITAND_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
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
BITAND_TEXT      SEGMENT
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
	and	BYTE PTR [bp-2],5	;c
; Line 19
	mov	al,[bp-2]	;c
	and	al,4
	and	[bp-2],al	;c
; Line 20
	and	WORD PTR [bp-14],15535	;s
; Line 21
	mov	ax,[bp-14]	;s
	and	ax,772
	and	[bp-14],ax	;s
; Line 22
	and	WORD PTR [bp-20],-22858	;i
	mov	WORD PTR [bp-18],0
; Line 23
	mov	ax,[bp-20]	;i
	mov	dx,[bp-18]
	and	ax,493
	sub	dx,dx
	and	[bp-20],ax	;i
	and	[bp-18],dx
; Line 24
	and	WORD PTR [bp-28],893	;l
	mov	[bp-26],dx
; Line 25
	mov	ax,[bp-28]	;l
	and	ax,342
	and	[bp-28],ax	;l
	and	[bp-26],dx
; Line 26
	mov	al,BYTE PTR $S13_a+4
	and	al,42
	and	BYTE PTR $S13_a+2,al
; Line 27
	les	bx,[bp-8]	;p
	mov	al,es:[bx-1]
	and	al,93
	and	es:[bx+2],al
; Line 28
	and	BYTE PTR [bp-4],99	;C
; Line 29
	mov	al,[bp-4]	;C
	and	al,93
	and	[bp-4],al	;C
; Line 30
	and	WORD PTR [bp-16],67	;S
; Line 31
	mov	ax,[bp-16]	;S
	and	ax,932
	and	[bp-16],ax	;S
; Line 32
	and	WORD PTR [bp-24],-9342	;I
; Line 33
	mov	ax,[bp-24]	;I
	mov	dx,[bp-22]
	and	ax,323
	sub	dx,dx
	and	[bp-24],ax	;I
	and	[bp-22],dx
; Line 34
	and	WORD PTR [bp-32],-454	;L
; Line 35
	mov	ax,[bp-32]	;L
	mov	dx,[bp-30]
	and	ax,832
	sub	dx,dx
	and	[bp-32],ax	;L
	and	[bp-30],dx
; Line 36
	mov	ax,WORD PTR $S19_A
	mov	dx,WORD PTR $S19_A+2
	and	ax,23
	sub	dx,dx
	and	WORD PTR $S19_A+4,ax
	and	WORD PTR $S19_A+6,dx
; Line 37
	les	bx,[bp-12]	;P
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	and	ax,43
	sub	dx,dx
	and	es:[bx-4],ax
	and	es:[bx-2],dx
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
BITAND_TEXT	ENDS
END
