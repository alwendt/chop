;	Static Name Aliases
;
	TITLE   ifrelational

	.286p
	.287
IFRELATIONAL_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
IFRELATIONAL_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: IFRELATIONAL_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	_exit:FAR
EXTRN	__chkstk:FAR
_DATA      SEGMENT
$SG16	DB	'char polongers and unsigned char polongers ok',  0aH,  00H
	EVEN
$SG17	DB	'char polongers and unsigned char polongers not ok',  0aH,  00H
	EVEN
$SG27	DB	'longs and unsigned longs ok',  0aH,  00H
	EVEN
$SG28	DB	'longs and unsigned longs not ok',  0aH,  00H
	EVEN
$SG37	DB	'shorts and unsigned shorts ok',  0aH,  00H
	EVEN
$SG38	DB	'shorts and unsigned shorts not ok',  0aH,  00H
	EVEN
$SG47	DB	'chars and unsigned chars ok',  0aH,  00H
	EVEN
$SG48	DB	'chars and unsigned chars not ok',  0aH,  00H
	EVEN
$SG57	DB	'longs and unsigned longs ok',  0aH,  00H
	EVEN
$SG58	DB	'longs and unsigned longs not ok',  0aH,  00H
	EVEN
_DATA      ENDS
IFRELATIONAL_TEXT      SEGMENT
; Line 4
	PUBLIC	_polongers
_polongers	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,16
	call	FAR PTR __chkstk
;	i = -4
;	j = -8
; Line 5
	mov	WORD PTR [bp-4],1	;i
	mov	WORD PTR [bp-2],0
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
; Line 7
	mov	dx,ax
	cmp	[bp-4],ax	;i
	ja	$JCC34
	jmp	$I14
$JCC34:
	cmp	[bp-4],ax	;i
	jae	$JCC42
	jmp	$I14
$JCC42:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	dec	ax
	cmp	ax,[bp-8]	;j
	jae	$JCC57
	jmp	$I14
$JCC57:
	mov	ax,[bp-4]	;i
	dec	ax
	cmp	dx,[bp-6]
	je	$JCC69
	jmp	$I14
$JCC69:
	cmp	ax,[bp-8]	;j
	je	$JCC77
	jmp	$I14
$JCC77:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	cmp	[bp-2],dx
	jne	$L20001
	cmp	[bp-4],ax	;i
	jne	$JCC96
	jmp	$I14
$JCC96:
$L20001:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-8],ax	;j
	jb	$JCC110
	jmp	$I14
$JCC110:
	cmp	[bp-8],ax	;j
	jbe	$JCC118
	jmp	$I14
$JCC118:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	inc	ax
	cmp	ax,[bp-4]	;i
	jbe	$JCC133
	jmp	$I14
$JCC133:
	mov	ax,[bp-8]	;j
	inc	ax
	cmp	dx,[bp-2]
	je	$JCC145
	jmp	$I14
$JCC145:
	cmp	ax,[bp-4]	;i
	je	$JCC153
	jmp	$I14
$JCC153:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-6],dx
	jne	$L20002
	cmp	[bp-8],ax	;j
	jne	$JCC172
	jmp	$I14
$JCC172:
$L20002:
;	k = -12
;	l = -16
; Line 9
	mov	WORD PTR [bp-12],1	;k
	mov	WORD PTR [bp-10],0
	sub	ax,ax
	mov	[bp-14],ax
	mov	[bp-16],ax	;l
; Line 11
	mov	dx,ax
	cmp	[bp-12],ax	;k
	jbe	$I14
	cmp	[bp-12],ax	;k
	jb	$I14
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	dec	ax
	cmp	ax,[bp-16]	;l
	jb	$I14
	mov	ax,[bp-12]	;k
	dec	ax
	cmp	dx,[bp-14]
	jne	$I14
	cmp	ax,[bp-16]	;l
	jne	$I14
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	cmp	[bp-10],dx
	jne	$L20003
	cmp	[bp-12],ax	;k
	je	$I14
$L20003:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-16],ax	;l
	jae	$I14
	cmp	[bp-16],ax	;l
	ja	$I14
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	inc	ax
	cmp	ax,[bp-12]	;k
	ja	$I14
	mov	ax,[bp-16]	;l
	inc	ax
	cmp	dx,[bp-10]
	jne	$I14
	cmp	ax,[bp-12]	;k
	jne	$I14
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-14],dx
	jne	$L20004
	cmp	[bp-16],ax	;l
	je	$I14
