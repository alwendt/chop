;	Static Name Aliases
;
	TITLE   8q

	.286p
	.287
8Q_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
8Q_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: 8Q_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	__chkstk:FAR
EXTRN	_putchar:FAR
EXTRN	_up:BYTE
EXTRN	_down:BYTE
EXTRN	_rows:BYTE
EXTRN	_x:BYTE
;	.comm _up,03cH
;	.comm _down,03cH
;	.comm _rows,020H
;	.comm _x,020H
8Q_TEXT      SEGMENT
;	c = 6
8Q_TEXT      ENDS
CONST      SEGMENT
$T20002	DW SEG _rows 
CONST      ENDS
8Q_TEXT      SEGMENT
8Q_TEXT      ENDS
CONST      SEGMENT
$T20003	DW SEG _up 
CONST      ENDS
8Q_TEXT      SEGMENT
8Q_TEXT      ENDS
CONST      SEGMENT
$T20004	DW SEG _down 
CONST      ENDS
8Q_TEXT      SEGMENT
8Q_TEXT      ENDS
CONST      SEGMENT
$T20005	DW SEG _x 
CONST      ENDS
8Q_TEXT      SEGMENT
; Line 6
	PUBLIC	_queens
_queens	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	r = -4
; Line 9
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;r
$F15:
	cmp	WORD PTR [bp-2],0
	jle	$JCC23
	jmp	$FB17
$JCC23:
	jl	$F18
	cmp	WORD PTR [bp-4],8	;r
	jb	$JCC34
	jmp	$FB17
$JCC34:
$F18:
; Line 10
	mov	bx,[bp-4]	;r
	shl	bx,2
	mov	es,$T20002
	mov	ax,WORD PTR es:_rows[bx]
	or	ax,WORD PTR es:_rows[bx+2]
	jne	$JCC59
	jmp	$I19
$JCC59:
	mov	bx,[bp-4]	;r
	sub	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20003
	mov	ax,WORD PTR es:_up[bx+28]
	or	ax,WORD PTR es:_up[bx+30]
	jne	$JCC87
	jmp	$I19
$JCC87:
	mov	bx,[bp-4]	;r
	add	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20004
	mov	ax,WORD PTR es:_down[bx]
	or	ax,WORD PTR es:_down[bx+2]
	jne	$JCC115
	jmp	$I19
$JCC115:
; Line 11
	mov	bx,[bp-4]	;r
	add	bx,[bp+6]	;c
	shl	bx,2
	sub	ax,ax
	cwd	
	mov	WORD PTR es:_down[bx],ax
	mov	WORD PTR es:_down[bx+2],dx
	mov	bx,[bp-4]	;r
	sub	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20003
	mov	WORD PTR es:_up[bx+28],ax
	mov	WORD PTR es:_up[bx+30],dx
	mov	bx,[bp-4]	;r
	shl	bx,2
	mov	es,$T20002
	mov	WORD PTR es:_rows[bx],ax
	mov	WORD PTR es:_rows[bx+2],dx
; Line 12
	mov	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20005
	mov	ax,[bp-4]	;r
	mov	dx,[bp-2]
	mov	WORD PTR es:_x[bx],ax
	mov	WORD PTR es:_x[bx+2],dx
; Line 13
	cmp	WORD PTR [bp+6],7	;c
	jne	$I20
	call	FAR PTR _prlong
; Line 14
	jmp	SHORT $I22
$I20:
	mov	ax,[bp+6]	;c
	inc	ax
	push	ax
	call	FAR PTR _queens
	add	sp,2
$I22:
; Line 15
	mov	bx,[bp-4]	;r
	add	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20004
	mov	ax,1
	cwd	
	mov	WORD PTR es:_down[bx],ax
	mov	WORD PTR es:_down[bx+2],dx
	mov	bx,[bp-4]	;r
	sub	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20003
	mov	WORD PTR es:_up[bx+28],ax
	mov	WORD PTR es:_up[bx+30],dx
	mov	bx,[bp-4]	;r
	shl	bx,2
	mov	es,$T20002
	mov	WORD PTR es:_rows[bx],ax
	mov	WORD PTR es:_rows[bx+2],dx
; Line 17
$I19:
	add	WORD PTR [bp-4],1	;r
	adc	WORD PTR [bp-2],0
	jmp	$F15
$FB17:
	leave	
	ret	

_queens	ENDP
; Line 19
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	i = -4
; Line 22
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;i
$F26:
	cmp	WORD PTR [bp-2],0
	jg	$FB28
	jl	$F29
	cmp	WORD PTR [bp-4],15	;i
	jae	$FB28
$F29:
; Line 23
	mov	bx,[bp-4]	;i
	shl	bx,2
	mov	es,$T20004
	mov	ax,1
	cwd	
	mov	WORD PTR es:_down[bx],ax
	mov	WORD PTR es:_down[bx+2],dx
	mov	bx,[bp-4]	;i
	shl	bx,2
	mov	es,$T20003
	mov	WORD PTR es:_up[bx],ax
	mov	WORD PTR es:_up[bx+2],dx
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
	jmp	SHORT $F26
$FB28:
; Line 24
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;i
$F30:
	cmp	WORD PTR [bp-2],0
	jg	$FB32
	jl	$F33
	cmp	WORD PTR [bp-4],8	;i
	jae	$FB32
$F33:
; Line 25
	mov	bx,[bp-4]	;i
	shl	bx,2
	mov	es,$T20002
	mov	WORD PTR es:_rows[bx],1
	mov	WORD PTR es:_rows[bx+2],0
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
	jmp	SHORT $F30
$FB32:
; Line 26
	push	WORD PTR 0
	call	FAR PTR _queens
; Line 27
	leave	
	ret	

_main	ENDP
; Line 29
	PUBLIC	_prlong
_prlong	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	k = -4
; Line 32
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;k
$F36:
	cmp	WORD PTR [bp-2],0
	jg	$FB38
	jl	$F39
	cmp	WORD PTR [bp-4],8	;k
	jae	$FB38
$F39:
; Line 33
	push	WORD PTR 32
	call	FAR PTR _putchar
	add	sp,2
; Line 34
	mov	bx,[bp-4]	;k
	shl	bx,2
	mov	es,$T20005
	mov	ax,WORD PTR es:_x[bx]
	mov	dx,WORD PTR es:_x[bx+2]
	add	ax,49
	adc	dx,0
	push	dx
	push	ax
	call	FAR PTR _putchar
	add	sp,4
; Line 35
	add	WORD PTR [bp-4],1	;k
	adc	WORD PTR [bp-2],0
	jmp	SHORT $F36
$FB38:
; Line 36
	push	WORD PTR 10
	call	FAR PTR _putchar
; Line 37
	leave	
	ret	

_prlong	ENDP
8Q_TEXT	ENDS
END
