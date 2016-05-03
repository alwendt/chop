;	Static Name Aliases
;
;	$S23_folding	EQU	folding
;	$S24_ignore	EQU	ignore
;	$S25_stats	EQU	stats
;	$S26_matchlen	EQU	matchlen
;	$S27_defvar	EQU	defvar
;	$S29_arg	EQU	arg
;	$S36_linebf	EQU	linebf
;	$S37_start	EQU	start
;	$S38_stop	EQU	stop
;	$S39_last	EQU	last
;	$S40_count	EQU	count
;	$S41_current	EQU	current
;	$S42_endfile	EQU	endfile
;	$S43_nb	EQU	nb
;	$S44_hashtable	EQU	hashtable
;	$S45_fptr	EQU	fptr
;	$S46_sync	EQU	sync
;	$S47_ichan	EQU	ichan
;	$S48_nocore	EQU	nocore
;	$S50_nocomp	EQU	nocomp
;	$S52_collct	EQU	collct
;	$S103_hashind	EQU	hashind
;	$S104_tmpstr	EQU	tmpstr
;	$S112_commentmode	EQU	commentmode
;	$S149_k	EQU	k
;	$S192_delim	EQU	delim
;	$S194_linex	EQU	linex
;	$S230_i	EQU	i
;	$S242_i	EQU	i
;	$S243_strikes	EQU	strikes
;	$S246_hashind	EQU	hashind
;	$S247_hash0	EQU	hash0
;	$S248_hash1	EQU	hash1
;	$S249_tb	EQU	tb
	TITLE   scom

	.286p
	.287
SCOM_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
SCOM_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: SCOM_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_atoi:FAR
EXTRN	_fopen:FAR
EXTRN	_malloc:FAR
EXTRN	_puts:FAR
EXTRN	__chkstk:FAR
EXTRN	_strcmp:FAR
EXTRN	_strlen:FAR
EXTRN	_strcpy:FAR
EXTRN	__lshl:FAR
EXTRN	_free:FAR
EXTRN	_fputs:FAR
EXTRN	_printf:FAR
EXTRN	_fprintf:FAR
EXTRN	_fgetc:FAR
EXTRN	_exit:FAR
EXTRN	__iob:BYTE
_DATA      SEGMENT
$SG49	DB	'Abort -- insufficient memory',  0aH,  00H
$SG51	DB	'Abort -- files differ too much',  0aH,  00H
$SG57	DB	'%s',  0aH,  00H
$SG118	DB	' /',  00H
	EVEN
$SG133	DB	' (End of file)',  0aH,  00H
$SG179	DB	'File ',  00H
$SG181	DB	' beginning to ',  00H
	EVEN
$SG184	DB	' line %d to ',  00H
	EVEN
$SG186	DB	'end',  0aH,  00H
	EVEN
$SG188	DB	'line %d',  0aH,  00H
	EVEN
$SG193	DB	'<><><><><><><><><><><><><><><><><><><>',  00H
	EVEN
$SG199	DB	'#ifndef %s',  0aH,  00H
$SG201	DB	'#ifdef %s',  0aH,  00H
	EVEN
$SG208	DB	'#else',  0aH,  00H
	EVEN
$SG214	DB	'#endif',  0aH,  00H
$SG270	DB	'Format: scom <flags> <file1> <file2>',  0aH,  00H
$SG271	DB	'flags: -f fold whitespace to single space',  0aH,  00H
	EVEN
$SG272	DB	09H, '-i ignore whitespace entirely',  0aH,  00H
$SG273	DB	09H, '-sN resynchronize at N equal lines',  0aH,  00H
	EVEN
$SG274	DB	09H, '-Dname output program with #defines',  0aH,  00H
$SG280	DB	'r',  00H
$SG282	DB	'can''t read %s',  0aH,  00H
	EVEN
$SG285	DB	'can''t allocate hash table',  0aH,  00H
	EVEN
$SG287	DB	'can''t allocate line buffer',  0aH,  00H
$SG288	DB	' (Beginning of file)',  0aH,  00H
$SG329	DB	'%5d  %5d',  0aH,  00H
$S23_folding	DB	00H
	EVEN
$S24_ignore	DB	00H
	EVEN
$S25_stats	DB	00H
	EVEN
$S26_matchlen	DW	03H
$S27_defvar	DD	0H
$S29_arg	DW	01H
$S36_linebf	DD	0H
$S37_start	DD	00H
	DD	00H
$S38_stop	DD	00H
	DD	00H
$S39_last	DD	00H
	DD	00H
$S40_count	DD	00H
	DD	00H
$S41_current	DD	00H
	DD	00H
$S42_endfile	DD	0ffffffffH
	DD	0ffffffffH
$S43_nb	DB	00H
	DB	00H
$S44_hashtable	DD	0H
$S46_sync	DB	01H
	EVEN
$S47_ichan	DD	0H
	ORG	$+4
$S48_nocore	DD	OFFSET DGROUP:$SG49
$S50_nocomp	DD	OFFSET DGROUP:$SG51
$S52_collct	DD	0H
$S192_delim	DD	OFFSET DGROUP:$SG193
_DATA      ENDS
_BSS      SEGMENT
$S194_linex	DW 02H DUP (?)
$S149_k	DW 02H DUP (?)
$S230_i	DW 02H DUP (?)
$S103_hashind	DW 02H DUP (?)
$S104_tmpstr	DW 02H DUP (?)
$S45_fptr	DW 04H DUP (?)
$S112_commentmode	DW 01H DUP (?)
$S242_i	DW 02H DUP (?)
$S243_strikes	DB 01H DUP (?)
	EVEN
$S246_hashind	DW 02H DUP (?)
$S247_hash0	DW 02H DUP (?)
$S248_hash1	DW 02H DUP (?)
$S249_tb	DW 02H DUP (?)
_BSS      ENDS
SCOM_TEXT      SEGMENT
;	s = 6
; Line 84
	PUBLIC	_newstr
_newstr	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	p = -4
; Line 87
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;s
	call	FAR PTR _strlen
	add	sp,4
	inc	ax
	push	ax
	call	FAR PTR _malloc
	add	sp,2
	mov	[bp-4],ax	;p
	mov	[bp-2],dx
; Line 88
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;s
	push	dx
	push	ax
	call	FAR PTR _strcpy
	add	sp,8
; Line 89
	mov	ax,[bp-4]	;p
	mov	dx,[bp-2]
	leave	
	ret	

_newstr	ENDP
;	msg = 6
; Line 125
	PUBLIC	_errkill
_errkill	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 127
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;msg
	mov	ax,OFFSET DGROUP:$SG57
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,12
; Line 128
	push	WORD PTR 0
	call	FAR PTR _exit
; Line 129
	leave	
	ret	

_errkill	ENDP
;	s = 6
;	result = 10
; Line 136
	PUBLIC	_fold
_fold	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,10
	call	FAR PTR __chkstk
;	c = -4
;	once = -6
;	t = -10
; Line 143
	mov	ax,[bp+10]	;result
	mov	dx,[bp+12]
	mov	[bp-10],ax	;t
	mov	[bp-8],dx
; Line 144
	or	ax,dx
	jne	$I66
	push	WORD PTR $S50_nocomp+2
	push	WORD PTR $S50_nocomp
	call	FAR PTR _errkill
	add	sp,4
; Line 146
$I66:
	cmp	$S23_folding,0
	jne	$I67
	cmp	$S24_ignore,0
	jne	$I67
	mov	ax,[bp+6]	;s
	mov	dx,[bp+8]
	inc	ax
	jmp	$EX62
