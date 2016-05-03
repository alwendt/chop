;	Static Name Aliases
;
	TITLE   switch

	.286p
	.287
SWITCH_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
SWITCH_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: SWITCH_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_exit:FAR
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__lmul:FAR
_DATA      SEGMENT
$SG21	DB	'i is %d',  0aH,  00H
	EVEN
$SG29	DB	'i is %d',  0aH,  00H
	EVEN
$SG36	DB	'i is %d',  0aH,  00H
	EVEN
$SG47	DB	'i is %d',  0aH,  00H
	EVEN
$SG67	DB	'i is %d',  0aH,  00H
	EVEN
_DATA      ENDS
SWITCH_TEXT      SEGMENT
; Line 2
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	i = -4
; Line 3
	mov	WORD PTR [bp-4],3	;i
	mov	WORD PTR [bp-2],0
; Line 5
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
	or	ax,ax
	je	$SC14
	cmp	ax,1
	je	$SC15
	cmp	ax,2
	je	$SC16
	cmp	ax,3
	je	$SC17
	cmp	ax,5
	je	$SC18
	cmp	ax,7
	je	$SC19
	jmp	SHORT $SB11
$SC14:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 8
$SC15:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 9
$SC16:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 10
$SC17:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 11
$SC18:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 12
$SC19:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 13
$SB11:
; Line 14
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;i
	mov	ax,OFFSET DGROUP:$SG21
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 16
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
	cmp	ax,5
	je	$SC28
	cmp	ax,6
	je	$SC27
	cmp	ax,7
	jne	$SB23
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 19
$SC27:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 20
$SC28:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 21
$SB23:
; Line 22
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;i
	mov	ax,OFFSET DGROUP:$SG29
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 24
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
	cmp	ax,2
	je	$SC34
	cmp	ax,3
	je	$SC35
	jmp	SHORT $SB31
$SC34:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 27
$SC35:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 28
$SB31:
; Line 29
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;i
	mov	ax,OFFSET DGROUP:$SG36
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 31
	push	WORD PTR 0
	push	WORD PTR 100
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;i
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
	call	FAR PTR __lmul
	or	ax,ax
	je	$SC41
	cmp	ax,100
	je	$SC42
	cmp	ax,200
	je	$SC43
	cmp	ax,300
	je	$SC44
	cmp	ax,400
	je	$SC45
	cmp	ax,500
	je	$SC46
	jmp	SHORT $SB38
$SC41:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 34
$SC42:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 35
$SC43:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 36
$SC44:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 37
$SC45:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 38
$SC46:
	sub	WORD PTR [bp-4],1	;i
	sbb	WORD PTR [bp-2],0
; Line 39
$SB38:
; Line 40
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;i
	mov	ax,OFFSET DGROUP:$SG47
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 42
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
	cmp	ax,11
	je	$SC58
	jle	$JCC406
	jmp	$L20002
$JCC406:
	or	ax,ax
	je	$SC52
	cmp	ax,1
	je	$SC53
	cmp	ax,2
	je	$SC54
	cmp	ax,3
	je	$SC55
	cmp	ax,4
	je	$SC56
	cmp	ax,10
	je	$SC57
	jmp	$SB49
$SC52:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 45
$SC53:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 46
$SC54:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 47
$SC55:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 48
$SC56:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 49
$SC57:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 50
$SC58:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 51
$SC59:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 52
$SC60:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 53
$SC61:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 54
$SC62:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 55
$SC63:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 56
$SC64:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 57
$SC65:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 58
$SC66:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
; Line 59
	jmp	SHORT $SB49
$L20002:
	cmp	ax,110
	je	$SC62
	jg	$L20003
	cmp	ax,12
	je	$SC59
	cmp	ax,13
	je	$SC60
	cmp	ax,14
	je	$SC61
	jmp	SHORT $SB49
$L20003:
	cmp	ax,111
	je	$SC63
	cmp	ax,112
	je	$SC64
	cmp	ax,113
	je	$SC65
	cmp	ax,114
	je	$SC66
$SB49:
; Line 60
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;i
	mov	ax,OFFSET DGROUP:$SG67
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 61
	push	WORD PTR 0
	call	FAR PTR _exit
; Line 62
	leave	
	ret	

_main	ENDP
SWITCH_TEXT	ENDS
END