$L20004:
; Line 13
	mov	ax,OFFSET DGROUP:$SG16
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 14
	jmp	SHORT $EX8
$I14:
; Line 17
	mov	ax,OFFSET DGROUP:$SG17
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 18
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 19
$EX8:
	leave	
	ret	

_polongers	ENDP
; Line 21
	PUBLIC	_longs
_longs	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,16
	call	FAR PTR __chkstk
;	i = -4
;	j = -8
; Line 22
	mov	WORD PTR [bp-4],1	;i
	mov	WORD PTR [bp-2],0
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
; Line 24
	mov	dx,ax
	cmp	[bp-2],dx
	jge	$JCC381
	jmp	$I26
$JCC381:
	jg	$L20005
	cmp	[bp-4],ax	;i
	ja	$JCC391
	jmp	$I26
$JCC391:
$L20005:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	cmp	[bp-2],dx
	jge	$JCC405
	jmp	$I26
$JCC405:
	jg	$L20006
	cmp	[bp-4],ax	;i
	jae	$JCC415
	jmp	$I26
$JCC415:
$L20006:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-6]
	jge	$JCC435
	jmp	$I26
$JCC435:
	jg	$L20007
	cmp	ax,[bp-8]	;j
	jae	$JCC445
	jmp	$I26
$JCC445:
$L20007:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-6]
	je	$JCC465
	jmp	$I26
$JCC465:
	cmp	ax,[bp-8]	;j
	je	$JCC473
	jmp	$I26
$JCC473:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	cmp	[bp-2],dx
	jne	$L20008
	cmp	[bp-4],ax	;i
	jne	$JCC492
	jmp	$I26
$JCC492:
$L20008:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-6],dx
	jle	$JCC506
	jmp	$I26
$JCC506:
	jl	$L20009
	cmp	[bp-8],ax	;j
	jb	$JCC516
	jmp	$I26
$JCC516:
$L20009:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-6],dx
	jle	$JCC530
	jmp	$I26
$JCC530:
	jl	$L20010
	cmp	[bp-8],ax	;j
	jbe	$JCC540
	jmp	$I26
$JCC540:
$L20010:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-2]
	jle	$JCC560
	jmp	$I26
$JCC560:
	jl	$L20011
	cmp	ax,[bp-4]	;i
	jbe	$JCC570
	jmp	$I26
$JCC570:
$L20011:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-2]
	je	$JCC590
	jmp	$I26
$JCC590:
	cmp	ax,[bp-4]	;i
	je	$JCC598
	jmp	$I26
$JCC598:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-6],dx
	jne	$L20012
	cmp	[bp-8],ax	;j
	jne	$JCC617
	jmp	$I26
$JCC617:
$L20012:
;	k = -12
;	l = -16
; Line 26
	mov	WORD PTR [bp-12],1	;k
	mov	WORD PTR [bp-10],0
	sub	ax,ax
	mov	[bp-14],ax
	mov	[bp-16],ax	;l
; Line 28
	mov	dx,ax
	cmp	[bp-10],dx
	jae	$JCC645
	jmp	$I26
$JCC645:
	ja	$L20013
	cmp	[bp-12],ax	;k
	ja	$JCC655
	jmp	$I26
$JCC655:
$L20013:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	cmp	[bp-10],dx
	jae	$JCC669
	jmp	$I26
$JCC669:
	ja	$L20014
	cmp	[bp-12],ax	;k
	jae	$JCC679
	jmp	$I26
$JCC679:
$L20014:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-14]
	jae	$JCC699
	jmp	$I26
$JCC699:
	ja	$L20015
	cmp	ax,[bp-16]	;l
	jae	$JCC709
	jmp	$I26
$JCC709:
$L20015:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-14]
	je	$JCC729
	jmp	$I26
$JCC729:
	cmp	ax,[bp-16]	;l
	je	$JCC737
	jmp	$I26
$JCC737:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	cmp	[bp-10],dx
	jne	$L20016
	cmp	[bp-12],ax	;k
	je	$I26
$L20016:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-14],dx
	ja	$I26
	jb	$L20017
	cmp	[bp-16],ax	;l
	jae	$I26