$I67:
	cmp	$S24_ignore,0
	jne	$JCC183
	jmp	$I68
$JCC183:
; Line 150
	les	bx,[bp+6]	;s
	inc	WORD PTR [bp+6]	;s
	cmp	BYTE PTR es:[bx],47
	je	$F75
$D71:
; Line 152
	les	bx,[bp+6]	;s
	cmp	BYTE PTR es:[bx],47
	jne	$FB77
	cmp	BYTE PTR es:[bx+1],42
	jne	$FB77
; Line 154
	add	WORD PTR [bp+6],2	;s
; Line 155
$F75:
; Line 156
	les	bx,[bp+6]	;s
	cmp	BYTE PTR es:[bx],10
	jne	$I78
$FB77:
; Line 164
	les	bx,[bp+6]	;s
	inc	WORD PTR [bp+6]	;s
	mov	al,es:[bx]
	cbw	
	cwd	
	mov	[bp-4],ax	;c
	mov	[bp-2],dx
; Line 165
	or	dx,dx
	jne	$L20001
	cmp	ax,32
	je	$I80
$L20001:
	cmp	WORD PTR [bp-2],0
	jne	$L20002
	cmp	WORD PTR [bp-4],9	;c
	je	$I80
$L20002:
	les	bx,[bp-10]	;t
	inc	WORD PTR [bp-10]	;t
	mov	al,[bp-4]	;c
	mov	es:[bx],al
; Line 166
$I80:
	mov	ax,[bp-4]	;c
	or	ax,[bp-2]
	jne	$D71
; Line 169
	jmp	SHORT $I81
$I78:
	les	bx,[bp+6]	;s
	cmp	BYTE PTR es:[bx],42
	jne	$I79
	cmp	BYTE PTR es:[bx+1],47
	jne	$I79
; Line 158
	add	WORD PTR [bp+6],2	;s
; Line 159
	jmp	SHORT $FB77
$I79:
	inc	WORD PTR [bp+6]	;s
; Line 162
	jmp	SHORT $F75
$I68:
; Line 170
	mov	BYTE PTR [bp-6],0	;once
; Line 171
$D82:
; Line 172
	les	bx,[bp+6]	;s
	inc	WORD PTR [bp+6]	;s
	mov	al,es:[bx]
	cbw	
	cwd	
	mov	[bp-4],ax	;c
	mov	[bp-2],dx
; Line 173
	or	dx,dx
	jne	$L20003
	cmp	ax,32
	je	$I86
$L20003:
	cmp	WORD PTR [bp-2],0
	jne	$I85
	cmp	WORD PTR [bp-4],9	;c
	jne	$I85
$I86:
; Line 174
	cmp	BYTE PTR [bp-6],0	;once
	jne	$I88
; Line 175
	les	bx,[bp-10]	;t
	inc	WORD PTR [bp-10]	;t
	mov	BYTE PTR es:[bx],32
; Line 176
	inc	BYTE PTR [bp-6]	;once
; Line 179
	jmp	SHORT $I88
$I85:
; Line 180
	mov	BYTE PTR [bp-6],0	;once
; Line 181
	les	bx,[bp-10]	;t
	inc	WORD PTR [bp-10]	;t
	mov	al,[bp-4]	;c
	mov	es:[bx],al
; Line 182
$I88:
; Line 183
	mov	ax,[bp-4]	;c
	or	ax,[bp-2]
	jne	$D82
; Line 184
$I81:
; Line 186
	mov	ax,[bp+10]	;result
	mov	dx,[bp+12]
$EX62:
	leave	
	ret	

_fold	ENDP
;	line = 6
; Line 191
	PUBLIC	_hash
_hash	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,1032
	call	FAR PTR __chkstk
	push	si
;	result = -4
;	buffer = -1028
;	lptr = -1032
; Line 198
	lea	ax,[bp-1028]	;buffer
	push	ss
	push	ax
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;line
	call	FAR PTR _fold
	add	sp,8
	mov	[bp-1032],ax	;lptr
	mov	[bp-1030],dx
; Line 199
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;result
; Line 200
	jmp	SHORT $L20035
$WC95:
; Line 201
	mov	ax,[bp-4]	;result
	mov	dx,[bp-2]
	and	ax,1
	sub	dx,dx
	mov	cl,15
	call	FAR PTR __lshl
	mov	cx,[bp-4]	;result
	mov	bx,[bp-2]
	shr	bx,1
	rcr	cx,1
	xor	ax,cx
	xor	dx,bx
	les	bx,[bp-1032]	;lptr
	inc	WORD PTR [bp-1032]	;lptr
	mov	cx,ax
	mov	al,es:[bx]
	cbw	
	mov	bx,dx
	cwd	
	xor	cx,ax
	xor	bx,dx
	mov	[bp-4],cx	;result
	mov	[bp-2],bx
; Line 202
$L20035:
	les	bx,[bp-1032]	;lptr
	cmp	BYTE PTR es:[bx],0
	jne	$WC95
; Line 203
	mov	ax,[bp-4]	;result
	and	ah,127
	sub	dx,dx
	mov	cx,1279
	div	cx
	mov	[bp-4],dx	;result
	mov	WORD PTR [bp-2],0
; Line 204
	cmp	$S25_stats,0
	je	$I97
	mov	bx,dx
	shl	bx,2
	les	si,DWORD PTR $S52_collct
	add	WORD PTR es:[bx][si],1
	adc	WORD PTR es:[bx+2][si],0
; Line 205
$I97:
	mov	ax,[bp-4]	;result
	mov	dx,[bp-2]
	pop	si
	leave	
	ret	

_hash	ENDP
;	filex = 6
;	buff = 8
;	size = 12
; Line 211
	PUBLIC	_entline
_entline	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
	push	si
; Line 219
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S38_stop[bx]
	mov	dx,WORD PTR $S38_stop[bx+2]
	add	ax,1
	adc	dx,0
	and	ah,3
	sub	dx,dx
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	WORD PTR $S38_stop[bx],cx
	mov	WORD PTR $S38_stop[bx+2],dx
; Line 220
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S37_start[bx]
	mov	dx,WORD PTR $S37_start[bx+2]
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	cmp	WORD PTR $S38_stop[bx+2],dx
	jne	$I105
	cmp	WORD PTR $S38_stop[bx],cx
	jne	$I105
	push	WORD PTR $S50_nocomp+2
	push	WORD PTR $S50_nocomp
	call	FAR PTR _errkill
	add	sp,4
; Line 222
$I105:
	push	WORD PTR [bp+14]
	push	WORD PTR [bp+12]	;size
	call	FAR PTR _malloc
	add	sp,4
	mov	WORD PTR $S104_tmpstr,ax
	mov	WORD PTR $S104_tmpstr+2,dx
	or	ax,dx
	jne	$I106
	push	WORD PTR $S50_nocomp+2
	push	WORD PTR $S50_nocomp
	call	FAR PTR _errkill
	add	sp,4
; Line 223
$I106:
	push	WORD PTR [bp+10]
	push	WORD PTR [bp+8]	;buff
	push	WORD PTR $S104_tmpstr+2
	push	WORD PTR $S104_tmpstr
	call	FAR PTR _strcpy
	add	sp,8
; Line 224
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S38_stop[bx]
	mov	dx,WORD PTR $S38_stop[bx+2]
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	shl	ax,10
	mov	bx,dx
	cwd	
	add	cx,ax
	adc	bx,dx
	mov	WORD PTR $S103_hashind,cx
	mov	WORD PTR $S103_hashind+2,bx
