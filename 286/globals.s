;	Static Name Aliases
;
	TITLE   globals

	.286p
	.287
GLOBALS_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
GLOBALS_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: GLOBALS_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _i
PUBLIC  _j
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__blmul:FAR
EXTRN	__bldiv:FAR
EXTRN	__blrem:FAR
EXTRN	__blshl:FAR
EXTRN	__blshr:FAR
_DATA      SEGMENT
$SG12	DB	'i %d j %d',  0aH,  00H
	EVEN
	PUBLIC	_i
_i	DD	064H
	PUBLIC	_j
_j	DD	03H
_DATA      ENDS
GLOBALS_TEXT      SEGMENT
; Line 4
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 5
	mov	ax,WORD PTR _j
	mov	dx,WORD PTR _j+2
	sub	WORD PTR _i,ax
	sbb	WORD PTR _i+2,dx
; Line 6
	add	WORD PTR _i,ax
	adc	WORD PTR _i+2,dx
; Line 7
	add	WORD PTR _i,1
	adc	WORD PTR _i+2,0
; Line 8
	sub	WORD PTR _i,1
	sbb	WORD PTR _i+2,0
; Line 9
	push	dx
	push	ax
	push	OFFSET DGROUP:WORD PTR _i
	call	FAR PTR __blmul
; Line 10
	push	WORD PTR _j+2
	push	WORD PTR _j
	push	OFFSET DGROUP:WORD PTR _i
	call	FAR PTR __bldiv
; Line 11
	mov	ax,WORD PTR _j
	mov	dx,WORD PTR _j+2
	xor	WORD PTR _i,ax
	xor	WORD PTR _i+2,dx
; Line 12
	push	dx
	push	ax
	push	OFFSET DGROUP:WORD PTR _i
	call	FAR PTR __blrem
; Line 13
	mov	al,BYTE PTR _j
	cbw	
	push	ax
	push	OFFSET DGROUP:WORD PTR _i
	call	FAR PTR __blshl
; Line 14
	mov	al,BYTE PTR _j
	cbw	
	push	ax
	push	OFFSET DGROUP:WORD PTR _i
	call	FAR PTR __blshr
; Line 15
	mov	ax,WORD PTR _j
	mov	dx,WORD PTR _j+2
	or	WORD PTR _i,ax
	or	WORD PTR _i+2,dx
; Line 16
	and	WORD PTR _i,ax
	and	WORD PTR _i+2,dx
; Line 17
	not	ax
	not	dx
	mov	WORD PTR _i,ax
	mov	WORD PTR _i+2,dx
; Line 18
	mov	ax,WORD PTR _j
	mov	dx,WORD PTR _j+2
	neg	ax
	adc	dx,0
	neg	dx
	mov	WORD PTR _i,ax
	mov	WORD PTR _i+2,dx
; Line 19
	push	WORD PTR _j+2
	push	WORD PTR _j
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG12
	push	ds
	push	ax
	call	FAR PTR _printf
; Line 20
	leave	
	ret	

_main	ENDP
GLOBALS_TEXT	ENDS
END
