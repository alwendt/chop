;	Static Name Aliases
;
;	$S13_a	EQU	a
;	$S21_A	EQU	A
	TITLE   addition

	.286p
	.287
ADDITION_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
ADDITION_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: ADDITION_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
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
$S21_A	DD	08H
	DD	09H
	DD	0aH
	DD	0bH
	DD	0cH
_DATA      ENDS
ADDITION_TEXT      SEGMENT
ADDITION_TEXT      ENDS
CONST      SEGMENT
$T20001		DD	03eaf1aa0H   ;	.34200001
CONST      ENDS
ADDITION_TEXT      SEGMENT
ADDITION_TEXT      ENDS
CONST      SEGMENT
$T20002		DQ	040a9440000000000H    ;	3234.000000000000
CONST      ENDS
ADDITION_TEXT      SEGMENT
ADDITION_TEXT      ENDS
CONST      SEGMENT
$T20003		DD	04290af1bH   ;	72.342003
CONST      ENDS
ADDITION_TEXT      SEGMENT
ADDITION_TEXT      ENDS
CONST      SEGMENT
$T20004		DQ	040a24c999999999aH    ;	2342.300000000000
CONST      ENDS
ADDITION_TEXT      SEGMENT
ADDITION_TEXT      ENDS
CONST      SEGMENT
$T20005		DQ	040aebda8f5c28f5cH    ;	3934.830000000000
CONST      ENDS
ADDITION_TEXT      SEGMENT
ADDITION_TEXT      ENDS
CONST      SEGMENT
$T20006		DQ	03ee4f8b588e368f1H    ;	1.000000000000000E-05
CONST      ENDS
ADDITION_TEXT      SEGMENT
; Line 4
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,44
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
;	i = -32
;	I = -36
;	l = -40
;	L = -44
; Line 5
	mov	BYTE PTR [bp-2],25	;c
; Line 6
	mov	WORD PTR [bp-26],932	;s
; Line 7
	mov	WORD PTR [bp-32],-22062	;i
	mov	WORD PTR [bp-30],-157
; Line 8
	mov	WORD PTR [bp-40],2823	;l
	mov	WORD PTR [bp-38],0
; Line 10
	mov	ax,OFFSET DGROUP:$S13_a+5
	mov	[bp-16],ax	;p
	mov	[bp-14],ds
; Line 11
	mov	BYTE PTR [bp-4],127	;C
; Line 12
	mov	WORD PTR [bp-28],117	;S
; Line 13
	mov	WORD PTR [bp-36],232	;I
	mov	WORD PTR [bp-34],0
; Line 14
	mov	WORD PTR [bp-44],2344	;L
	mov	WORD PTR [bp-42],0
; Line 15
	fld	$T20001
	fstp	DWORD PTR [bp-24]	;F
; Line 16
	fld	$T20002
	fstp	QWORD PTR [bp-12]	;D
	fwait	
; Line 18
	mov	ax,OFFSET DGROUP:$S21_A+12
	mov	[bp-20],ax	;P
	mov	[bp-18],ds
; Line 20
	add	BYTE PTR [bp-2],5	;c
; Line 21
	mov	al,[bp-2]	;c
	add	al,72
	add	[bp-2],al	;c
; Line 22
	add	WORD PTR [bp-26],15535	;s
; Line 23
	mov	ax,[bp-26]	;s
	add	ax,532
	add	[bp-26],ax	;s
; Line 24
	add	WORD PTR [bp-32],-22858	;i
	adc	WORD PTR [bp-30],0
; Line 25
	mov	ax,[bp-32]	;i
	mov	dx,[bp-30]
	add	ax,23466
	adc	dx,0
	add	[bp-32],ax	;i
	adc	[bp-30],dx
; Line 26
	add	WORD PTR [bp-40],893	;l
	adc	WORD PTR [bp-38],0
; Line 27
	mov	ax,[bp-40]	;l
	mov	dx,[bp-38]
	add	ax,12354
	adc	dx,0
	add	[bp-40],ax	;l
	adc	[bp-38],dx
; Line 28
	mov	al,BYTE PTR $S13_a+4
	add	al,23
	add	BYTE PTR $S13_a+2,al
; Line 29
	add	WORD PTR [bp-16],-3	;p
; Line 30
	les	bx,[bp-16]	;p
	mov	al,es:[bx-1]
	add	al,32
	add	es:[bx+2],al
; Line 31
	add	BYTE PTR [bp-4],99	;C
; Line 32
	mov	al,[bp-4]	;C
	add	al,36
	add	[bp-4],al	;C
; Line 33
	add	WORD PTR [bp-28],67	;S
; Line 34
	mov	ax,[bp-28]	;S
	add	ax,32342
	add	[bp-28],ax	;S
; Line 35
	add	WORD PTR [bp-36],-9342	;I
	adc	WORD PTR [bp-34],-1
; Line 36
	mov	ax,[bp-36]	;I
	mov	dx,[bp-34]
	add	ax,23432
	adc	dx,0
	add	[bp-36],ax	;I
	adc	[bp-34],dx
; Line 37
	add	WORD PTR [bp-44],-454	;L
	adc	WORD PTR [bp-42],-1
; Line 38
	mov	ax,[bp-44]	;L
	mov	dx,[bp-42]
	sub	ax,3243
	sbb	dx,0
	add	[bp-44],ax	;L
	adc	[bp-42],dx
; Line 39
	fld	$T20003
	fadd	DWORD PTR [bp-24]	;F
	fst	DWORD PTR [bp-24]	;F
; Line 40
	fadd	$T20004
	fadd	DWORD PTR [bp-24]	;F
	fstp	DWORD PTR [bp-24]	;F
; Line 41
	fld	$T20005
	fadd	QWORD PTR [bp-12]	;D
	fst	QWORD PTR [bp-12]	;D
; Line 42
	fadd	$T20006
	fadd	QWORD PTR [bp-12]	;D
	fstp	QWORD PTR [bp-12]	;D
	fwait	
; Line 43
	mov	ax,WORD PTR $S21_A
	mov	dx,WORD PTR $S21_A+2
	add	ax,32
	adc	dx,0
	add	WORD PTR $S21_A+4,ax
	adc	WORD PTR $S21_A+6,dx
; Line 44
	add	WORD PTR [bp-20],4	;P
; Line 45
	les	bx,[bp-20]	;P
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	sub	ax,54
	sbb	dx,0
	add	es:[bx-4],ax
	adc	es:[bx-2],dx
; Line 47
	les	bx,[bp-20]	;P
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	push	WORD PTR $S21_A+10
	push	WORD PTR $S21_A+8
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
	push	WORD PTR [bp-42]
	push	WORD PTR [bp-44]	;L
	push	WORD PTR [bp-34]
	push	WORD PTR [bp-36]	;I
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
	push	WORD PTR [bp-38]
	push	WORD PTR [bp-40]	;l
	push	WORD PTR [bp-30]
	push	WORD PTR [bp-32]	;i
	push	WORD PTR [bp-26]	;s
	mov	al,[bp-2]	;c
	sub	ah,ah
	push	ax
	mov	ax,OFFSET DGROUP:$SG24
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,56
; Line 48
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
ADDITION_TEXT	ENDS
END