$L20017:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-14],dx
	ja	$I26
	jb	$L20018
	cmp	[bp-16],ax	;l
	ja	$I26
$L20018:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-10]
	ja	$I26
	jb	$L20019
	cmp	ax,[bp-12]	;k
	ja	$I26
$L20019:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-10]
	jne	$I26
	cmp	ax,[bp-12]	;k
	jne	$I26
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-14],dx
	jne	$L20020
	cmp	[bp-16],ax	;l
	je	$I26
$L20020:
; Line 30
	mov	ax,OFFSET DGROUP:$SG27
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 31
	call	FAR PTR _polongers
; Line 32
	jmp	SHORT $EX20
$I26:
; Line 35
	mov	ax,OFFSET DGROUP:$SG28
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 36
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 37
$EX20:
	leave	
	ret	

_longs	ENDP
; Line 39
	PUBLIC	_shorts
_shorts	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
;	i = -2
;	j = -4
; Line 40
	mov	WORD PTR [bp-2],1	;i
	mov	WORD PTR [bp-4],0	;j
; Line 42
	mov	ax,[bp-4]	;j
	cmp	[bp-2],ax	;i
	jg	$JCC928
	jmp	$I36
$JCC928:
	cmp	[bp-2],ax	;i
	jge	$JCC936
	jmp	$I36
$JCC936:
	mov	ax,[bp-2]	;i
	dec	ax
	cmp	ax,[bp-4]	;j
	jge	$JCC948
	jmp	$I36
$JCC948:
	mov	ax,[bp-2]	;i
	dec	ax
	cmp	ax,[bp-4]	;j
	je	$JCC960
	jmp	$I36
$JCC960:
	mov	ax,[bp-4]	;j
	cmp	[bp-2],ax	;i
	jne	$JCC971
	jmp	$I36
$JCC971:
	mov	ax,[bp-2]	;i
	cmp	[bp-4],ax	;j
	jl	$JCC982
	jmp	$I36
$JCC982:
	cmp	[bp-4],ax	;j
	jle	$JCC990
	jmp	$I36
$JCC990:
	mov	ax,[bp-4]	;j
	inc	ax
	cmp	ax,[bp-2]	;i
	jg	$I36
	mov	ax,[bp-4]	;j
	inc	ax
	cmp	ax,[bp-2]	;i
	jne	$I36
	mov	ax,[bp-2]	;i
	cmp	[bp-4],ax	;j
	je	$I36
;	k = -6
;	l = -8
; Line 44
	mov	WORD PTR [bp-6],1	;k
	mov	WORD PTR [bp-8],0	;l
; Line 46
	mov	ax,[bp-8]	;l
	cmp	[bp-6],ax	;k
	jbe	$I36
	cmp	[bp-6],ax	;k
	jb	$I36
	mov	ax,[bp-6]	;k
	dec	ax
	cmp	ax,[bp-8]	;l
	jb	$I36
	mov	ax,[bp-6]	;k
	dec	ax
	cmp	ax,[bp-8]	;l
	jne	$I36
	mov	ax,[bp-8]	;l
	cmp	[bp-6],ax	;k
	je	$I36
	mov	ax,[bp-6]	;k
	cmp	[bp-8],ax	;l
	jae	$I36
	cmp	[bp-8],ax	;l
	ja	$I36
	mov	ax,[bp-8]	;l
	inc	ax
	cmp	ax,[bp-6]	;k
	ja	$I36
	mov	ax,[bp-8]	;l
	inc	ax
	cmp	ax,[bp-6]	;k
	jne	$I36
	mov	ax,[bp-6]	;k
	cmp	[bp-8],ax	;l
	je	$I36
; Line 48
	mov	ax,OFFSET DGROUP:$SG37
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 49
	call	FAR PTR _longs
; Line 50
	jmp	SHORT $EX30
$I36:
; Line 53
	mov	ax,OFFSET DGROUP:$SG38
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 54
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 55
$EX30:
	leave	
	ret	

_shorts	ENDP
; Line 57
	PUBLIC	_chars
_chars	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
;	i = -2
;	j = -4
; Line 58
	mov	BYTE PTR [bp-2],1	;i
	mov	BYTE PTR [bp-4],0	;j
; Line 60
	mov	al,[bp-4]	;j
	cmp	[bp-2],al	;i
	jg	$JCC1179
	jmp	$I46