; Line 225
	mov	al,[bp+6]	;filex
	cbw	
	shl	ax,10
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	bx,WORD PTR $S38_stop[bx]
	add	bx,cx
	shl	bx,2
	les	si,DWORD PTR $S36_linebf
	mov	ax,WORD PTR $S104_tmpstr
	mov	dx,WORD PTR $S104_tmpstr+2
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],dx
; Line 226
	pop	si
	leave	
	ret	

_entline	ENDP
;	filex = 6
;	linex = 10
; Line 233
	PUBLIC	_readaline
_readaline	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,1040
	call	FAR PTR __chkstk
	push	si
;	c = -4
;	buff = -1028
;	csize = -1032
;	f = -1036
;	lastcc = -1040
; Line 241
	mov	WORD PTR [bp-1040],10	;lastcc
	mov	WORD PTR [bp-1038],0
; Line 243
	mov	bx,[bp+6]	;filex
	shl	bx,2
	mov	ax,WORD PTR $S47_ichan[bx]
	mov	dx,WORD PTR $S47_ichan[bx+2]
	mov	[bp-1036],ax	;f
	mov	[bp-1034],dx
; Line 244
	mov	bx,[bp+6]	;filex
	shl	bx,2
	cmp	WORD PTR $S42_endfile[bx+2],-1
	je	$JCC908
	jmp	$EX110
$JCC908:
	cmp	WORD PTR $S42_endfile[bx],-1
	je	$JCC918
	jmp	$EX110
$JCC918:
	mov	bx,[bp+6]	;filex
	mov	al,BYTE PTR $S112_commentmode[bx]
	cbw	
	mov	bx,ax
	mov	al,BYTE PTR $SG118[bx]
	mov	[bp-1028],al	;buff
; Line 248
	mov	WORD PTR [bp-1032],1	;csize
	mov	WORD PTR [bp-1030],0
; Line 251
$F119:
; Line 252
	push	WORD PTR [bp-1034]
	push	WORD PTR [bp-1036]	;f
	call	FAR PTR _fgetc
	add	sp,4
	cwd	
	mov	[bp-4],ax	;c
	mov	[bp-2],dx
; Line 254
	or	dx,dx
	jne	$I123
	cmp	ax,42
	jne	$I123
; Line 255
	cmp	WORD PTR [bp-1038],0
	jne	$I131
	cmp	WORD PTR [bp-1040],47	;lastcc
	jne	$I131
	cmp	$S24_ignore,0
	je	$I131
	mov	bx,[bp+6]	;filex
	mov	BYTE PTR $S112_commentmode[bx],1
; Line 258
$I131:
	mov	ax,[bp-4]	;c
	mov	dx,[bp-2]
	mov	[bp-1040],ax	;lastcc
	mov	[bp-1038],dx
; Line 280
	mov	ax,[bp-1032]	;csize
	mov	dx,[bp-1030]
	add	WORD PTR [bp-1032],1	;csize
	adc	WORD PTR [bp-1030],0
	mov	si,ax
	mov	al,[bp-4]	;c
	mov	[bp-1028][si],al
; Line 281
	jmp	SHORT $F119
$I123:
	cmp	WORD PTR [bp-2],0
	jne	$I126
	cmp	WORD PTR [bp-4],47	;c
	jne	$I126
; Line 259
	cmp	WORD PTR [bp-1038],0
	jne	$I131
	cmp	WORD PTR [bp-1040],42	;lastcc
	jne	$I131
	cmp	$S24_ignore,0
	je	$I131
	mov	bx,[bp+6]	;filex
	mov	BYTE PTR $S112_commentmode[bx],0
; Line 262
	jmp	SHORT $I131
$I126:
	cmp	WORD PTR [bp-2],0
	jne	$I129
	cmp	WORD PTR [bp-4],10	;c
	jne	$I129
; Line 263
	mov	ax,[bp-1032]	;csize
	mov	dx,[bp-1030]
	add	WORD PTR [bp-1032],1	;csize
	adc	WORD PTR [bp-1030],0
	mov	si,ax
	mov	al,[bp-4]	;c
	mov	[bp-1028][si],al
; Line 264
	mov	ax,[bp-1032]	;csize
	mov	dx,[bp-1030]
	add	WORD PTR [bp-1032],1	;csize
	adc	WORD PTR [bp-1030],0
	mov	si,ax
	mov	BYTE PTR [bp-1028][si],0
; Line 265
	push	WORD PTR [bp-1030]
	push	WORD PTR [bp-1032]	;csize
	lea	ax,[bp-1028]	;buff
	push	ss
	push	ax
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;filex
	call	FAR PTR _entline
	add	sp,12
; Line 266
	jmp	$EX110
$I129:
	cmp	WORD PTR [bp-2],-1
	je	$JCC1199
	jmp	$I131
$JCC1199:
	cmp	WORD PTR [bp-4],-1	;c
	je	$JCC1208
	jmp	$I131
$JCC1208:
; Line 270
	cmp	WORD PTR [bp-1030],0
	jb	$I132
	ja	$L20006
	cmp	WORD PTR [bp-1032],1	;csize
	jbe	$I132
$L20006:
; Line 271
	mov	ax,[bp-1032]	;csize
	mov	dx,[bp-1030]
	add	WORD PTR [bp-1032],1	;csize
	adc	WORD PTR [bp-1030],0
	mov	si,ax
	mov	BYTE PTR [bp-1028][si],0
; Line 272
	add	WORD PTR [bp+10],1	;linex
	adc	WORD PTR [bp+12],0
; Line 273
	push	WORD PTR [bp-1030]
	push	WORD PTR [bp-1032]	;csize
	lea	ax,[bp-1028]	;buff
	push	ss
	push	ax
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;filex
	call	FAR PTR _entline
	add	sp,12
; Line 275
$I132:
	push	WORD PTR 16
	mov	ax,OFFSET DGROUP:$SG133
	push	ds
	push	ax
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;filex
	call	FAR PTR _entline
	add	sp,10
; Line 276
	mov	bx,[bp+6]	;filex
	shl	bx,2
	mov	ax,[bp+10]	;linex
	mov	dx,[bp+12]
	mov	WORD PTR $S42_endfile[bx],ax
	mov	WORD PTR $S42_endfile[bx+2],dx
; Line 277
$EX110:
	pop	si
	leave	
	ret	

_readaline	ENDP
;	filex = 6
;	linex = 8
; Line 286
	PUBLIC	_lines
_lines	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
	push	si
;	s = -4
; Line 290
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	cbw	
	mov	si,ax
	shl	si,2
	mov	ax,WORD PTR $S38_stop[si]
	mov	dx,WORD PTR $S38_stop[si+2]
	sub	ax,WORD PTR $S37_start[bx]
	sbb	dx,WORD PTR $S37_start[bx+2]
	and	ah,3
	sub	dx,dx
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	add	cx,WORD PTR $S39_last[bx]
	adc	dx,WORD PTR $S39_last[bx+2]
	cmp	dx,[bp+10]
	ja	$I139
	jb	$L20008
	cmp	cx,[bp+8]	;linex
	jae	$I139
$L20008:
; Line 291
	push	WORD PTR [bp+10]
	push	WORD PTR [bp+8]	;linex
	mov	al,[bp+6]	;filex
	cbw	
	push	ax
	call	FAR PTR _readaline
	add	sp,6
