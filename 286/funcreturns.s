;	Static Name Aliases
;
;	$S40_array	EQU	array
;	$S75_array	EQU	array
	TITLE   funcreturns

	.286p
	.287
FUNCRETURNS_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
FUNCRETURNS_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: FUNCRETURNS_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__fac:FAR
EXTRN	__blmul:FAR
EXTRN	__fltused:NEAR
_DATA      SEGMENT
$SG25	DB	'%d %d %d %d %d %d %d',  0aH, '%d %d %f %f %d %d',  0aH,  00H
_DATA      ENDS
_BSS      SEGMENT
$S75_array	DW 0aH DUP (?)
$S40_array	DB 05H DUP (?)
	EVEN
_BSS      ENDS
FUNCRETURNS_TEXT      SEGMENT
; Line 15
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
	push	di
	push	si
;	z = -4
;	i = -8
; Line 16
	mov	WORD PTR [bp-8],13697	;i
	mov	WORD PTR [bp-6],11
; Line 18
	lea	ax,[bp-8]	;i
	push	ss
	push	ax
	call	FAR PTR _dotfunc
	add	sp,4
; Line 21
	lea	ax,[bp-4]	;z
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _Pfunc
	add	sp,4
	mov	bx,ax
	mov	es,dx
	push	WORD PTR es:[bx+18]
	push	WORD PTR es:[bx+16]
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _Dfunc
	add	sp,4
	sub	sp,8
	mov	si,ax
	mov	di,sp
	push	ss
	pop	es
	push	ds
	mov	ds,dx
	movsw
	movsw
	movsw
	movsw
	pop	ds
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _Ffunc
	add	sp,4
	mov	bx,ax
	mov	es,dx
	fld	QWORD PTR es:[bx]
	sub	sp,8
	mov	bx,sp
	fstp	QWORD PTR [bx]
	fwait	
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _Lfunc
	add	sp,4
	push	dx
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _Ifunc
	add	sp,4
	push	dx
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _Sfunc
	add	sp,4
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _Cfunc
	add	sp,4
	cbw	
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _pfunc
	add	sp,4
	mov	bx,ax
	mov	es,dx
	mov	al,es:[bx+2]
	cbw	
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _lfunc
	add	sp,4
	push	dx
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _ifunc
	add	sp,4
	push	dx
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _sfunc
	add	sp,4
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;i
	call	FAR PTR _cfunc
	add	sp,4
	sub	ah,ah
	push	ax
	mov	ax,OFFSET DGROUP:$SG25
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,54
; Line 22
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
;	i = 6
; Line 25
	PUBLIC	_cfunc
_cfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2
	call	FAR PTR __chkstk
;	c = -2
; Line 27
	mov	al,[bp+6]	;i
	mov	[bp-2],al	;c
; Line 28
	sub	ah,ah
	leave	
	ret	

_cfunc	ENDP
;	i = 6
; Line 32
	PUBLIC	_sfunc
_sfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2
	call	FAR PTR __chkstk
;	s = -2
; Line 34
	mov	ax,[bp+6]	;i
	mov	[bp-2],ax	;s
; Line 35
	leave	
	ret	

_sfunc	ENDP
;	i = 6
; Line 39
	PUBLIC	_ifunc
_ifunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	ei = -4
; Line 41
	mov	ax,[bp+6]	;i
	mov	dx,[bp+8]
	mov	[bp-4],ax	;ei
	mov	[bp-2],dx
; Line 42
	leave	
	ret	

_ifunc	ENDP
;	i = 6
; Line 46
	PUBLIC	_lfunc
_lfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	l = -4
; Line 48
	mov	ax,[bp+6]	;i
	mov	dx,[bp+8]
	mov	[bp-4],ax	;l
	mov	[bp-2],dx
; Line 49
	leave	
	ret	

_lfunc	ENDP
;	i = 6
; Line 53
	PUBLIC	_pfunc
_pfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
	push	si
;	p = -4
;	j = -8
; Line 56
	mov	ax,OFFSET DGROUP:$S40_array+4
	mov	[bp-4],ax	;p
	mov	[bp-2],ds
; Line 58
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
$F43:
	cmp	WORD PTR [bp-6],0
	jg	$FB45
	jl	$F46
	cmp	WORD PTR [bp-8],5	;j
	jae	$FB45
$F46:
; Line 59
	mov	bx,[bp-8]	;j
	mov	ax,[bp-6]
	neg	bx
	adc	ax,0
	neg	ax
	les	si,[bp-4]	;p
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	neg	ax
	adc	dx,0
	neg	dx
	mov	es:[bx][si],al
	add	WORD PTR [bp-8],1	;j
	adc	WORD PTR [bp-6],0
	jmp	SHORT $F43
$FB45:
; Line 60
	mov	ax,OFFSET DGROUP:$S40_array
	mov	[bp-4],ax	;p
	mov	[bp-2],ds
; Line 61
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
$F47:
	cmp	WORD PTR [bp-6],0
	jg	$FB49
	jl	$F50
	cmp	WORD PTR [bp-8],5	;j
	jae	$FB49
$F50:
; Line 62
	mov	bx,[bp-8]	;j
	les	si,[bp-4]	;p
	mov	al,[bp-8]	;j
	mov	es:[bx][si],al
	add	WORD PTR [bp-8],1	;j
	adc	WORD PTR [bp-6],0
	jmp	SHORT $F47
