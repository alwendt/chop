;	Static Name Aliases
;
	TITLE   ij

	.286p
	.287
IJ_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
IJ_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: IJ_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _i
PUBLIC  _j
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
_DATA      SEGMENT
$SG12	DB	'%d %d',  0aH,  00H
	EVEN
	PUBLIC	_i
_i	DD	07H
	PUBLIC	_j
_j	DD	09H
_DATA      ENDS
IJ_TEXT      SEGMENT
; Line 3
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 4
	mov	ax,WORD PTR _i
	mov	dx,WORD PTR _i+2
	add	WORD PTR _j,ax
	adc	WORD PTR _j+2,dx
	mov	ax,WORD PTR _j
	mov	dx,WORD PTR _j+2
	mov	WORD PTR _i,ax
	mov	WORD PTR _i+2,dx
; Line 5
	push	dx
	push	ax
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG12
	push	ds
	push	ax
	call	FAR PTR _printf
; Line 6
	leave	
	ret	

_main	ENDP
IJ_TEXT	ENDS
END