; Line 297
$I139:
; Line 298
	mov	al,[bp+6]	;filex
	cbw	
	shl	ax,10
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S39_last[bx]
	mov	dx,WORD PTR $S39_last[bx+2]
	mov	bx,ax
	mov	dx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S37_start[bx]
	mov	[bp-8],ax
	mov	ax,WORD PTR $S37_start[bx+2]
	mov	[bp-6],ax
	mov	bx,[bp+8]	;linex
	sub	bx,dx
	add	bx,[bp-8]
	and	bh,3
	add	bx,cx
	shl	bx,2
	les	si,DWORD PTR $S36_linebf
	mov	ax,es:[bx][si]
	mov	dx,es:[bx+2][si]
	pop	si
	leave	
	ret	

_lines	ENDP
; Line 304
	PUBLIC	_match
_match	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2064
	call	FAR PTR __chkstk
	push	di
	push	si
;	t = -2
;	bf0 = -1026
;	tmp = -1030
;	j = -1032
;	bf1 = -2056
;	s0 = -2060
;	s1 = -2064
; Line 312
	cmp	$S46_sync,0
	je	$I150
	mov	WORD PTR [bp-1032],1	;j
	jmp	SHORT $I151
$I150:
	mov	ax,$S26_matchlen
	mov	[bp-1032],ax	;j
$I151:
; Line 313
	sub	ax,ax
	mov	WORD PTR $S149_k+2,ax
	mov	WORD PTR $S149_k,ax
; Line 315
	jmp	$SB168
$WC152:
; Line 317
	mov	BYTE PTR $S43_nb,0
; Line 318
$red0154:
; Line 319
	mov	ax,WORD PTR $S40_count
	mov	dx,WORD PTR $S40_count+2
	add	ax,WORD PTR $S149_k
	adc	dx,WORD PTR $S149_k+2
	mov	[bp-1030],ax	;tmp
	mov	[bp-1028],dx
; Line 320
	mov	al,BYTE PTR $S43_nb
	cbw	
	cwd	
	add	[bp-1030],ax	;tmp
	adc	[bp-1028],dx
; Line 321
	lea	ax,[bp-1026]	;bf0
	push	ss
	push	ax
	push	WORD PTR [bp-1028]
	push	WORD PTR [bp-1030]	;tmp
	push	WORD PTR 0
	call	FAR PTR _lines
	add	sp,6
	push	dx
	push	ax
	call	FAR PTR _fold
	add	sp,8
	mov	[bp-2060],ax	;s0
	mov	[bp-2058],dx
; Line 322
	les	bx,[bp-2060]	;s0
	cmp	BYTE PTR es:[bx],10
	jne	$I155
	cmp	$S24_ignore,0
	je	$I155
; Line 323
	mov	ax,$S26_matchlen
	cmp	[bp-1032],ax	;j
	jne	$I156
	mov	ax,WORD PTR $S27_defvar
	or	ax,WORD PTR $S27_defvar+2
	jne	$I156
$fal157:
	mov	$S46_sync,0
	sub	ax,ax
	jmp	$EX141
$I156:
	inc	BYTE PTR $S43_nb
; Line 325
	jmp	$red0154
$I155:
	mov	BYTE PTR $S43_nb+1,0
; Line 329
	jmp	SHORT $L20036
$red1158:
; Line 330
	cmp	$S24_ignore,0
	je	$I159
; Line 332
	mov	ax,$S26_matchlen
	cmp	[bp-1032],ax	;j
	jne	$I160
	mov	ax,WORD PTR $S27_defvar
	or	ax,WORD PTR $S27_defvar+2
	je	$fal157
$I160:
	inc	BYTE PTR $S43_nb+1
; Line 334
$L20036:
	lea	ax,[bp-2056]	;bf1
	push	ss
	push	ax
	mov	al,BYTE PTR $S43_nb+1
	cbw	
	cwd	
	mov	cx,WORD PTR $S40_count+4
	mov	bx,WORD PTR $S40_count+6
	add	cx,ax
	adc	bx,dx
	add	cx,WORD PTR $S149_k
	adc	bx,WORD PTR $S149_k+2
	push	bx
	push	cx
	push	WORD PTR 1
	call	FAR PTR _lines
	add	sp,6
	push	dx
	push	ax
	call	FAR PTR _fold
	add	sp,8
	mov	[bp-2064],ax	;s1
	mov	[bp-2062],dx
; Line 331
	les	bx,[bp-2064]	;s1
	cmp	BYTE PTR es:[bx],10
	je	$red1158
$I159:
	push	WORD PTR [bp-2062]
	push	WORD PTR [bp-2064]	;s1
	push	WORD PTR [bp-2058]
	push	WORD PTR [bp-2060]	;s0
	call	FAR PTR _strcmp
	add	sp,8
	or	ax,ax
	je	$JCC1829
	jmp	$fal157
$JCC1829:
	les	bx,[bp-2060]	;s0
	cmp	BYTE PTR es:[bx],10
	jne	$I164
	mov	ax,WORD PTR $S27_defvar
	or	ax,WORD PTR $S27_defvar+2
	je	$I163
$I164:
	dec	WORD PTR [bp-1032]	;j
; Line 347
	jmp	SHORT $I166
$I163:
	mov	ax,$S26_matchlen
	cmp	[bp-1032],ax	;j
	jne	$I166
	mov	ax,WORD PTR $S27_defvar
	or	ax,WORD PTR $S27_defvar+2
	jne	$JCC1875
	jmp	$fal157
$JCC1875:
$I166:
; Line 352
	mov	al,BYTE PTR $S43_nb+1
	cbw	
	cwd	
	mov	cx,WORD PTR $S40_count+4
	mov	bx,WORD PTR $S40_count+6
	add	cx,ax
	adc	bx,dx
	add	cx,WORD PTR $S149_k
	adc	bx,WORD PTR $S149_k+2
	cmp	bx,WORD PTR $S42_endfile+6
	jne	$L20011
	cmp	cx,WORD PTR $S42_endfile+4
	jne	$L20011
	mov	ax,1
	jmp	SHORT $L20012
$L20011:
	sub	ax,ax
$L20012:
	mov	cx,ax
	mov	al,BYTE PTR $S43_nb
	cbw	
	cwd	
	mov	bx,WORD PTR $S40_count
	mov	si,WORD PTR $S40_count+2
	add	bx,ax
	adc	si,dx
	add	bx,WORD PTR $S149_k
	adc	si,WORD PTR $S149_k+2
	mov	di,cx
	cmp	si,WORD PTR $S42_endfile+2
	jne	$L20009
	cmp	bx,WORD PTR $S42_endfile
	jne	$L20009
	mov	ax,1
	jmp	SHORT $L20010
$L20009:
	sub	ax,ax
$L20010:
	add	ax,di
	or	ax,ax
	je	$SC171
	cmp	ax,1
	jne	$JCC1981
	jmp	$fal157
$JCC1981:
	cmp	ax,2
	je	$tru174
	jmp	SHORT $SB168
$SC171:
	add	WORD PTR $S149_k,1
	adc	WORD PTR $S149_k+2,0
$SB168:
; Line 358
	cmp	WORD PTR [bp-1032],0	;j
	je	$JCC2008
	jmp	$WC152
$JCC2008:
; Line 360
$tru174:
	mov	ax,1
$EX141:
	pop	si
	pop	di
	leave	
	ret	

_match	ENDP
;	filex = 6
; Line 366
	PUBLIC	_id
_id	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 368
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG179
	push	ds
	push	ax
	call	FAR PTR _fputs
	add	sp,8
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	push	WORD PTR $S45_fptr[bx+2]
	push	WORD PTR $S45_fptr[bx]
	call	FAR PTR _fputs
	add	sp,8
; Line 369
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S39_last[bx]
	or	ax,WORD PTR $S39_last[bx+2]
	jne	$I180
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG181
	push	ds
	push	ax
	call	FAR PTR _fputs
	jmp	SHORT $L20038
