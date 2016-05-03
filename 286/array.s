;	Static Name Aliases
;
	TITLE   array

	.286p
	.287
ARRAY_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
ARRAY_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: ARRAY_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _p
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
_DATA      SEGMENT
$SG8	DB	'string1',  00H
$SG9	DB	'string2',  00H
$SG10	DB	'string3',  00H
$SG11	DB	'string4',  00H
$SG12	DB	'string5',  00H
$SG13	DB	'string6',  00H
$SG17	DB	'%c%c',  0aH,  00H
	PUBLIC	_p
_p	DD	OFFSET DGROUP:$SG8
	DD	OFFSET DGROUP:$SG9
	DD	OFFSET DGROUP:$SG10
	ORG	$+4
	DD	OFFSET DGROUP:$SG11
	DD	OFFSET DGROUP:$SG12
	DD	OFFSET DGROUP:$SG13
	ORG	$+4
_DATA      ENDS
ARRAY_TEXT      SEGMENT
; Line 5
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 6
	les	bx,DWORD PTR _p+24
	mov	al,es:[bx+6]
	cbw	
	push	ax
	les	bx,DWORD PTR _p+8
	mov	al,es:[bx+6]
	cbw	
	push	ax
	mov	ax,OFFSET DGROUP:$SG17
	push	ds
	push	ax
	call	FAR PTR _printf
; Line 7
	leave	
	ret	

_main	ENDP
ARRAY_TEXT	ENDS
END
