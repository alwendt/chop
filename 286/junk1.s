;	Static Name Aliases
;
	TITLE   junk1

	.286p
	.287
JUNK1_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
JUNK1_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: JUNK1_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__fltused:NEAR
_DATA      SEGMENT
$SG12	DB	'%.8f',  0aH,  00H
_DATA      ENDS
JUNK1_TEXT      SEGMENT
JUNK1_TEXT      ENDS
CONST      SEGMENT
$T20001		DD	03eaf1aa0H   ;	.34200001
CONST      ENDS
JUNK1_TEXT      SEGMENT
JUNK1_TEXT      ENDS
CONST      SEGMENT
$T20002		DQ	040a9440000000000H    ;	3234.000000000000
CONST      ENDS
JUNK1_TEXT      SEGMENT
JUNK1_TEXT      ENDS
CONST      SEGMENT
$T20003		DD	04290af1bH   ;	72.342003
CONST      ENDS
JUNK1_TEXT      SEGMENT
JUNK1_TEXT      ENDS
CONST      SEGMENT
$T20004		DQ	040a24c999999999aH    ;	2342.300000000000
CONST      ENDS
JUNK1_TEXT      SEGMENT
JUNK1_TEXT      ENDS
CONST      SEGMENT
$T20005		DQ	040aebda8f5c28f5cH    ;	3934.830000000000
CONST      ENDS
JUNK1_TEXT      SEGMENT
JUNK1_TEXT      ENDS
CONST      SEGMENT
$T20006		DQ	03ee4f8b588e368f1H    ;	1.000000000000000E-05
CONST      ENDS
JUNK1_TEXT      SEGMENT
; Line 4
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,12
	call	FAR PTR __chkstk
	push	di
	push	si
;	D = -8
;	F = -12
; Line 5
	fld	$T20001
	fstp	DWORD PTR [bp-12]	;F
; Line 6
	fld	$T20002
	fstp	QWORD PTR [bp-8]	;D
; Line 7
	fld	$T20003
	fadd	DWORD PTR [bp-12]	;F
	fst	DWORD PTR [bp-12]	;F
; Line 8
	fadd	$T20004
	fadd	DWORD PTR [bp-12]	;F
	fstp	DWORD PTR [bp-12]	;F
; Line 9
	fld	$T20005
	fadd	QWORD PTR [bp-8]	;D
	fst	QWORD PTR [bp-8]	;D
; Line 10
	fadd	$T20006
	fadd	QWORD PTR [bp-8]	;D
	fstp	QWORD PTR [bp-8]	;D
	fwait	
; Line 11
	sub	sp,8
	lea	si,[bp-8]	;D
	mov	di,sp
	push	ss
	pop	es
	movsw
	movsw
	movsw
	movsw
	mov	ax,OFFSET DGROUP:$SG12
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,12
; Line 12
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
JUNK1_TEXT	ENDS
END
