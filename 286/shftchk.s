;	Static Name Aliases
;
	TITLE   shftchk

	.286p
	.287
SHFTCHK_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
SHFTCHK_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: SHFTCHK_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _fun
EXTRN	_sprintf:FAR
EXTRN	_strcmp:FAR
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	__lshl:FAR
EXTRN	__ulshr:FAR
EXTRN	__ulrem:FAR
_DATA      SEGMENT
$SG14	DB	'%d',  00H
	EVEN
$SG15	DB	'%d',  00H
	EVEN
$SG19	DB	'<< not ok',  0aH,  00H
	EVEN
$SG21	DB	'<< ok',  0aH,  00H
	EVEN
$SG22	DB	'%d',  00H
	EVEN
$SG23	DB	'%d',  00H
	EVEN
$SG25	DB	'>> not ok',  0aH,  00H
	EVEN
$SG27	DB	'>> ok',  0aH,  00H
	EVEN
	PUBLIC	_fun
_fun	DD	0d5H
	DD	034eaH
	DD	03930eH
	DD	01aH
	DD	0fffffffcH
	DD	0eaH
	DD	0ffffffe8H
	ORG	$+12
_DATA      ENDS
SHFTCHK_TEXT      SEGMENT
; Line 4
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,44
	call	FAR PTR __chkstk
	push	di
	push	si
;	bf0 = -20
;	i = -24
;	bf1 = -44
; Line 5
	mov	WORD PTR [bp-24],5	;i
	mov	WORD PTR [bp-22],0
; Line 8
	mov	ax,[bp-24]	;i
	mov	dx,[bp-22]
	mov	cl,10
	call	FAR PTR __lshl
	mov	bx,[bp-24]	;i
	shl	bx,2
	mov	cx,WORD PTR _fun[bx]
	mov	si,WORD PTR _fun[bx+2]
	add	cx,ax
	adc	si,dx
	push	si
	push	cx
	mov	ax,OFFSET DGROUP:$SG14
	push	ds
	push	ax
	lea	ax,[bp-20]	;bf0
	push	ss
	push	ax
	call	FAR PTR _sprintf
	add	sp,12
; Line 9
	mov	ax,[bp-24]	;i
	mov	dx,[bp-22]
	mov	cl,10
	call	FAR PTR __lshl
	mov	bx,[bp-24]	;i
	shl	bx,2
	mov	cx,WORD PTR _fun[bx]
	mov	si,WORD PTR _fun[bx+2]
	add	cx,ax
	adc	si,dx
	push	si
	push	cx
	mov	ax,OFFSET DGROUP:$SG15
	push	ds
	push	ax
	lea	ax,[bp-44]	;bf1
	push	ss
	push	ax
	call	FAR PTR _sprintf
	add	sp,12
; Line 10
	lea	ax,[bp-44]	;bf1
	push	ss
	push	ax
	lea	ax,[bp-20]	;bf0
	push	ss
	push	ax
	call	FAR PTR _strcmp
	add	sp,8
	or	ax,ax
	je	$I17
; Line 12
	mov	ax,OFFSET DGROUP:$SG19
	jmp	SHORT $L20004
$I17:
; Line 15
	mov	ax,OFFSET DGROUP:$SG21
$L20004:
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 18
	mov	WORD PTR [bp-24],25583	;i
	mov	WORD PTR [bp-22],110
; Line 19
	mov	ax,[bp-24]	;i
	mov	dx,[bp-22]
	mov	cl,10
	call	FAR PTR __ulshr
	push	WORD PTR 0
	push	WORD PTR 10
	push	WORD PTR [bp-22]
	push	WORD PTR [bp-24]	;i
	mov	si,ax
	mov	di,dx
	call	FAR PTR __ulrem
	mov	bx,ax
	shl	bx,2
	add	si,WORD PTR _fun[bx]
	adc	di,WORD PTR _fun[bx+2]
	push	di
	push	si
	mov	ax,OFFSET DGROUP:$SG22
	push	ds
	push	ax
	lea	ax,[bp-20]	;bf0
	push	ss
	push	ax
	call	FAR PTR _sprintf
	add	sp,12
; Line 20
	mov	ax,[bp-24]	;i
	mov	dx,[bp-22]
	mov	cl,10
	call	FAR PTR __ulshr
	push	WORD PTR 0
	push	WORD PTR 10
	push	WORD PTR [bp-22]
	push	WORD PTR [bp-24]	;i
	mov	si,ax
	mov	di,dx
	call	FAR PTR __ulrem
	mov	bx,ax
	shl	bx,2
	add	si,WORD PTR _fun[bx]
	adc	di,WORD PTR _fun[bx+2]
	push	di
	push	si
	mov	ax,OFFSET DGROUP:$SG23
	push	ds
	push	ax
	lea	ax,[bp-44]	;bf1
	push	ss
	push	ax
	call	FAR PTR _sprintf
	add	sp,12
; Line 21
	lea	ax,[bp-44]	;bf1
	push	ss
	push	ax
	lea	ax,[bp-20]	;bf0
	push	ss
	push	ax
	call	FAR PTR _strcmp
	add	sp,8
	or	ax,ax
	je	$I24
; Line 23
	mov	ax,OFFSET DGROUP:$SG25
	jmp	SHORT $L20005
$I24:
; Line 26
	mov	ax,OFFSET DGROUP:$SG27
$L20005:
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 28
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
SHFTCHK_TEXT	ENDS
END
