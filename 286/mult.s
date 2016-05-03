;	Static Name Aliases
;
;	$S13_a	EQU	a
;	$S21_A	EQU	A
	TITLE   mult

	.286p
	.287
MULT_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
MULT_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: MULT_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__aulmul:FAR
EXTRN	__ulmul:FAR
EXTRN	__almul:FAR
EXTRN	__lmul:FAR
EXTRN	__fltused:NEAR
_DATA      SEGMENT
$SG24	DB	'%d %d %d %d %d %d',  0aH, '%d %d %d %d %f %f %d %d',  0aH,  00H
	EVEN
$S13_a	DB	01H
	DB	02H
	DB	03H
	DB	04H
	DB	05H
	DB	06H
	DB	07H
	EVEN
$S21_A	DW	08H
	DW	09H
	DW	0aH
	DW	0bH
	DW	0cH
_DATA      ENDS
MULT_TEXT      SEGMENT
MULT_TEXT      ENDS
CONST      SEGMENT
$T20001		DD	03eaf1aa0H   ;	.34200001
CONST      ENDS
MULT_TEXT      SEGMENT
MULT_TEXT      ENDS
CONST      SEGMENT
$T20002		DQ	040a9440000000000H    ;	3234.000000000000
CONST      ENDS
MULT_TEXT      SEGMENT
MULT_TEXT      ENDS
CONST      SEGMENT
$T20007		DD	04290af1bH   ;	72.342003
CONST      ENDS
MULT_TEXT      SEGMENT
MULT_TEXT      ENDS
CONST      SEGMENT
$T20008		DQ	04037333333333333H    ;	23.20000000000000
CONST      ENDS
MULT_TEXT      SEGMENT
MULT_TEXT      ENDS
CONST      SEGMENT
$T20009		DQ	040aebda8f5c28f5cH    ;	3934.830000000000
CONST      ENDS
MULT_TEXT      SEGMENT
MULT_TEXT      ENDS
CONST      SEGMENT
$T20010		DQ	03fcdf3b645a1cac1H    ;	.2340000000000000
CONST      ENDS
MULT_TEXT      SEGMENT
; Line 4
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,40
	call	FAR PTR __chkstk
	push	di
	push	si
;	c = -2
;	C = -4
;	D = -12
;	p = -16
;	P = -20
;	F = -24
;	s = -26
;	S = -28
;	i = -30
;	I = -32
;	l = -36
;	L = -40
; Line 5
	mov	BYTE PTR [bp-2],3	;c
; Line 6
	mov	WORD PTR [bp-26],932	;s
; Line 7
	mov	WORD PTR [bp-30],-22062	;i
; Line 8
	mov	WORD PTR [bp-36],2823	;l
	mov	WORD PTR [bp-34],0
; Line 10
	mov	ax,OFFSET DGROUP:$S13_a+5
	mov	[bp-16],ax	;p
	mov	[bp-14],ds
; Line 11
	mov	BYTE PTR [bp-4],128	;C
; Line 12
	mov	WORD PTR [bp-28],117	;S
; Line 13
	mov	WORD PTR [bp-32],232	;I
; Line 14
	mov	WORD PTR [bp-40],2344	;L
	mov	WORD PTR [bp-38],0
; Line 15
	fld	$T20001
	fstp	DWORD PTR [bp-24]	;F
; Line 16
	fld	$T20002
	fstp	QWORD PTR [bp-12]	;D
	fwait	
; Line 18
	mov	ax,OFFSET DGROUP:$S21_A+6
	mov	[bp-20],ax	;P
	mov	[bp-18],ds
; Line 20
	shl	BYTE PTR [bp-2],1	;c
; Line 21
	mov	al,[bp-2]	;c
	shl	al,1
	mul	BYTE PTR [bp-2]	;c
	mov	[bp-2],al	;c
; Line 22
	mov	ax,15535
	mul	WORD PTR [bp-26]	;s
	mov	[bp-26],ax	;s
; Line 23
	imul	ax,ax,23
	mul	WORD PTR [bp-26]	;s
	mov	[bp-26],ax	;s
; Line 24
	mov	ax,-22858
	mul	WORD PTR [bp-30]	;i
	mov	[bp-30],ax	;i
; Line 25
	imul	ax,ax,23
	mul	WORD PTR [bp-30]	;i
	mov	[bp-30],ax	;i
; Line 26
	push	WORD PTR 0
	push	WORD PTR 893
	lea	ax,[bp-36]	;l
	push	ss
	push	ax
	call	FAR PTR __aulmul
