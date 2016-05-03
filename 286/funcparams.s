;	Static Name Aliases
;
;	$S67_A	EQU	A
;	$S59_a	EQU	a
;	$S39_Sc	EQU	Sc
;	$S40_Ss	EQU	Ss
;	$S41_Si	EQU	Si
;	$S42_Sl	EQU	Sl
;	$S43_Sa	EQU	Sa
;	$S44_Sp	EQU	Sp
;	$S45_SC	EQU	SC
;	$S46_SS	EQU	SS
;	$S47_SI	EQU	SI
;	$S48_SL	EQU	SL
;	$S49_SF	EQU	SF
;	$S50_SD	EQU	SD
;	$S51_SA	EQU	SA
;	$S52_SP	EQU	SP
	TITLE   funcparams

	.286p
	.287
FUNCPARAMS_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
FUNCPARAMS_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: FUNCPARAMS_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _Gc
PUBLIC  _Gs
PUBLIC  _Gi
PUBLIC  _Gl
PUBLIC  _Ga
PUBLIC  _Gp
PUBLIC  _GC
PUBLIC  _GS
PUBLIC  _GI
PUBLIC  _GL
PUBLIC  _GF
PUBLIC  _GD
PUBLIC  _GA
PUBLIC  _GP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__fltused:NEAR
_DATA      SEGMENT
$SG24	DB	'%d %d %d %d %d %d',  0aH, '%d %d %d %d %f %f %d %d',  0aH,  00H
	EVEN
	PUBLIC	_Gc
_Gc	DB	00H
	EVEN
	PUBLIC	_Gs
_Gs	DW	01H
	PUBLIC	_Gi
_Gi	DD	02H
	PUBLIC	_Gl
_Gl	DD	03H
	PUBLIC	_Ga
_Ga	DB	0aH
	DB	014H
	DB	01eH
	DB	028H
	DB	032H
	DB	03cH
	DB	046H
	EVEN
	PUBLIC	_Gp
_Gp	DD	OFFSET DGROUP:_Ga+5
	PUBLIC	_GC
_GC	DB	080H
	EVEN
	PUBLIC	_GS
_GS	DW	08001H
	PUBLIC	_GI
_GI	DD	0fff1b4daH
	PUBLIC	_GL
_GL	DD	0d4e06d8aH
	PUBLIC	_GF
_GF	DD	04647b95eH   ;	12782.342
	PUBLIC	_GD
_GD	DQ	0c0f5f2f000000000H    ;	-89903.00000000000
	PUBLIC	_GA
_GA	DD	0fffffff8H
	DD	0fffffff7H
	DD	0fffffff6H
	DD	0fffffff5H
	DD	0fffffff4H
	PUBLIC	_GP
_GP	DD	OFFSET DGROUP:_GI
$S39_Sc	DB	053H
	EVEN
$S40_Ss	DW	01b1H
$S41_Si	DD	020c8H
$S42_Sl	DD	05b88H
$S43_Sa	DB	0aH
	DB	078H
	DB	00H
	DB	04H
	DB	032H
	DB	03cH
	DB	046H
	EVEN
$S44_Sp	DD	OFFSET DGROUP:$S43_Sa+5
$S45_SC	DB	02aH
	EVEN
$S46_SS	DW	05361H
$S47_SI	DD	03941bH
$S48_SL	DD	0fffee2daH
$S49_SF	DD	044decd71H   ;	1782.4200
$S50_SD	DQ	040c3578000000000H    ;	9903.000000000000
$S51_SA	DD	01b0H
	DD	0225H
	DD	0bc5f17H
	DD	0bH
	DD	0cH
$S52_SP	DD	OFFSET DGROUP:$S47_SI
$S59_a	DB	01H
	DB	02H
	DB	03H
	DB	04H
	DB	05H
	DB	06H
	DB	07H
	EVEN
$S67_A	DD	08H
	DD	09H
	DD	0aH
	DD	0bH
	DD	0cH
_DATA      ENDS
FUNCPARAMS_TEXT      SEGMENT
;	c = 6
;	s = 8
;	i = 10
;	l = 14
;	a = 18
;	p = 22
;	C = 26
;	S = 28
;	I = 30
;	L = 34
;	F = 38
;	D = 46
;	A = 54
;	P = 58
; Line 4
	PUBLIC	_func
_func	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
	push	di
	push	si
; Line 20
	les	bx,[bp+58]	;P
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	les	bx,[bp+54]	;A
	push	WORD PTR es:[bx+10]
	push	WORD PTR es:[bx+8]
	sub	sp,8
	lea	si,[bp+46]	;D
	mov	di,sp
	push	ss
	pop	es
	movsw
	movsw
	movsw
	movsw
	sub	sp,8
	lea	si,[bp+38]	;F
	mov	di,sp
	movsw
	movsw
	movsw
	movsw
	push	WORD PTR [bp+36]
	push	WORD PTR [bp+34]	;L
	push	WORD PTR [bp+32]
	push	WORD PTR [bp+30]	;I
	push	WORD PTR [bp+28]	;S
	mov	al,[bp+26]	;C
	cbw	
	push	ax
	les	bx,[bp+22]	;p
	mov	al,es:[bx]
	cbw	
	push	ax
	les	bx,[bp+18]	;a
	mov	al,es:[bx+3]
	cbw	
	push	ax
	push	WORD PTR [bp+16]
	push	WORD PTR [bp+14]	;l
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;i
	push	WORD PTR [bp+8]	;s
	mov	al,[bp+6]	;c
	sub	ah,ah
	push	ax
	mov	ax,OFFSET DGROUP:$SG24
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,56
; Line 21
	pop	si
	pop	di
	leave	
	ret	