$FB49:
; Line 63
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
$F51:
	cmp	WORD PTR [bp-6],0
	jg	$FB53
	jl	$F54
	cmp	WORD PTR [bp-8],5	;j
	jae	$FB53
$F54:
; Line 64
	mov	al,[bp+6]	;i
	mov	bx,[bp-8]	;j
	imul	BYTE PTR $S40_array[bx]
	mov	BYTE PTR $S40_array[bx],al
	add	WORD PTR [bp-8],1	;j
	adc	WORD PTR [bp-6],0
	jmp	SHORT $F51
$FB53:
; Line 65
	mov	ax,[bp-4]	;p
	mov	dx,[bp-2]
	pop	si
	leave	
	ret	

_pfunc	ENDP
;	i = 6
; Line 69
	PUBLIC	_Cfunc
_Cfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2
	call	FAR PTR __chkstk
;	C = -2
; Line 71
	mov	al,[bp+6]	;i
	mov	[bp-2],al	;C
; Line 72
	cbw	
	leave	
	ret	

_Cfunc	ENDP
;	i = 6
; Line 76
	PUBLIC	_Sfunc
_Sfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2
	call	FAR PTR __chkstk
;	S = -2
; Line 78
	mov	ax,[bp+6]	;i
	mov	[bp-2],ax	;S
; Line 79
	leave	
	ret	

_Sfunc	ENDP
;	i = 6
; Line 83
	PUBLIC	_Ifunc
_Ifunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	I = -4
; Line 85
	mov	ax,[bp+6]	;i
	mov	dx,[bp+8]
	mov	[bp-4],ax	;I
	mov	[bp-2],dx
; Line 86
	leave	
	ret	

_Ifunc	ENDP
;	i = 6
; Line 90
	PUBLIC	_Lfunc
_Lfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	L = -4
; Line 92
	mov	ax,[bp+6]	;i
	mov	dx,[bp+8]
	mov	[bp-4],ax	;L
	mov	[bp-2],dx
; Line 93
	leave	
	ret	

_Lfunc	ENDP
;	i = 6
; Line 97
	PUBLIC	_Ffunc
_Ffunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	F = -4
; Line 99
	fild	DWORD PTR [bp+6]	;i
	fst	DWORD PTR [bp-4]	;F
; Line 100
	mov	dx,SEG __fac
	mov	es,dx
	fstp	QWORD PTR es:__fac
	mov	ax,OFFSET __fac
	fwait	
	leave	
	ret	

_Ffunc	ENDP
;	i = 6
; Line 104
	PUBLIC	_Dfunc
_Dfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
;	D = -8
; Line 106
	fild	DWORD PTR [bp+6]	;i
	fst	QWORD PTR [bp-8]	;D
; Line 107
	mov	dx,SEG __fac
	mov	es,dx
	fstp	QWORD PTR es:__fac
	mov	ax,OFFSET __fac
	fwait	
	leave	
	ret	

_Dfunc	ENDP
;	i = 6
; Line 111
	PUBLIC	_Pfunc
_Pfunc	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
	push	si
;	P = -4
;	j = -8
; Line 114
	mov	ax,OFFSET DGROUP:$S75_array+16
	mov	[bp-4],ax	;P
	mov	[bp-2],ds
; Line 116
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
$F78:
	cmp	WORD PTR [bp-6],0
	jg	$FB80
	jl	$F81
	cmp	WORD PTR [bp-8],5	;j
	jae	$FB80
$F81:
; Line 117
	mov	bx,[bp-8]	;j
	mov	ax,[bp-6]
	neg	bx
	adc	ax,0
	neg	ax
	shl	bx,2
	les	si,[bp-4]	;P
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	neg	ax
	adc	dx,0
	neg	dx
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],dx
	add	WORD PTR [bp-8],1	;j
	adc	WORD PTR [bp-6],0
	jmp	SHORT $F78
$FB80:
; Line 118
	mov	ax,OFFSET DGROUP:$S75_array
	mov	[bp-4],ax	;P
	mov	[bp-2],ds
; Line 119
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
$F82:
	cmp	WORD PTR [bp-6],0
	jg	$FB84
	jl	$F85
	cmp	WORD PTR [bp-8],5	;j
	jae	$FB84
$F85:
; Line 120
	mov	bx,[bp-8]	;j
	shl	bx,2
	les	si,[bp-4]	;P
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],dx
	add	WORD PTR [bp-8],1	;j
	adc	WORD PTR [bp-6],0
	jmp	SHORT $F82
$FB84:
; Line 121
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
$F86:
	cmp	WORD PTR [bp-6],0
	jg	$FB88
	jl	$F89
	cmp	WORD PTR [bp-8],5	;j
	jae	$FB88
$F89:
; Line 122
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;i
	mov	ax,[bp-8]	;j
	shl	ax,2
	add	ax,OFFSET DGROUP:$S75_array
	push	ax
	call	FAR PTR __blmul
	add	WORD PTR [bp-8],1	;j
	adc	WORD PTR [bp-6],0
	jmp	SHORT $F86
$FB88:
; Line 123
	mov	ax,[bp-4]	;P
	mov	dx,[bp-2]
	pop	si
	leave	
	ret	

_Pfunc	ENDP
;	pi = 6
; Line 127
	PUBLIC	_dotfunc
_dotfunc	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 129
	les	bx,[bp+6]	;pi
	add	WORD PTR es:[bx],1
	adc	WORD PTR es:[bx+2],0
; Line 130
	leave	
	ret	

_dotfunc	ENDP
FUNCRETURNS_TEXT	ENDS
END