; Line 27
	push	WORD PTR 0
	push	WORD PTR 3234
	push	WORD PTR [bp-34]
	push	WORD PTR [bp-36]	;l
	call	FAR PTR __ulmul
	push	dx
	push	ax
	lea	ax,[bp-36]	;l
	push	ss
	push	ax
	call	FAR PTR __aulmul
; Line 28
	mov	al,BYTE PTR $S13_a+4
	cbw	
	imul	WORD PTR 234
	imul	BYTE PTR $S13_a+2
	mov	BYTE PTR $S13_a+2,al
; Line 29
	les	bx,[bp-16]	;p
	mov	al,es:[bx-1]
	cbw	
	imul	WORD PTR 452
	imul	BYTE PTR es:[bx+2]
	mov	es:[bx+2],al
; Line 30
	mov	al,99
	imul	BYTE PTR [bp-4]	;C
	mov	[bp-4],al	;C
; Line 31
	mov	al,22
	imul	BYTE PTR [bp-4]	;C
	imul	BYTE PTR [bp-4]	;C
	mov	[bp-4],al	;C
; Line 32
	mov	ax,67
	imul	WORD PTR [bp-28]	;S
	mov	[bp-28],ax	;S
; Line 33
	shl	ax,5
	neg	ax
	imul	WORD PTR [bp-28]	;S
	mov	[bp-28],ax	;S
; Line 34
	mov	ax,-9342
	imul	WORD PTR [bp-32]	;I
	mov	[bp-32],ax	;I
; Line 35
	imul	ax,ax,234
	imul	WORD PTR [bp-32]	;I
	mov	[bp-32],ax	;I
; Line 36
	push	WORD PTR -1
	push	WORD PTR -454
	lea	ax,[bp-40]	;L
	push	ss
	push	ax
	call	FAR PTR __almul
; Line 37
	push	WORD PTR 0
	push	WORD PTR 2345
	push	WORD PTR [bp-38]
	push	WORD PTR [bp-40]	;L
	call	FAR PTR __lmul
	push	dx
	push	ax
	lea	ax,[bp-40]	;L
	push	ss
	push	ax
	call	FAR PTR __almul
; Line 38
	fld	$T20007
	fmul	DWORD PTR [bp-24]	;F
	fst	DWORD PTR [bp-24]	;F
; Line 39
	fmul	$T20008
	fmul	DWORD PTR [bp-24]	;F
	fstp	DWORD PTR [bp-24]	;F
; Line 40
	fld	$T20009
	fmul	QWORD PTR [bp-12]	;D
	fst	QWORD PTR [bp-12]	;D
; Line 41
	fmul	$T20010
	fmul	QWORD PTR [bp-12]	;D
	fstp	QWORD PTR [bp-12]	;D
	fwait	
; Line 42
	mov	ax,WORD PTR $S21_A
	shl	ax,1
	imul	WORD PTR $S21_A+2
	mov	WORD PTR $S21_A+2,ax
; Line 43
	les	bx,[bp-20]	;P
	imul	ax,WORD PTR es:[bx],5
	imul	WORD PTR es:[bx-2]
	mov	es:[bx-2],ax
; Line 45
	les	bx,[bp-20]	;P
	push	WORD PTR es:[bx]
	push	WORD PTR $S21_A+4
	sub	sp,8
	lea	si,[bp-12]	;D
	mov	di,sp
	push	ss
	pop	es
	movsw
	movsw
	movsw
	movsw
	fld	DWORD PTR [bp-24]	;F
	sub	sp,8
	mov	bx,sp
	fstp	QWORD PTR [bx]
	fwait	
	push	WORD PTR [bp-38]
	push	WORD PTR [bp-40]	;L
	push	WORD PTR [bp-32]	;I
	push	WORD PTR [bp-28]	;S
	mov	al,[bp-4]	;C
	cbw	
	push	ax
	les	bx,[bp-16]	;p
	mov	al,es:[bx]
	cbw	
	push	ax
	mov	al,BYTE PTR $S13_a+3
	cbw	
	push	ax
	push	WORD PTR [bp-34]
	push	WORD PTR [bp-36]	;l
	push	WORD PTR [bp-30]	;i
	push	WORD PTR [bp-26]	;s
	mov	al,[bp-2]	;c
	sub	ah,ah
	push	ax
	mov	ax,OFFSET DGROUP:$SG24
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,48
; Line 46
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
MULT_TEXT	ENDS
END
