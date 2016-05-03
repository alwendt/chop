;	Static Name Aliases
;
	TITLE   constarray

	.286p
	.287
CONSTARRAY_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
CONSTARRAY_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: CONSTAR_main	PROC FAR
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
	mov	BYTE PTR [bp-2],255	;c
; Line 6
	mov	WORD PTR [bp-26],932	;s
; Line 7
	mov	WORD PTR [bp-32],-22062	;i
	mov	WORD PTR [bp-30],-157
; Line 8
	mov	WORD PTR [bp-40],7607	;l
	mov	WORD PTR [bp-38],431
; Line 10
	mov	ax,OFFSET DGROUP:$S13_a+5
	mov	[bp-16],ax	;p
	mov	[bp-14],ds
; Line 11
	mov	BYTE PTR [bp-4],123	;C
; Line 12
	mov	WORD PTR [bp-28],117	;S
; Line 13
	mov	WORD PTR [bp-36],-14392	;I
	mov	WORD PTR [bp-34],-691
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
	mov	ax,OFFSET DGROUP:$S21_A+4
	mov	[bp-20],ax	;P
	mov	[bp-18],ds
; Line 20
	mov	cl,5
	mov	al,[bp-2]	;c
	sub	ah,ah
	div	cl
	mov	[bp-2],al	;c
; Line 21
	mov	cl,al
	shr	cl,1
	sub	ah,ah
	div	cl
	mov	[bp-2],al	;c
; Line 22
	mov	cx,15
	mov	ax,[bp-26]	;s
	sub	dx,dx
	div	cx
	mov	[bp-26],ax	;s
; Line 23
	sub	dx,dx
	mov	cx,24
	div	cx
	mov	cx,ax
	mov	ax,[bp-26]	;s
	sub	dx,dx
	div	cx
	mov	[bp-26],ax	;s
; Line 24
	push	WORD PTR 0
	push	WORD PTR 468
	lea	ax,[bp-32]	;i
	push	ss
	push	ax
	call	FAR PTR __auldiv
; Line 25
	push	WORD PTR 0
	push	WORD PTR 245
	push	WORD PTR [bp-30]
	push	WORD PTR [bp-32]	;i
	call	FAR PTR __uldiv
	push	dx
	push	ax
	lea	ax,[bp-32]	;i
	push	ss
	push	ax
	call	FAR PTR __auldiv
; Line 26
	push	WORD PTR 0
	push	WORD PTR 83
	lea	ax,[bp-40]	;l
	push	ss
	push	ax
	call	FAR PTR __auldiv
; Line 27
	push	WORD PTR 0
	push	WORD PTR 246
	push	WORD PTR [bp-38]
	push	WORD PTR [bp-40]	;l
	call	FAR PTR __uldiv
	push	dx
	push	ax
	lea	ax,[bp-40]	;l
	push	ss
	push	ax
	call	FAR PTR __auldiv
; Line 28
	mov	al,BYTE PTR $S13_a+2
	cbw	
	idiv	BYTE PTR $S13_a+4
	mov	BYTE PTR $S13_a+2,al
; Line 29
	les	bx,[bp-16]	;p
	mov	cl,es:[bx-1]
	mov	al,es:[bx+2]
	cbw	
	idiv	cl
	mov	es:[bx+2],al
; Line 30
	mov	cl,255
	mov	al,[bp-4]	;C
	cbw	
	idiv	cl
	mov	[bp-4],al	;C
; Line 31
	cbw	
	mov	cl,2
	idiv	cl
	mov	cl,al
	mov	al,[bp-4]	;C
	cbw	
	idiv	cl
	mov	[bp-4],al	;C
; Line 32
	mov	cx,7
	mov	ax,[bp-28]	;S
	cwd	
	idiv	cx
	mov	[bp-28],ax	;S
; Line 33
	cwd	
	mov	cx,4
	idiv	cx
	mov	cx,ax
	mov	ax,[bp-28]	;S
	cwd	
	idiv	cx
	mov	[bp-28],ax	;S
; Line 34
	push	WORD PTR -1
	push	WORD PTR -932
	lea	ax,[bp-36]	;I
	push	ss
	push	ax
	call	FAR PTR __aldiv
; Line 35
	push	WORD PTR 0
	push	WORD PTR 63
	push	WORD PTR [bp-34]
	push	WORD PTR [bp-36]	;I
	call	FAR PTR __ldiv
	push	dx
	push	ax
	lea	ax,[bp-36]	;I
	push	ss
	push	ax
	call	FAR PTR __aldiv
; Line 36
	push	WORD PTR -1
	push	WORD PTR -44
	lea	ax,[bp-44]	;L
	push	ss
	push	ax
	call	FAR PTR __aldiv
; Line 37
	push	WORD PTR 0
	push	WORD PTR 23
	push	WORD PTR [bp-42]
	push	WORD PTR [bp-44]	;L
	call	FAR PTR __ldiv
	push	dx
	push	ax
	lea	ax,[bp-44]	;L
	push	ss
	push	ax
	call	FAR PTR __aldiv
; Line 38
	fld	$T20007
	fmul	DWORD PTR [bp-24]	;F
	fst	DWORD PTR [bp-24]	;F
; Line 39
	fmul	DWORD PTR [bp-24]	;F
	fstp	DWORD PTR [bp-24]	;F
; Line 40
	fld	$T20008
	fmul	QWORD PTR [bp-12]	;D
	fst	QWORD PTR [bp-12]	;D
; Line 41
	fmul	QWORD PTR [bp-12]	;D
	fstp	QWORD PTR [bp-12]	;D
	fwait	
; Line 42
	push	WORD PTR $S21_A+2
	push	WORD PTR $S21_A
	push	OFFSET DGROUP:WORD PTR $S21_A+4
	call	FAR PTR __bldiv
; Line 43
	les	bx,[bp-20]	;P
	push	WORD PTR es:[bx+14]
	push	WORD PTR es:[bx+12]
	mov	ax,bx
	mov	dx,es
	sub	ax,4
	push	dx
	push	ax
	call	FAR PTR __aldiv
; Line 45
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
; Line 46
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
DIVISION_TEXT	ENDS
END