$I180:
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	push	WORD PTR $S39_last[bx+2]
	push	WORD PTR $S39_last[bx]
	mov	ax,OFFSET DGROUP:$SG184
	push	ds
	push	ax
	call	FAR PTR _printf
$L20038:
	add	sp,8
; Line 371
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S42_endfile[bx]
	mov	dx,WORD PTR $S42_endfile[bx+2]
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	cmp	WORD PTR $S40_count[bx+2],dx
	jne	$I185
	cmp	WORD PTR $S40_count[bx],cx
	jne	$I185
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG186
	push	ds
	push	ax
	call	FAR PTR _fputs
	jmp	SHORT $L20039
$I185:
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	push	WORD PTR $S40_count[bx+2]
	push	WORD PTR $S40_count[bx]
	mov	ax,OFFSET DGROUP:$SG188
	push	ds
	push	ax
	call	FAR PTR _printf
$L20039:
; Line 373
	leave	
	ret	

_id	ENDP
; Line 376
	PUBLIC	_runout
_runout	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2
	call	FAR PTR __chkstk
	push	si
;	filex = -2
; Line 377
	mov	BYTE PTR [bp-2],0	;filex
; Line 380
	mov	ax,WORD PTR $S27_defvar
	or	ax,WORD PTR $S27_defvar+2
	jne	$JCC2265
	jmp	$I195
$JCC2265:
; Line 386
	mov	ax,WORD PTR $S39_last
	mov	dx,WORD PTR $S39_last+2
	add	ax,1
	adc	dx,0
	cmp	dx,WORD PTR $S40_count+2
	jg	$L20015
	jl	$L20013
	cmp	ax,WORD PTR $S40_count
	jae	$L20015
$L20013:
	mov	ax,WORD PTR $S40_count
	mov	dx,WORD PTR $S40_count+2
	sub	ax,WORD PTR $S39_last
	sbb	dx,WORD PTR $S39_last+2
	mov	cx,WORD PTR $S40_count+4
	mov	bx,WORD PTR $S40_count+6
	sub	cx,WORD PTR $S39_last+4
	sbb	bx,WORD PTR $S39_last+6
	cmp	dx,bx
	jl	$I196
	jg	$L20014
	cmp	ax,cx
	jbe	$I196
$L20014:
	mov	ax,WORD PTR $S39_last+4
	mov	dx,WORD PTR $S39_last+6
	add	ax,1
	adc	dx,0
	cmp	dx,WORD PTR $S40_count+6
	jg	$I196
	jl	$L20015
	cmp	ax,WORD PTR $S40_count+4
	jae	$I196
$L20015:
; Line 387
	mov	BYTE PTR [bp-2],1	;filex
; Line 389
$I196:
	cmp	BYTE PTR [bp-2],0	;filex
	je	$I198
	push	WORD PTR $S27_defvar+2
	push	WORD PTR $S27_defvar
	mov	ax,OFFSET DGROUP:$SG199
	jmp	SHORT $L20040
$I198:
	push	WORD PTR $S27_defvar+2
	push	WORD PTR $S27_defvar
	mov	ax,OFFSET DGROUP:$SG201
$L20040:
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 392
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S39_last[bx]
	mov	dx,WORD PTR $S39_last[bx+2]
	add	ax,1
	adc	dx,0
	mov	WORD PTR $S194_linex,ax
	mov	WORD PTR $S194_linex+2,dx
$F202:
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S194_linex
	mov	dx,WORD PTR $S194_linex+2
	cmp	WORD PTR $S40_count[bx+2],dx
	jl	$FB204
	jg	$F205
	cmp	WORD PTR $S40_count[bx],ax
	jbe	$FB204
$F205:
; Line 393
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S194_linex
	mov	dx,WORD PTR $S194_linex+2
	cmp	WORD PTR $S42_endfile[bx+2],dx
	jne	$L20017
	cmp	WORD PTR $S42_endfile[bx],ax
	je	$FC203
$L20017:
; Line 394
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR $S194_linex+2
	push	WORD PTR $S194_linex
	mov	al,[bp-2]	;filex
	cbw	
	push	ax
	call	FAR PTR _lines
	add	sp,6
	inc	ax
	push	dx
	push	ax
	call	FAR PTR _fputs
	add	sp,8
; Line 396
$FC203:
	add	WORD PTR $S194_linex,1
	adc	WORD PTR $S194_linex+2,0
	jmp	SHORT $F202
$FB204:
	mov	al,1
	sub	al,[bp-2]	;filex
	mov	[bp-2],al	;filex
; Line 399
	cbw	
	mov	bx,ax
	shl	bx,2
	cbw	
	mov	si,ax
	shl	si,2
	mov	ax,WORD PTR $S39_last[si]
	mov	dx,WORD PTR $S39_last[si+2]
	add	ax,1
	adc	dx,0
	cmp	dx,WORD PTR $S40_count[bx+2]
	jle	$JCC2587
	jmp	$FB211
$JCC2587:
	jl	$L20018
	cmp	ax,WORD PTR $S40_count[bx]
	jb	$JCC2598
	jmp	$FB211
$JCC2598:
$L20018:
; Line 400
	mov	ax,OFFSET DGROUP:$SG208
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,4
; Line 401
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S39_last[bx]
	mov	dx,WORD PTR $S39_last[bx+2]
	add	ax,1
	adc	dx,0
	mov	WORD PTR $S194_linex,ax
	mov	WORD PTR $S194_linex+2,dx
$F209:
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S194_linex
	mov	dx,WORD PTR $S194_linex+2
	cmp	WORD PTR $S40_count[bx+2],dx
	jl	$FB211
	jg	$F212
	cmp	WORD PTR $S40_count[bx],ax
	jbe	$FB211
$F212:
; Line 402
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S194_linex
	mov	dx,WORD PTR $S194_linex+2
	cmp	WORD PTR $S42_endfile[bx+2],dx
	jne	$L20020
	cmp	WORD PTR $S42_endfile[bx],ax
	je	$FC210
$L20020:
; Line 403
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR $S194_linex+2
	push	WORD PTR $S194_linex
	mov	al,[bp-2]	;filex
	cbw	
	push	ax
	call	FAR PTR _lines
	add	sp,6
	inc	ax
	push	dx
	push	ax
	call	FAR PTR _fputs
	add	sp,8
; Line 404
$FC210:
	add	WORD PTR $S194_linex,1
	adc	WORD PTR $S194_linex+2,0
	jmp	SHORT $F209
$FB211:
; Line 406
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG214
	push	ds
	push	ax
	call	FAR PTR _fputs
	add	sp,8
; Line 408
	jmp	$FB218
$I195:
	mov	BYTE PTR [bp-2],0	;filex
$F216:
	cmp	BYTE PTR [bp-2],2	;filex
	jl	$JCC2788
	jmp	$FB218
$JCC2788:
; Line 410
	mov	al,[bp-2]	;filex
	cbw	
	push	ax
	call	FAR PTR _id
	add	sp,2
; Line 411
	cmp	BYTE PTR [bp-2],0	;filex
	jne	$I220
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR $S192_delim+2
	push	WORD PTR $S192_delim
	call	FAR PTR _fputs
	add	sp,8
; Line 412
$I220:
	push	WORD PTR $S192_delim+2
	push	WORD PTR $S192_delim
	call	FAR PTR _puts
	add	sp,4
; Line 413
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S39_last[bx]
	mov	dx,WORD PTR $S39_last[bx+2]
	mov	WORD PTR $S194_linex,ax
	mov	WORD PTR $S194_linex+2,dx
