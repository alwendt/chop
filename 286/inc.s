;	Static Name Aliases
;
	TITLE   inc

	.286p
	.287
INC_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
INC_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: INC_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _i
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
_DATA      SEGMENT
$SG11	DB	'%d',  0aH,  00H
	PUBLIC	_i
_i	DB	07H
	EVEN
_DATA      ENDS
INC_TEXT      SEGMENT
; Line 3
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 4
	mov	al,_i
	add	_i,al
; Line 5
	mov	al,_i
	cbw	
	push	ax
	mov	ax,OFFSET DGROUP:$SG11
	push	ds
	push	ax
	call	FAR PTR _printf
; Line 6
	leave	
	ret	

_main	ENDP
INC_TEXT	ENDS
END