$JCC1179:
	cmp	[bp-2],al	;i
	jge	$JCC1187
	jmp	$I46
$JCC1187:
	mov	al,[bp-2]	;i
	cbw	
	dec	ax
	mov	cx,ax
	mov	al,[bp-4]	;j
	cbw	
	cmp	cx,ax
	jge	$JCC1205
	jmp	$I46
$JCC1205:
	mov	al,[bp-2]	;i
	cbw	
	dec	ax
	mov	cx,ax
	mov	al,[bp-4]	;j
	cbw	
	cmp	cx,ax
	je	$JCC1223
	jmp	$I46
$JCC1223:
	cmp	[bp-2],al	;i
	jne	$JCC1231
	jmp	$I46
$JCC1231:
	mov	al,[bp-2]	;i
	cmp	[bp-4],al	;j
	jl	$JCC1242
	jmp	$I46
$JCC1242:
	cmp	[bp-4],al	;j
	jle	$JCC1250
	jmp	$I46
$JCC1250:
	mov	al,[bp-4]	;j
	cbw	
	inc	ax
	mov	cx,ax
	mov	al,[bp-2]	;i
	cbw	
	cmp	cx,ax
	jle	$JCC1268
	jmp	$I46
$JCC1268:
	mov	al,[bp-4]	;j
	cbw	
	inc	ax
	mov	cx,ax
	mov	al,[bp-2]	;i
	cbw	
	cmp	cx,ax
	jne	$I46
	cmp	[bp-4],al	;j
	je	$I46
;	k = -6
;	l = -8
; Line 62
	mov	BYTE PTR [bp-6],1	;k
	mov	BYTE PTR [bp-8],0	;l
; Line 64
	mov	al,[bp-8]	;l
	cmp	[bp-6],al	;k
	jbe	$I46
	cmp	[bp-6],al	;k
	jb	$I46
	mov	al,[bp-6]	;k
	sub	ah,ah
	dec	ax
	mov	cl,[bp-8]	;l
	sub	ch,ch
	cmp	ax,cx
	jb	$I46
	mov	al,[bp-6]	;k
	sub	ah,ah
	dec	ax
	cmp	ax,cx
	jne	$I46
	mov	al,cl
	cmp	[bp-6],al	;k
	je	$I46
	mov	al,[bp-6]	;k
	cmp	cl,al
	jae	$I46
	cmp	cl,al
	ja	$I46
	mov	al,cl
	sub	ah,ah
	inc	ax
	mov	cl,[bp-6]	;k
	cmp	ax,cx
	ja	$I46
	mov	al,[bp-8]	;l
	sub	ah,ah
	inc	ax
	cmp	ax,cx
	jne	$I46
	mov	al,cl
	cmp	[bp-8],al	;l
	je	$I46
; Line 66
	mov	ax,OFFSET DGROUP:$SG47
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 67
	jmp	SHORT $EX40
$I46:
; Line 70
	mov	ax,OFFSET DGROUP:$SG48
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 71
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 72
$EX40:
	leave	
	ret	

_chars	ENDP
; Line 74
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,16
	call	FAR PTR __chkstk
;	i = -4
;	j = -8
; Line 75
	mov	WORD PTR [bp-4],1	;i
	mov	WORD PTR [bp-2],0
	sub	ax,ax
	mov	[bp-6],ax
	mov	[bp-8],ax	;j
; Line 77
	mov	dx,ax
	cmp	[bp-2],dx
	jge	$JCC1460
	jmp	$I56
$JCC1460:
	jg	$L20021
	cmp	[bp-4],ax	;i
	ja	$JCC1470
	jmp	$I56
$JCC1470:
$L20021:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	cmp	[bp-2],dx
	jge	$JCC1484
	jmp	$I56
$JCC1484:
	jg	$L20022
	cmp	[bp-4],ax	;i
	jae	$JCC1494
	jmp	$I56
$JCC1494:
$L20022:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-6]
	jge	$JCC1514
	jmp	$I56
$JCC1514:
	jg	$L20023
	cmp	ax,[bp-8]	;j
	jae	$JCC1524
	jmp	$I56
$JCC1524:
$L20023:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-6]
	je	$JCC1544
	jmp	$I56