$F222:
	mov	al,[bp-2]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S194_linex
	mov	dx,WORD PTR $S194_linex+2
	cmp	WORD PTR $S40_count[bx+2],dx
	jl	$FB224
	jg	$F225
	cmp	WORD PTR $S40_count[bx],ax
	jb	$FB224
$F225:
; Line 414
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR $S194_linex+2
	push	WORD PTR $S194_linex
	mov	al,[bp-2]	;filex
	cbw	
	push	ax
	call	FAR PTR _lines
	add	sp,6
	inc	ax
	push	dx
	push	ax
	call	FAR PTR _fputs
	add	sp,8
; Line 415
	add	WORD PTR $S194_linex,1
	adc	WORD PTR $S194_linex+2,0
	jmp	SHORT $F222
$FB224:
; Line 416
	cmp	BYTE PTR [bp-2],0	;filex
	je	$I226
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR $S192_delim+2
	push	WORD PTR $S192_delim
	call	FAR PTR _fputs
	add	sp,8
; Line 417
$I226:
	push	WORD PTR $S192_delim+2
	push	WORD PTR $S192_delim
	call	FAR PTR _puts
	add	sp,4
; Line 418
	inc	BYTE PTR [bp-2]	;filex
	jmp	$F216
$FB218:
; Line 419
	pop	si
	leave	
	ret	

_runout	ENDP
;	filex = 6
; Line 425
	PUBLIC	_crong
_crong	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
	push	si
; Line 429
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	al,$S46_sync
	cbw	
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	si,ax
	mov	al,BYTE PTR $S43_nb[si]
	cbw	
	add	ax,cx
	dec	ax
	cwd	
	add	WORD PTR $S40_count[bx],ax
	adc	WORD PTR $S40_count[bx+2],dx
; Line 430
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S39_last[bx]
	mov	dx,WORD PTR $S39_last[bx+2]
	mov	WORD PTR $S230_i,ax
	mov	WORD PTR $S230_i+2,dx
$F231:
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S230_i
	mov	dx,WORD PTR $S230_i+2
	cmp	WORD PTR $S40_count[bx+2],dx
	jl	$FB233
	jg	$F234
	cmp	WORD PTR $S40_count[bx],ax
	jbe	$FB233
$F234:
; Line 432
	mov	al,[bp+6]	;filex
	cbw	
	shl	ax,10
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	bx,WORD PTR $S37_start[bx]
	add	bx,cx
	shl	bx,2
	les	si,DWORD PTR $S36_linebf
	mov	ax,es:[bx][si]
	mov	dx,es:[bx+2][si]
	mov	[bp-4],ax	;p
	mov	[bp-2],dx
	or	ax,dx
	je	$I236
	push	dx
	push	WORD PTR [bp-4]	;p
	call	FAR PTR _free
	add	sp,4
; Line 433
$I236:
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	add	WORD PTR $S37_start[bx],1
	adc	WORD PTR $S37_start[bx+2],0
; Line 434
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	and	BYTE PTR $S37_start[bx+1],3
	mov	WORD PTR $S37_start[bx+2],0
; Line 435
	add	WORD PTR $S230_i,1
	adc	WORD PTR $S230_i+2,0
	jmp	$F231
;	p = -4
$FB233:
; Line 437
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	ax,WORD PTR $S40_count[bx]
	mov	dx,WORD PTR $S40_count[bx+2]
	mov	cx,ax
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	WORD PTR $S39_last[bx],cx
	mov	WORD PTR $S39_last[bx+2],dx
	mov	al,[bp+6]	;filex
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	WORD PTR $S41_current[bx],cx
	mov	WORD PTR $S41_current[bx+2],dx
; Line 438
	pop	si
	leave	
	ret	

_crong	ENDP
;	ac = 6
;	av = 10
; Line 441
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
	push	si
;	hashp = -4
;	hashend = -8
; Line 450
$F250:
; Line 452
	add	WORD PTR [bp+10],4	;av
; Line 453
	sub	WORD PTR [bp+6],1	;ac
	sbb	WORD PTR [bp+8],0
; Line 454
	cmp	WORD PTR [bp+8],0
	jl	$FB252
	jg	$L20023
	cmp	WORD PTR [bp+6],0	;ac
	jbe	$FB252
$L20023:
	les	bx,[bp+10]	;av
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],45
	jne	$JCC3333
	jmp	$I254
$JCC3333:
$FB252:
; Line 474
	cmp	WORD PTR [bp+8],0
	jne	$I267
	cmp	WORD PTR [bp+6],2	;ac
	jne	$JCC3348
	jmp	$I275
$JCC3348:
$I267:
; Line 463
	mov	ax,OFFSET DGROUP:$SG270
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,8
; Line 465
	mov	ax,OFFSET DGROUP:$SG271
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,8
; Line 466
	mov	ax,OFFSET DGROUP:$SG272
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,8
; Line 467
	mov	ax,OFFSET DGROUP:$SG273
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,8
; Line 468
	mov	ax,OFFSET DGROUP:$SG274
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,8
; Line 469
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 471
$I254:
	les	bx,[bp+10]	;av
	inc	WORD PTR es:[bx]
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],0
	jne	$JCC3481
	jmp	$F250
$JCC3481:
; Line 456
	les	bx,[bp+10]	;av
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],102
	jne	$I258
	inc	$S23_folding
; Line 457
	jmp	SHORT $I254
$I258:
	les	bx,[bp+10]	;av
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],105
	jne	$I260
	inc	$S24_ignore
; Line 458
	jmp	SHORT $I254
$I260:
	les	bx,[bp+10]	;av
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],122
	jne	$I262
	inc	$S25_stats
; Line 459
	jmp	SHORT $I254
$I262:
	les	bx,[bp+10]	;av
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],115
	jne	$I264
	les	bx,[bp+10]	;av
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	inc	ax
	push	dx
	push	ax
	call	FAR PTR _atoi
	add	sp,4
	mov	$S26_matchlen,ax
	jmp	$F250
$I264:
	les	bx,[bp+10]	;av
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],68
	je	$JCC3589
	jmp	$I267
$JCC3589:
	les	bx,[bp+10]	;av
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	inc	ax
	push	dx
	push	ax
	call	FAR PTR _newstr
	add	sp,4
	mov	WORD PTR $S27_defvar,ax
	mov	WORD PTR $S27_defvar+2,dx
	jmp	$F250
$I275:
	sub	ax,ax
	mov	WORD PTR $S242_i+2,ax
	mov	WORD PTR $S242_i,ax
$F276:
	cmp	WORD PTR $S242_i+2,0
	jbe	$JCC3638
	jmp	$FB278
$JCC3638:
	jb	$F279
	cmp	WORD PTR $S242_i,2
	jb	$JCC3650
	jmp	$FB278
$JCC3650:
$F279:
; Line 479
	mov	ax,OFFSET DGROUP:$SG280
	push	ds
	push	ax
	les	bx,[bp+10]	;av
	mov	si,WORD PTR $S242_i
	shl	si,2
	push	WORD PTR es:[bx+2][si]
	push	WORD PTR es:[bx][si]
	call	FAR PTR _fopen
	add	sp,8
	mov	bx,WORD PTR $S242_i
	shl	bx,2
	mov	WORD PTR $S47_ichan[bx],ax
	mov	WORD PTR $S47_ichan[bx+2],dx
; Line 480
	les	bx,[bp+10]	;av
	mov	si,WORD PTR $S242_i
	shl	si,2
	mov	ax,es:[bx][si]
	mov	dx,es:[bx+2][si]
	mov	bx,WORD PTR $S242_i
	shl	bx,2
	mov	WORD PTR $S45_fptr[bx],ax
	mov	WORD PTR $S45_fptr[bx+2],dx
