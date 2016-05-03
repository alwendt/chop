;	Static Name Aliases
;
	TITLE   spill

	.286p
	.287
SPILL_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
SPILL_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: SPILL_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	_i:DWORD
EXTRN	_j:DWORD
EXTRN	_k:DWORD
_DATA      SEGMENT
$SG25	DB	'%d ',  00H
$SG26	DB	0aH,  00H
;	.comm _i,04H
;	.comm _j,04H
;	.comm _k,04H
_DATA      ENDS
SPILL_TEXT      SEGMENT
; Line 2
	PUBLIC	_fee
_fee	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
	mov	ax,1
	leave	
	ret	

_fee	ENDP
; Line 3
	PUBLIC	_fie
_fie	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
	mov	ax,2
	leave	
	ret	

_fie	ENDP
; Line 4
	PUBLIC	_foo
_foo	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
	mov	ax,3
	leave	
	ret	

_foo	ENDP
; Line 5
	PUBLIC	_fum
_fum	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
	mov	ax,4
	leave	
	ret	

_fum	ENDP
; Line 10
SPILL_TEXT      ENDS
CONST      SEGMENT
$T20001	DW SEG _j 
CONST      ENDS
SPILL_TEXT      SEGMENT
SPILL_TEXT      ENDS
CONST      SEGMENT
$T20005	DW SEG _k 
CONST      ENDS
SPILL_TEXT      SEGMENT
SPILL_TEXT      ENDS
CONST      SEGMENT
$T20006	DW SEG _i 
CONST      ENDS
SPILL_TEXT      SEGMENT
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,6
	call	FAR PTR __chkstk
	push	di
	push	si
; Line 11
	mov	es,$T20001
	sub	ax,ax
	mov	WORD PTR es:_j+2,ax
	mov	WORD PTR es:_j,ax
$F20:
	mov	es,$T20001
	cmp	WORD PTR es:_j+2,0
	jle	$JCC97
	jmp	$FB22
$JCC97:
	jl	$F23
	cmp	WORD PTR es:_j,2
	jb	$JCC110
	jmp	$FB22
$JCC110:
$F23:
; Line 12
	call	FAR PTR _fum
	cwd	
	mov	si,ax
	mov	di,dx
	call	FAR PTR _foo
	cwd	
	mov	es,$T20001
	mov	[bp-4],ax
	mov	[bp-2],dx
	mov	ax,WORD PTR es:_j
	or	ax,WORD PTR es:_j+2
	je	$L20003
	call	FAR PTR _fie
	mov	[bp-6],ax
	call	FAR PTR _fee
	add	ax,[bp-6]
	cwd	
	mov	es,$T20001
	add	ax,WORD PTR es:_j
	adc	dx,WORD PTR es:_j+2
	jmp	SHORT $L20004
$L20003:
	mov	es,$T20005
	mov	ax,WORD PTR es:_k
	mov	dx,WORD PTR es:_k+2
$L20004:
	add	ax,[bp-4]
	adc	dx,[bp-2]
	add	ax,si
	adc	dx,di
	mov	es,$T20006
	mov	WORD PTR es:_i,ax
	mov	WORD PTR es:_i+2,dx
; Line 13
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG25
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 14
	mov	es,$T20001
	add	WORD PTR es:_j,1
	adc	WORD PTR es:_j+2,0
	jmp	$F20
$FB22:
; Line 15
	mov	ax,OFFSET DGROUP:$SG26
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 16
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
SPILL_TEXT	ENDS
END