_func	ENDP
; Line 55
FUNCPARAMS_TEXT      ENDS
CONST      SEGMENT
$T20001		DD	0444395e3H   ;	782.34198
CONST      ENDS
FUNCPARAMS_TEXT      SEGMENT
FUNCPARAMS_TEXT      ENDS
CONST      SEGMENT
$T20002		DQ	04116c31800000000H    ;	372934.0000000000
CONST      ENDS
FUNCPARAMS_TEXT      SEGMENT
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
; Line 56
	mov	BYTE PTR [bp-2],255	;c
; Line 57
	mov	WORD PTR [bp-26],-1	;s
; Line 58
	mov	WORD PTR [bp-32],-1	;i
	mov	WORD PTR [bp-30],32767
; Line 59
	mov	WORD PTR [bp-40],17397	;l
	mov	WORD PTR [bp-38],11
; Line 61
	mov	ax,OFFSET DGROUP:$S59_a+5
	mov	[bp-16],ax	;p
	mov	[bp-14],ds
; Line 62
	mov	BYTE PTR [bp-4],129	;C
; Line 63
	mov	WORD PTR [bp-28],32767	;S
; Line 64
	mov	WORD PTR [bp-36],-22626	;I
	mov	WORD PTR [bp-34],12
; Line 65
	mov	WORD PTR [bp-44],-18082	;L
	mov	WORD PTR [bp-42],125
; Line 66
	fld	$T20001
	fstp	DWORD PTR [bp-24]	;F
; Line 67
	fld	$T20002
	fstp	QWORD PTR [bp-12]	;D
	fwait	
; Line 69
	lea	ax,[bp-36]	;I
	mov	[bp-20],ax	;P
	mov	[bp-18],ss
; Line 70
	push	ss
	push	ax
	mov	ax,OFFSET DGROUP:$S67_A
	push	ds
	push	ax
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
	push	ds
	push	WORD PTR [bp-16]	;p
	mov	ax,OFFSET DGROUP:$S59_a
	push	ds
	push	ax
	push	WORD PTR [bp-38]
	push	WORD PTR [bp-40]	;l
	push	WORD PTR [bp-30]
	push	WORD PTR [bp-32]	;i
	push	WORD PTR [bp-26]	;s
	mov	al,[bp-2]	;c
	sub	ah,ah
	push	ax
	call	FAR PTR _func
	add	sp,56
; Line 71
	push	WORD PTR _GP+2
	push	WORD PTR _GP
	mov	ax,OFFSET DGROUP:_GA
	push	ds
	push	ax
	sub	sp,8
	mov	si,OFFSET DGROUP:_GD
	mov	di,sp
	push	ss
	pop	es
	movsw
	movsw
	movsw
	movsw
	fld	_GF
	sub	sp,8
	mov	bx,sp
	fstp	QWORD PTR [bx]
	fwait	
	push	WORD PTR _GL+2
	push	WORD PTR _GL
	push	WORD PTR _GI+2
	push	WORD PTR _GI
	push	_GS
	mov	al,_GC
	cbw	
	push	ax
	push	WORD PTR _Gp+2
	push	WORD PTR _Gp
	mov	ax,OFFSET DGROUP:_Ga
	push	ds
	push	ax
	push	WORD PTR _Gl+2
	push	WORD PTR _Gl
	push	WORD PTR _Gi+2
	push	WORD PTR _Gi
	push	_Gs
	mov	al,_Gc
	sub	ah,ah
	push	ax
	call	FAR PTR _func
	add	sp,56
; Line 72
	push	WORD PTR $S52_SP+2
	push	WORD PTR $S52_SP
	mov	ax,OFFSET DGROUP:$S51_SA
	push	ds
	push	ax
	sub	sp,8
	mov	si,OFFSET DGROUP:$S50_SD
	mov	di,sp
	push	ss
	pop	es
	movsw
	movsw
	movsw
	movsw
	fld	$S49_SF
	sub	sp,8
	mov	bx,sp
	fstp	QWORD PTR [bx]
	fwait	
	push	WORD PTR $S48_SL+2
	push	WORD PTR $S48_SL
	push	WORD PTR $S47_SI+2
	push	WORD PTR $S47_SI
	push	$S46_SS
	mov	al,$S45_SC
	cbw	
	push	ax
	push	WORD PTR $S44_Sp+2
	push	WORD PTR $S44_Sp
	mov	ax,OFFSET DGROUP:$S43_Sa
	push	ds
	push	ax
	push	WORD PTR $S42_Sl+2
	push	WORD PTR $S42_Sl
	push	WORD PTR $S41_Si+2
	push	WORD PTR $S41_Si
	push	$S40_Ss
	mov	al,$S39_Sc
	sub	ah,ah
	push	ax
	call	FAR PTR _func
	add	sp,56
; Line 73
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
FUNCPARAMS_TEXT	ENDS
END