; Line 481
	mov	bx,WORD PTR $S242_i
	shl	bx,2
	mov	ax,WORD PTR $S47_ichan[bx]
	or	ax,WORD PTR $S47_ichan[bx+2]
	jne	$FC277
; Line 483
	les	bx,[bp+10]	;av
	mov	si,WORD PTR $S242_i
	shl	si,2
	push	WORD PTR es:[bx+2][si]
	push	WORD PTR es:[bx][si]
	mov	ax,OFFSET DGROUP:$SG282
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,12
; Line 484
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 486
$FC277:
	add	WORD PTR $S242_i,1
	adc	WORD PTR $S242_i+2,0
	jmp	$F276
$FB278:
; Line 489
	cmp	$S25_stats,0
	je	$I283
	push	WORD PTR 5116
	call	FAR PTR _malloc
	add	sp,2
	mov	WORD PTR $S52_collct,ax
	mov	WORD PTR $S52_collct+2,dx
; Line 493
$I283:
	push	WORD PTR 10232
	call	FAR PTR _malloc
	add	sp,2
	mov	WORD PTR $S44_hashtable,ax
	mov	WORD PTR $S44_hashtable+2,dx
; Line 494
	or	ax,dx
	jne	$I284
	mov	ax,OFFSET DGROUP:$SG285
	push	ds
	push	ax
	call	FAR PTR _errkill
	add	sp,4
; Line 496
$I284:
	push	WORD PTR 8192
	call	FAR PTR _malloc
	add	sp,2
	mov	WORD PTR $S36_linebf,ax
	mov	WORD PTR $S36_linebf+2,dx
; Line 497
	or	ax,dx
	jne	$I286
	mov	ax,OFFSET DGROUP:$SG287
	push	ds
	push	ax
	call	FAR PTR _errkill
	add	sp,4
; Line 500
$I286:
	mov	ax,OFFSET DGROUP:$SG288
	mov	WORD PTR $S249_tb,ax
	mov	WORD PTR $S249_tb+2,ds
; Line 501
	push	ds
	push	ax
	call	FAR PTR _newstr
	add	sp,4
	les	bx,DWORD PTR $S36_linebf
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	or	ax,dx
	jne	$I289
	push	WORD PTR $S48_nocore+2
	push	WORD PTR $S48_nocore
	call	FAR PTR _errkill
	add	sp,4
; Line 502
$I289:
	push	WORD PTR $S249_tb+2
	push	WORD PTR $S249_tb
	call	FAR PTR _newstr
	add	sp,4
	les	bx,DWORD PTR $S36_linebf
	mov	es:[bx+4096],ax
	mov	es:[bx+4098],dx
	or	ax,dx
	jne	$I290
	push	WORD PTR $S48_nocore+2
	push	WORD PTR $S48_nocore
	call	FAR PTR _errkill
	add	sp,4
; Line 508
$I290:
; Line 509
	mov	ax,WORD PTR $S44_hashtable
	mov	dx,WORD PTR $S44_hashtable+2
	add	ax,10232
	mov	[bp-8],ax	;hashend
	mov	[bp-6],dx
; Line 510
	mov	ax,WORD PTR $S44_hashtable
	mov	[bp-4],ax	;hashp
	mov	[bp-2],dx
$F292:
	mov	ax,[bp-8]	;hashend
	mov	dx,[bp-6]
	cmp	[bp-2],dx
	jne	$F295
	cmp	[bp-4],ax	;hashp
	je	$FB294
$F295:
	les	bx,[bp-4]	;hashp
	mov	WORD PTR es:[bx],-1
	mov	WORD PTR es:[bx+2],-1
	add	WORD PTR [bp-4],4	;hashp
	jmp	SHORT $F292
$FB294:
; Line 513
	mov	$S243_strikes,0
; Line 515
	mov	ax,WORD PTR $S42_endfile
	mov	dx,WORD PTR $S42_endfile+2
	cmp	WORD PTR $S41_current+2,dx
	jne	$I297
	cmp	WORD PTR $S41_current,ax
	jne	$I297
	inc	$S243_strikes
; Line 516
	jmp	SHORT $I298
$I297:
	add	WORD PTR $S41_current,1
	adc	WORD PTR $S41_current+2,0
$I298:
; Line 518
	mov	ax,WORD PTR $S42_endfile+4
	mov	dx,WORD PTR $S42_endfile+6
	cmp	WORD PTR $S41_current+6,dx
	jne	$I299
	cmp	WORD PTR $S41_current+4,ax
	jne	$I299
	inc	$S243_strikes
; Line 519
	jmp	SHORT $I300
$I299:
	add	WORD PTR $S41_current+4,1
	adc	WORD PTR $S41_current+6,0
$I300:
; Line 521
	mov	ax,WORD PTR $S41_current
	mov	dx,WORD PTR $S41_current+2
	mov	WORD PTR $S40_count,ax
	mov	WORD PTR $S40_count+2,dx
; Line 522
	mov	ax,WORD PTR $S41_current+4
	mov	dx,WORD PTR $S41_current+6
	mov	WORD PTR $S40_count+4,ax
	mov	WORD PTR $S40_count+6,dx
; Line 524
	call	FAR PTR _match
	or	al,al
	jne	$JCC4177
	jmp	$I301
$JCC4177:
$found302:
; Line 581
	cmp	$S46_sync,0
	jne	$I320
	push	WORD PTR 0
	call	FAR PTR _runout
	add	sp,2
; Line 584
$I320:
	cmp	$S46_sync,0
	je	$I321
	mov	ax,WORD PTR $S27_defvar
	or	ax,WORD PTR $S27_defvar+2
	je	$I321
	mov	ax,WORD PTR $S40_count
	or	ax,WORD PTR $S40_count+2
	je	$I321
	mov	ax,WORD PTR $S42_endfile
	mov	dx,WORD PTR $S42_endfile+2
	cmp	WORD PTR $S40_count+2,dx
	jne	$L20033
	cmp	WORD PTR $S40_count,ax
	je	$I321
$L20033:
; Line 585
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR $S40_count+2
	push	WORD PTR $S40_count
	push	WORD PTR 0
	call	FAR PTR _lines
	add	sp,6
	inc	ax
	push	dx
	push	ax
	call	FAR PTR _fputs
	add	sp,8
; Line 587
$I321:
	push	WORD PTR 0
	call	FAR PTR _crong
	add	sp,2
	push	WORD PTR 1
	call	FAR PTR _crong
	add	sp,2
; Line 590
	cmp	$S243_strikes,2
	je	$JCC4305
	jmp	$I322
$JCC4305:
; Line 591
	cmp	$S25_stats,0
	jne	$JCC4315
	jmp	$FB326
$JCC4315:
; Line 592
	sub	ax,ax
	mov	WORD PTR $S242_i+2,ax
	mov	WORD PTR $S242_i,ax
$F324:
	cmp	WORD PTR $S242_i+2,0
	jbe	$JCC4333
	jmp	$FB326
$JCC4333:
	jb	$F327
	cmp	WORD PTR $S242_i,1279
	jb	$JCC4346
	jmp	$FB326
