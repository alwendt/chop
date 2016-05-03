;	Static Name Aliases
;
;	$S12_i	EQU	i
	TITLE   funcptr

	.286p
	.287
FUNCPTR_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
FUNCPTR_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: FUNCPTR_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
_DATA      SEGMENT
$SG9	DB	'hello',  00H
$SG17	DB	'%d',  0aH,  00H
$SG18	DB	'%s',  0aH,  00H
$S12_i	DD	01e67H
_DATA      ENDS
FUNCPTR_TEXT      SEGMENT
; Line 3
	PUBLIC	_hello
_hello	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 4
	mov	ax,OFFSET DGROUP:$SG9
	mov	dx,ds
	leave	
	ret	

_hello	ENDP
; Line 8
	PUBLIC	_hi
_hi	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 10
	mov	ax,OFFSET DGROUP:$S12_i
	mov	dx,ds
	leave	
	ret	

_hi	ENDP
; Line 14
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	p = -4
; Line 17
	mov	WORD PTR [bp-4],OFFSET _hi	;p
	mov	[bp-2],SEG _hi
; Line 18
	call	FAR PTR [bp-4]	;p
	mov	bx,ax
	mov	es,dx
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	mov	ax,OFFSET DGROUP:$SG17
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 19
	mov	WORD PTR [bp-4],OFFSET _hello	;p
	mov	[bp-2],SEG _hello
; Line 20
	call	FAR PTR [bp-4]	;p
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG18
	push	ds
	push	ax
	call	FAR PTR _printf
; Line 21
	leave	
	ret	

_main	ENDP
FUNCPTR_TEXT	ENDS
END