$JCC1544:
	cmp	ax,[bp-8]	;j
	je	$JCC1552
	jmp	$I56
$JCC1552:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	cmp	[bp-2],dx
	jne	$L20024
	cmp	[bp-4],ax	;i
	jne	$JCC1571
	jmp	$I56
$JCC1571:
$L20024:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-6],dx
	jle	$JCC1585
	jmp	$I56
$JCC1585:
	jl	$L20025
	cmp	[bp-8],ax	;j
	jb	$JCC1595
	jmp	$I56
$JCC1595:
$L20025:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-6],dx
	jle	$JCC1609
	jmp	$I56
$JCC1609:
	jl	$L20026
	cmp	[bp-8],ax	;j
	jbe	$JCC1619
	jmp	$I56
$JCC1619:
$L20026:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-2]
	jle	$JCC1639
	jmp	$I56
$JCC1639:
	jl	$L20027
	cmp	ax,[bp-4]	;i
	jbe	$JCC1649
	jmp	$I56
$JCC1649:
$L20027:
	mov	ax,[bp-8]	;j
	mov	dx,[bp-6]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-2]
	je	$JCC1669
	jmp	$I56
$JCC1669:
	cmp	ax,[bp-4]	;i
	je	$JCC1677
	jmp	$I56
$JCC1677:
	mov	ax,[bp-4]	;i
	mov	dx,[bp-2]
	cmp	[bp-6],dx
	jne	$L20028
	cmp	[bp-8],ax	;j
	jne	$JCC1696
	jmp	$I56
$JCC1696:
$L20028:
;	k = -12
;	l = -16
; Line 79
	mov	WORD PTR [bp-12],1	;k
	mov	WORD PTR [bp-10],0
	sub	ax,ax
	mov	[bp-14],ax
	mov	[bp-16],ax	;l
; Line 81
	mov	dx,ax
	cmp	[bp-10],dx
	jae	$JCC1724
	jmp	$I56
$JCC1724:
	ja	$L20029
	cmp	[bp-12],ax	;k
	ja	$JCC1734
	jmp	$I56
$JCC1734:
$L20029:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	cmp	[bp-10],dx
	jae	$JCC1748
	jmp	$I56
$JCC1748:
	ja	$L20030
	cmp	[bp-12],ax	;k
	jae	$JCC1758
	jmp	$I56
$JCC1758:
$L20030:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-14]
	jae	$JCC1778
	jmp	$I56
$JCC1778:
	ja	$L20031
	cmp	ax,[bp-16]	;l
	jae	$JCC1788
	jmp	$I56
$JCC1788:
$L20031:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	sub	ax,1
	sbb	dx,0
	cmp	dx,[bp-14]
	je	$JCC1808
	jmp	$I56
$JCC1808:
	cmp	ax,[bp-16]	;l
	je	$JCC1816
	jmp	$I56
$JCC1816:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	cmp	[bp-10],dx
	jne	$L20032
	cmp	[bp-12],ax	;k
	je	$I56
$L20032:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-14],dx
	ja	$I56
	jb	$L20033
	cmp	[bp-16],ax	;l
	jae	$I56
$L20033:
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-14],dx
	ja	$I56
	jb	$L20034
	cmp	[bp-16],ax	;l
	ja	$I56
$L20034:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-10]
	ja	$I56
	jb	$L20035
	cmp	ax,[bp-12]	;k
	ja	$I56
$L20035:
	mov	ax,[bp-16]	;l
	mov	dx,[bp-14]
	add	ax,1
	adc	dx,0
	cmp	dx,[bp-10]
	jne	$I56
	cmp	ax,[bp-12]	;k
	jne	$I56
	mov	ax,[bp-12]	;k
	mov	dx,[bp-10]
	cmp	[bp-14],dx
	jne	$L20036
	cmp	[bp-16],ax	;l
	je	$I56
$L20036:
; Line 83
	mov	ax,OFFSET DGROUP:$SG57
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 84
	call	FAR PTR _chars
; Line 85
	push	WORD PTR 0
	call	FAR PTR _exit
	add	sp,2
; Line 87
$I56:
; Line 88
	mov	ax,OFFSET DGROUP:$SG58
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 89
	push	WORD PTR 1
	call	FAR PTR _exit
; Line 90
	leave	
	ret	

_main	ENDP
IFRELATIONAL_TEXT	ENDS
END