$JCC4346:
$F327:
; Line 593
	mov	bx,WORD PTR $S242_i
	shl	bx,2
	les	si,DWORD PTR $S52_collct
	mov	ax,es:[bx][si]
	or	ax,es:[bx+2][si]
	je	$FC325
	mov	bx,WORD PTR $S242_i
	shl	bx,2
	push	WORD PTR es:[bx+2][si]
	push	WORD PTR es:[bx][si]
	push	WORD PTR $S242_i+2
	push	WORD PTR $S242_i
	mov	ax,OFFSET DGROUP:$SG329
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,12
; Line 594
$FC325:
	add	WORD PTR $S242_i,1
	adc	WORD PTR $S242_i+2,0
	jmp	SHORT $F324
$I301:
	mov	ax,WORD PTR $S41_current
	mov	dx,WORD PTR $S41_current+2
	mov	WORD PTR $S40_count,ax
	mov	WORD PTR $S40_count+2,dx
; Line 530
	mov	ax,WORD PTR $S42_endfile+4
	mov	dx,WORD PTR $S42_endfile+6
	cmp	WORD PTR $S41_current+6,dx
	jne	$L20027
	cmp	WORD PTR $S41_current+4,ax
	jne	$JCC4449
	jmp	$I304
$JCC4449:
$L20027:
; Line 531
	push	WORD PTR $S41_current+6
	push	WORD PTR $S41_current+4
	push	WORD PTR 1
	call	FAR PTR _lines
	add	sp,6
	push	dx
	push	ax
	call	FAR PTR _hash
	add	sp,4
	mov	WORD PTR $S248_hash1,ax
	mov	WORD PTR $S248_hash1+2,dx
; Line 532
	add	ax,1279
	adc	dx,0
	mov	WORD PTR $S246_hashind,ax
	mov	WORD PTR $S246_hashind+2,dx
; Line 533
$WC305:
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	cmp	WORD PTR es:[bx+2][si],-1
	jne	$L20028
	cmp	WORD PTR es:[bx][si],-1
	je	$WB306
$L20028:
; Line 534
	add	WORD PTR $S246_hashind,1
	adc	WORD PTR $S246_hashind+2,0
; Line 535
	cmp	WORD PTR $S246_hashind+2,0
	jne	$WC305
	cmp	WORD PTR $S246_hashind,2558
	jne	$WC305
	mov	WORD PTR $S246_hashind,1279
	mov	WORD PTR $S246_hashind+2,0
; Line 536
	jmp	SHORT $WC305
$WB306:
; Line 539
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	mov	ax,WORD PTR $S38_stop+4
	mov	dx,WORD PTR $S38_stop+6
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],dx
; Line 543
$I304:
	push	WORD PTR $S41_current+2
	push	WORD PTR $S41_current
	push	WORD PTR 0
	call	FAR PTR _lines
	add	sp,6
	push	dx
	push	ax
	call	FAR PTR _hash
	add	sp,4
	mov	WORD PTR $S247_hash0,ax
	mov	WORD PTR $S247_hash0+2,dx
; Line 544
	add	ax,1279
	adc	dx,0
	mov	WORD PTR $S246_hashind,ax
	mov	WORD PTR $S246_hashind+2,dx
; Line 547
$WC308:
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	cmp	WORD PTR es:[bx+2][si],-1
	jne	$L20029
	cmp	WORD PTR es:[bx][si],-1
	je	$WB309
$L20029:
; Line 548
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	mov	ax,es:[bx][si]
	mov	dx,es:[bx+2][si]
	sub	ax,WORD PTR $S37_start+4
	sbb	dx,WORD PTR $S37_start+6
	and	ah,3
	sub	dx,dx
	add	ax,WORD PTR $S39_last+4
	adc	dx,WORD PTR $S39_last+6
	mov	WORD PTR $S40_count+4,ax
	mov	WORD PTR $S40_count+6,dx
; Line 549
	call	FAR PTR _match
	or	al,al
	je	$JCC4715
	jmp	$found302
$JCC4715:
	add	WORD PTR $S246_hashind,1
	adc	WORD PTR $S246_hashind+2,0
; Line 551
	cmp	WORD PTR $S246_hashind+2,0
	jne	$WC308
	cmp	WORD PTR $S246_hashind,2558
	jne	$WC308
	mov	WORD PTR $S246_hashind,1279
	mov	WORD PTR $S246_hashind+2,0
; Line 552
	jmp	SHORT $WC308
$WB309:
; Line 555
	mov	ax,WORD PTR $S41_current+4
	mov	dx,WORD PTR $S41_current+6
	mov	WORD PTR $S40_count+4,ax
	mov	WORD PTR $S40_count+6,dx
; Line 558
	mov	ax,WORD PTR $S42_endfile
	mov	dx,WORD PTR $S42_endfile+2
	cmp	WORD PTR $S41_current+2,dx
	jne	$L20030
	cmp	WORD PTR $S41_current,ax
	je	$I312
$L20030:
; Line 559
	mov	ax,WORD PTR $S247_hash0
	mov	dx,WORD PTR $S247_hash0+2
	mov	WORD PTR $S246_hashind,ax
	mov	WORD PTR $S246_hashind+2,dx
; Line 560
$WC313:
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	cmp	WORD PTR es:[bx+2][si],-1
	jne	$L20031
	cmp	WORD PTR es:[bx][si],-1
	je	$WB314
$L20031:
; Line 561
	add	WORD PTR $S246_hashind,1
	adc	WORD PTR $S246_hashind+2,0
; Line 562
	cmp	WORD PTR $S246_hashind+2,0
	jne	$WC313
	cmp	WORD PTR $S246_hashind,1279
	jne	$WC313
	sub	ax,ax
	mov	WORD PTR $S246_hashind+2,ax
	mov	WORD PTR $S246_hashind,ax
; Line 563
	jmp	SHORT $WC313
$WB314:
; Line 566
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	mov	ax,WORD PTR $S38_stop
	mov	dx,WORD PTR $S38_stop+2
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],dx
; Line 569
$I312:
	mov	ax,WORD PTR $S248_hash1
	mov	dx,WORD PTR $S248_hash1+2
	mov	WORD PTR $S246_hashind,ax
	mov	WORD PTR $S246_hashind+2,dx
; Line 570
$WC316:
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	cmp	WORD PTR es:[bx+2][si],-1
	jne	$L20032
	cmp	WORD PTR es:[bx][si],-1
	jne	$JCC4926
	jmp	$FB294
$JCC4926:
$L20032:
; Line 571
	mov	bx,WORD PTR $S246_hashind
	shl	bx,2
	les	si,DWORD PTR $S44_hashtable
	mov	ax,es:[bx][si]
	mov	dx,es:[bx+2][si]
	sub	ax,WORD PTR $S37_start
	sbb	dx,WORD PTR $S37_start+2
	and	ah,3
	sub	dx,dx
	add	ax,WORD PTR $S39_last
	adc	dx,WORD PTR $S39_last+2
	mov	WORD PTR $S40_count,ax
	mov	WORD PTR $S40_count+2,dx
; Line 572
	call	FAR PTR _match
	or	al,al
	je	$JCC4984
	jmp	$found302
$JCC4984:
	add	WORD PTR $S246_hashind,1
	adc	WORD PTR $S246_hashind+2,0
; Line 574
	cmp	WORD PTR $S246_hashind+2,0
	jne	$WC316
	cmp	WORD PTR $S246_hashind,1279
	jne	$WC316
	sub	ax,ax
	mov	WORD PTR $S246_hashind+2,ax
	mov	WORD PTR $S246_hashind,ax
; Line 575
	jmp	SHORT $WC316
$FB326:
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 597
$I322:
	cmp	$S46_sync,0
	je	$JCC5039
	jmp	$FB294
$JCC5039:
	mov	$S46_sync,1
	jmp	$I290

_main	ENDP
SCOM_TEXT	ENDS
END
