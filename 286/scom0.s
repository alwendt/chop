;	Static Name Aliases
;
;	$S7_last	EQU	last
;	$S8_count	EQU	count
;	$S9_current	EQU	current
;	$S10_endfile	EQU	endfile
;	$S11_nb	EQU	nb
	TITLE   scom0

	.286p
	.287
SCOM0_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
SCOM0_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: SCOM0_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	_exit:FAR
EXTRN	__chkstk:FAR
_DATA      SEGMENT
$SG25	DB	'false',  0aH,  00H
	EVEN
$SG27	DB	'true %d',  0aH,  00H
	EVEN
$S7_last	DD	00H
	DD	00H
$S8_count	DD	00H
	DD	00H
$S9_current	DD	00H
	DD	00H
$S10_endfile	DD	0ffffffffH
	DD	0ffffffffH
$S11_nb	DB	00H
	DB	00H
_DATA      ENDS
SCOM0_TEXT      SEGMENT
; Line 7
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
	push	di
	push	si
;	k = -4
; Line 8
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;k
; Line 10
	mov	al,BYTE PTR $S11_nb+1
	cbw	
	cwd	
	mov	cx,[bp-4]	;k
	mov	bx,[bp-2]
	add	cx,WORD PTR $S8_count+4
	adc	bx,WORD PTR $S8_count+6
	add	cx,ax
	adc	bx,dx
	cmp	bx,WORD PTR $S10_endfile+6
	jne	$L20003
	cmp	cx,WORD PTR $S10_endfile+4
	jne	$L20003
	mov	ax,1
	jmp	SHORT $L20004
$L20003:
	sub	ax,ax
$L20004:
	mov	cx,ax
	mov	al,BYTE PTR $S11_nb
	cbw	
	cwd	
	mov	bx,[bp-4]	;k
	mov	si,[bp-2]
	add	bx,WORD PTR $S8_count
	adc	si,WORD PTR $S8_count+2
	add	bx,ax
	adc	si,dx
	mov	di,cx
	cmp	si,WORD PTR $S10_endfile+2
	jne	$L20001
	cmp	bx,WORD PTR $S10_endfile
	jne	$L20001
	mov	ax,1
	jmp	SHORT $L20002
$L20001:
	sub	ax,ax
$L20002:
	add	ax,di
	or	ax,ax
	je	$SC19
	cmp	ax,1
	je	$SB16
	cmp	ax,2
	je	$tru21
	jmp	SHORT $SB16
$SC19:
	add	WORD PTR [bp-4],1	;k
	adc	WORD PTR [bp-2],0
; Line 13
	jmp	SHORT $tru21
$SB16:
; Line 16
	mov	ax,OFFSET DGROUP:$SG25
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 17
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 18
$tru21:
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;k
	mov	ax,OFFSET DGROUP:$SG27
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 19
	push	WORD PTR 0
	call	FAR PTR _exit
	add	sp,2
; Line 20
	pop	si
	pop	di
	leave	
	ret	

_main	ENDP
SCOM0_TEXT	ENDS
END
