;	Static Name Aliases
;
;	$S7_sccsid	EQU	sccsid
	TITLE   ptx

	.286p
	.287
PTX_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
PTX_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: PTX_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _outptr
PUBLIC  _nofold
PUBLIC  _fold
PUBLIC  _sortopt
PUBLIC  _llen
PUBLIC  _gap
PUBLIC  _gutter
PUBLIC  _mlen
PUBLIC  _empty
PUBLIC  _inptr
EXTRN	__flsbuf:FAR
EXTRN	__filbuf:FAR
EXTRN	_ungetc:FAR
EXTRN	_fopen:FAR
EXTRN	__almul:FAR
EXTRN	__lshr:FAR
EXTRN	_signal:FAR
EXTRN	__chkstk:FAR
EXTRN	_atoi:FAR
EXTRN	_fclose:FAR
EXTRN	_fork:FAR
EXTRN	_calloc:FAR
EXTRN	_execl:FAR
EXTRN	_mktemp:FAR
EXTRN	__ldiv:FAR
EXTRN	_wait:FAR
EXTRN	_unlink:FAR
EXTRN	_exit:FAR
EXTRN	_fprintf:FAR
EXTRN	_outfile:DWORD
EXTRN	_sortfile:DWORD
EXTRN	_sortptr:DWORD
EXTRN	_bfile:DWORD
EXTRN	_bptr:DWORD
EXTRN	__iob:BYTE
EXTRN	__ctype_:BYTE
EXTRN	_status:DWORD
EXTRN	_hasht:BYTE
EXTRN	_line:BYTE
EXTRN	_btable:BYTE
EXTRN	_ignore:DWORD
EXTRN	_only:DWORD
EXTRN	_wlen:DWORD
EXTRN	_rflag:DWORD
EXTRN	_halflen:DWORD
EXTRN	_strtbufp:DWORD
EXTRN	_endbufp:DWORD
EXTRN	_infile:DWORD
_DATA      SEGMENT
$SG8	DB	'@(#)ptx.c',  09H, '4.2 (Berkeley) 9/23/85',  00H
	EVEN
$SG61	DB	00H
	EVEN
$SG86	DB	'/usr/lib/eign',  00H
$SG100	DB	'Wrong width:',  00H
	EVEN
$SG103	DB	'Lines truncated to 200 chars.',  00H
$SG110	DB	'Only file already given.',  00H
	EVEN
$SG114	DB	'Ignore file already given',  00H
$SG119	DB	'Illegal argument:',  00H
$SG121	DB	'Too many filenames',  00H
	EVEN
$SG125	DB	'w',  00H
$SG126	DB	'Cannot open output file:',  00H
	EVEN
$SG131	DB	'r',  00H
$SG132	DB	'Cannot open break char file',  00H
$SG137	DB	'Out of memory space',  00H
$SG139	DB	'r',  00H
$SG140	DB	'Cannot open  file',  00H
$SG147	DB	'Too many words',  00H
	EVEN
$SG150	DB	'Too many words in file',  00H
	EVEN
$SG151	DB	'/tmp/ptxsXXXXX',  00H
	EVEN
$SG153	DB	'w',  00H
$SG154	DB	'Cannot open output for sorting:',  00H
$SG156	DB	'r',  00H
$SG157	DB	'Cannot open data: ',  00H
	EVEN
$SG168	DB	'Cannot fork',  00H
$SG171	DB	'-o',  00H
	EVEN
$SG172	DB	'+1',  00H
	EVEN
$SG173	DB	'-1',  00H
	EVEN
$SG174	DB	'+0',  00H
	EVEN
$SG175	DB	'/usr/bin/sort',  00H
$SG176	DB	'/usr/bin/sort',  00H
$SG189	DB	'%s %s',  0aH,  00H
	EVEN
$SG279	DB	'r',  00H
$SG280	DB	'Cannot open sorted data:',  00H
	EVEN
$SG298	DB	'.xx "',  00H
$SG301	DB	'/',  00H
$SG302	DB	'" "',  00H
$SG304	DB	'/',  00H
$SG305	DB	'" "',  00H
$SG307	DB	'/',  00H
$SG308	DB	'" "',  00H
$SG310	DB	'/',  00H
$SG312	DB	'" %s',  0aH,  00H
$SG314	DB	'"',  0aH,  00H
	EVEN
$S7_sccsid	DD	OFFSET DGROUP:$SG8
	PUBLIC	_llen
_llen	DD	048H
	PUBLIC	_gap
_gap	DD	03H
	PUBLIC	_gutter
_gutter	DD	03H
	PUBLIC	_mlen
_mlen	DD	0c8H
	PUBLIC	_empty
_empty	DD	OFFSET DGROUP:$SG61
	PUBLIC	_inptr
_inptr	DD	OFFSET __iob
	PUBLIC	_outptr
_outptr	DD	OFFSET __iob+20
	PUBLIC	_nofold
_nofold	DB	02dH
	DB	064H
	DB	074H
	DB	07fH
	DB	00H
	EVEN
	PUBLIC	_fold
_fold	DB	02dH
	DB	064H
	DB	066H
	DB	074H
	DB	07fH
	DB	00H
	PUBLIC	_sortopt
_sortopt	DD	OFFSET DGROUP:_nofold
;	.comm _outfile,04H
;	.comm _sortfile,04H
;	.comm _sortptr,04H
;	.comm _bfile,04H
;	.comm _bptr,04H
;	.comm _status,04H
;	.comm _hasht,02000H
;	.comm _line,0c8H
;	.comm _btable,080H
;	.comm _ignore,04H
;	.comm _only,04H
;	.comm _wlen,04H
;	.comm _rflag,04H
;	.comm _halflen,04H
;	.comm _strtbufp,04H
;	.comm _endbufp,04H
;	.comm _infile,04H
_DATA      ENDS
PTX_TEXT      SEGMENT
;	argc = 6
PTX_TEXT      ENDS
CONST      SEGMENT
$T20002	DW SEG _rflag 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20004	DW SEG _wlen 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20007	DW SEG _only 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20009	DW SEG _ignore 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20012	DW SEG _bfile 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20015	DW SEG _infile 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20016	DW SEG _outfile 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20017	DW SEG _btable 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20018	DW SEG _bptr 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20022	DW SEG _strtbufp 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20023	DW SEG _endbufp 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20029	DW SEG __ctype_ 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20030	DW SEG _sortfile 
CONST      ENDS
PTX_TEXT      SEGMENT
PTX_TEXT      ENDS
CONST      SEGMENT
$T20031	DW SEG _sortptr 
CONST      ENDS
PTX_TEXT      SEGMENT
;	argv = 10
; Line 67
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,24
	call	FAR PTR __chkstk
	push	si
;	xptr = -4
;	bufp = -8
;	c = -12
;	pend = -16
;	xfile = -20
;	pid = -24
; Line 77
	push	SEG _onlongr
	push	OFFSET WORD PTR _onlongr
	push	WORD PTR 1
	call	FAR PTR _signal
	add	sp,6
	or	dx,dx
	jne	$I84
	cmp	ax,1
	jne	$I84
; Line 78
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 1
	call	FAR PTR _signal
	add	sp,6
; Line 79
$I84:
	push	SEG _onlongr
	push	OFFSET WORD PTR _onlongr
	push	WORD PTR 2
	call	FAR PTR _signal
	add	sp,6
	or	dx,dx
	jne	$I85
	cmp	ax,1
	jne	$I85
; Line 80
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 2
	call	FAR PTR _signal
	add	sp,6
; Line 81
$I85:
	push	SEG _onlongr
	push	OFFSET WORD PTR _onlongr
	push	WORD PTR 13
	call	FAR PTR _signal
	add	sp,6
; Line 82
	push	SEG _onlongr
	push	OFFSET WORD PTR _onlongr
	push	WORD PTR 15
	call	FAR PTR _signal
	add	sp,6
; Line 83
	mov	ax,OFFSET DGROUP:$SG86
	mov	[bp-20],ax	;xfile
	mov	[bp-18],ds
; Line 84
$L20123:
	add	WORD PTR [bp+10],4	;argv
; Line 85
	cmp	WORD PTR [bp+8],0
	jge	$JCC139
	jmp	$WB88
$JCC139:
	jg	$L20001
	cmp	WORD PTR [bp+6],1	;argc
	ja	$JCC150
	jmp	$WB88
$JCC150:
$L20001:
	les	bx,[bp+10]	;argv
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],45
	je	$JCC165
	jmp	$WB88
$JCC165:
; Line 86
	les	bx,[bp+10]	;argv
	inc	WORD PTR es:[bx]
	les	bx,es:[bx]
	mov	al,es:[bx]
	cbw	
	sub	ax,98
	cmp	ax,21
	jbe	$JCC189
	jmp	$SD118
$JCC189:
	add	ax,ax
	xchg	ax,bx
	jmp	WORD PTR cs:$L20013[bx]
$SC93:
; Line 88
	mov	es,$T20002
	add	WORD PTR es:_rflag,1
	adc	WORD PTR es:_rflag+2,0
; Line 89
	jmp	$SB90
$SC94:
; Line 91
	mov	ax,OFFSET DGROUP:_fold
	mov	WORD PTR _sortopt,ax
	mov	WORD PTR _sortopt+2,ds
; Line 92
	jmp	$SB90
$SC95:
; Line 94
	cmp	WORD PTR [bp+8],0
	jge	$JCC238
	jmp	$I96
$JCC238:
	jg	$L20003
	cmp	WORD PTR [bp+6],2	;argc
	jae	$JCC249
	jmp	$I96
$JCC249:
$L20003:
; Line 95
	sub	WORD PTR [bp+6],1	;argc
	sbb	WORD PTR [bp+8],0
; Line 96
	mov	es,$T20004
	add	WORD PTR es:_wlen,1
	adc	WORD PTR es:_wlen+2,0
; Line 97
	add	WORD PTR [bp+10],4	;argv
	les	bx,[bp+10]	;argv
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _atoi
	add	sp,4
	cwd	
	mov	WORD PTR _llen,ax
	mov	WORD PTR _llen+2,dx
; Line 98
	or	ax,dx
	jne	$I98
; Line 99
	les	bx,[bp+10]	;argv
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	mov	ax,OFFSET DGROUP:$SG100
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 100
$I98:
	cmp	WORD PTR _llen+2,0
	jge	$JCC340
	jmp	$SB90
$JCC340:
	jg	$L20005
	cmp	WORD PTR _llen,200
	ja	$JCC353
	jmp	$SB90
$JCC353:
$L20005:
; Line 101
	mov	WORD PTR _llen,200
	mov	WORD PTR _llen+2,0
; Line 102
	push	WORD PTR _empty+2
	push	WORD PTR _empty
	mov	ax,OFFSET DGROUP:$SG103
$L20124:
	push	ds
	push	ax
	call	FAR PTR _msg
	add	sp,8
; Line 104
	jmp	$SB90
$I96:
; Line 107
	mov	es,$T20004
	mov	ax,WORD PTR es:_wlen
	or	ax,WORD PTR es:_wlen+2
	je	$JCC407
	jmp	$SB90
$JCC407:
; Line 108
	mov	WORD PTR _llen,100
	mov	WORD PTR _llen+2,0
; Line 109
	jmp	$SB90
$SC106:
; Line 111
	cmp	WORD PTR [bp+8],0
	jge	$JCC431
	jmp	$SB90
$JCC431:
	jg	$L20006
	cmp	WORD PTR [bp+6],2	;argc
	jae	$JCC442
	jmp	$SB90
$JCC442:
$L20006:
; Line 112
	sub	WORD PTR [bp+6],1	;argc
	sbb	WORD PTR [bp+8],0
; Line 113
	add	WORD PTR [bp+10],4	;argv
	les	bx,[bp+10]	;argv
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _atoi
	add	sp,4
	cwd	
	mov	WORD PTR _gutter,ax
	mov	WORD PTR _gutter+2,dx
	mov	WORD PTR _gap,ax
	mov	WORD PTR _gap+2,dx
; Line 115
	jmp	$SB90
$SC108:
; Line 117
	mov	es,$T20007
	mov	ax,WORD PTR es:_only
	or	ax,WORD PTR es:_only+2
	je	$I109
; Line 118
	push	WORD PTR _empty+2
	push	WORD PTR _empty
	mov	ax,OFFSET DGROUP:$SG110
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 119
$I109:
	cmp	WORD PTR [bp+8],0
	jge	$JCC535
	jmp	$SB90
$JCC535:
	jg	$L20008
	cmp	WORD PTR [bp+6],2	;argc
	jae	$JCC546
	jmp	$SB90
$JCC546:
$L20008:
; Line 120
	sub	WORD PTR [bp+6],1	;argc
	sbb	WORD PTR [bp+8],0
; Line 121
	mov	es,$T20009
	add	WORD PTR es:_ignore,1
	adc	WORD PTR es:_ignore+2,0
; Line 122
$L20125:
	add	WORD PTR [bp+10],4	;argv
	les	bx,[bp+10]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-20],ax	;xfile
	mov	[bp-18],dx
; Line 124
	jmp	$SB90
$SC112:
; Line 126
	mov	es,$T20009
	mov	ax,WORD PTR es:_ignore
	or	ax,WORD PTR es:_ignore+2
	je	$I113
; Line 127
	push	WORD PTR _empty+2
	push	WORD PTR _empty
	mov	ax,OFFSET DGROUP:$SG114
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 128
$I113:
	cmp	WORD PTR [bp+8],0
	jge	$JCC638
	jmp	$SB90
$JCC638:
	jg	$L20010
	cmp	WORD PTR [bp+6],2	;argc
	jae	$JCC649
	jmp	$SB90
$JCC649:
$L20010:
; Line 129
	mov	es,$T20007
	add	WORD PTR es:_only,1
	adc	WORD PTR es:_only+2,0
; Line 130
	sub	WORD PTR [bp+6],1	;argc
	sbb	WORD PTR [bp+8],0
	jmp	SHORT $L20125
$SC116:
; Line 135
	cmp	WORD PTR [bp+8],0
	jl	$SB90
	jg	$L20011
	cmp	WORD PTR [bp+6],2	;argc
	jb	$SB90
$L20011:
; Line 136
	sub	WORD PTR [bp+6],1	;argc
	sbb	WORD PTR [bp+8],0
; Line 137
	add	WORD PTR [bp+10],4	;argv
	les	bx,[bp+10]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	es,$T20012
	mov	WORD PTR es:_bfile,ax
	mov	WORD PTR es:_bfile+2,dx
; Line 139
	jmp	SHORT $SB90
$SD118:
; Line 141
	les	bx,[bp+10]	;argv
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	mov	ax,OFFSET DGROUP:$SG119
	jmp	$L20124
$L20013:
		DW	$SC116
		DW	$SD118
		DW	$SD118
		DW	$SD118
		DW	$SC94
		DW	$SC106
		DW	$SD118
		DW	$SC108
		DW	$SD118
		DW	$SD118
		DW	$SD118
		DW	$SD118
		DW	$SD118
		DW	$SC112
		DW	$SD118
		DW	$SD118
		DW	$SC93
		DW	$SD118
		DW	$I96
		DW	$SD118
		DW	$SD118
		DW	$SC95
$SB90:
; Line 143
	sub	WORD PTR [bp+6],1	;argc
	sbb	WORD PTR [bp+8],0
	jmp	$L20123
$WB88:
; Line 146
	cmp	WORD PTR [bp+8],0
	jl	$I120
	jg	$L20014
	cmp	WORD PTR [bp+6],3	;argc
	jbe	$I120
$L20014:
; Line 147
	push	WORD PTR _empty+2
	push	WORD PTR _empty
	mov	ax,OFFSET DGROUP:$SG121
$L20126:
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 148
	jmp	$I128
$I120:
	cmp	WORD PTR [bp+8],0
	jne	$I123
	cmp	WORD PTR [bp+6],3	;argc
	jne	$I123
; Line 149
	les	bx,[bp+10]	;argv
	add	WORD PTR [bp+10],4	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	es,$T20015
	mov	WORD PTR es:_infile,ax
	mov	WORD PTR es:_infile+2,dx
; Line 150
	les	bx,[bp+10]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	es,$T20016
	mov	WORD PTR es:_outfile,ax
	mov	WORD PTR es:_outfile+2,dx
; Line 151
	mov	ax,OFFSET DGROUP:$SG125
	push	ds
	push	ax
	push	dx
	push	WORD PTR es:_outfile
	call	FAR PTR _fopen
	add	sp,8
	mov	WORD PTR _outptr,ax
	mov	WORD PTR _outptr+2,dx
	or	ax,dx
	jne	$I128
; Line 152
	mov	es,$T20016
	push	WORD PTR es:_outfile+2
	push	WORD PTR es:_outfile
	mov	ax,OFFSET DGROUP:$SG126
	jmp	SHORT $L20126
$I123:
	cmp	WORD PTR [bp+8],0
	jne	$I128
	cmp	WORD PTR [bp+6],2	;argc
	jne	$I128
; Line 154
	les	bx,[bp+10]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	es,$T20015
	mov	WORD PTR es:_infile,ax
	mov	WORD PTR es:_infile+2,dx
; Line 155
	mov	es,$T20016
	sub	ax,ax
	mov	WORD PTR es:_outfile+2,ax
	mov	WORD PTR es:_outfile,ax
; Line 158
$I128:
	mov	es,$T20017
	mov	BYTE PTR es:_btable+32,1
; Line 159
	mov	BYTE PTR es:_btable+9,1
; Line 160
	mov	BYTE PTR es:_btable+10,1
; Line 161
	mov	es,$T20012
	mov	ax,WORD PTR es:_bfile
	or	ax,WORD PTR es:_bfile+2
	jne	$JCC1035
	jmp	$WB135
$JCC1035:
; Line 162
	mov	ax,OFFSET DGROUP:$SG131
	push	ds
	push	ax
	push	WORD PTR es:_bfile+2
	push	WORD PTR es:_bfile
	call	FAR PTR _fopen
	add	sp,8
	mov	es,$T20018
	mov	WORD PTR es:_bptr,ax
	mov	WORD PTR es:_bptr+2,dx
	or	ax,dx
	jne	$I130
; Line 163
	mov	es,$T20012
	push	WORD PTR es:_bfile+2
	push	WORD PTR es:_bfile
	mov	ax,OFFSET DGROUP:$SG132
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 164
$I130:
	mov	es,$T20018
	les	bx,DWORD PTR es:_bptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20019
	mov	es,$T20018
	les	bx,DWORD PTR es:_bptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	sub	ah,ah
	sub	dx,dx
	jmp	SHORT $L20020
$L20019:
	mov	es,$T20018
	push	WORD PTR es:_bptr+2
	push	WORD PTR es:_bptr
	call	FAR PTR __filbuf
	add	sp,4
	cwd	
$L20020:
	mov	[bp-12],ax	;c
	mov	[bp-10],dx
	cmp	dx,-1
	jne	$L20021
	cmp	ax,-1
	je	$WB135
$L20021:
; Line 165
	mov	bx,[bp-12]	;c
	mov	es,$T20017
	mov	BYTE PTR es:_btable[bx],1
	jmp	SHORT $I130
$WB135:
; Line 167
	push	WORD PTR 1024
	push	WORD PTR 30
	call	FAR PTR _calloc
	add	sp,4
	mov	es,$T20022
	mov	WORD PTR es:_strtbufp,ax
	mov	WORD PTR es:_strtbufp+2,dx
	or	ax,dx
	jne	$I136
; Line 168
	push	WORD PTR _empty+2
	push	WORD PTR _empty
	mov	ax,OFFSET DGROUP:$SG137
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 169
$I136:
	mov	es,$T20022
	mov	ax,WORD PTR es:_strtbufp
	mov	dx,WORD PTR es:_strtbufp+2
	mov	[bp-8],ax	;bufp
	mov	[bp-6],dx
; Line 170
	add	ah,120
	mov	es,$T20023
	mov	WORD PTR es:_endbufp,ax
	mov	WORD PTR es:_endbufp+2,dx
; Line 171
	mov	ax,OFFSET DGROUP:$SG139
	push	ds
	push	ax
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;xfile
	call	FAR PTR _fopen
	add	sp,8
	mov	[bp-4],ax	;xptr
	mov	[bp-2],dx
	or	ax,dx
	jne	$I138
; Line 172
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;xfile
	mov	ax,OFFSET DGROUP:$SG140
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 173
$I138:
	mov	es,$T20023
	mov	ax,WORD PTR es:_endbufp
	mov	dx,WORD PTR es:_endbufp+2
	cmp	[bp-8],ax	;bufp
	jb	$JCC1366
	jmp	$WB142
$JCC1366:
	les	bx,[bp-4]	;xptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20024
	les	bx,[bp-4]	;xptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	sub	ah,ah
	sub	dx,dx
	jmp	SHORT $L20025
$L20024:
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;xptr
	call	FAR PTR __filbuf
	add	sp,4
	cwd	
$L20025:
	mov	[bp-12],ax	;c
	mov	[bp-10],dx
	cmp	dx,-1
	jne	$L20026
	cmp	ax,-1
	jne	$JCC1443
	jmp	$WB142
$JCC1443:
$L20026:
; Line 174
	mov	bx,[bp-12]	;c
	mov	es,$T20017
	cmp	BYTE PTR es:_btable[bx],0
	je	$I143
; Line 175
	mov	es,$T20022
	push	WORD PTR es:_strtbufp+2
	push	WORD PTR es:_strtbufp
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;bufp
	push	WORD PTR es:_strtbufp+2
	push	WORD PTR es:_strtbufp
	call	FAR PTR _hash
	add	sp,8
	push	ax
	call	FAR PTR _storeh
	add	sp,6
	or	ax,ax
	je	$I146
; Line 176
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;xfile
	mov	ax,OFFSET DGROUP:$SG147
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 177
$I146:
	les	bx,[bp-8]	;bufp
	inc	WORD PTR [bp-8]	;bufp
	mov	BYTE PTR es:[bx],0
; Line 178
	mov	es,$T20022
	mov	ax,[bp-8]	;bufp
	mov	dx,[bp-6]
	mov	WORD PTR es:_strtbufp,ax
	mov	WORD PTR es:_strtbufp+2,dx
; Line 180
	jmp	$I138
$I143:
; Line 181
	mov	bx,[bp-12]	;c
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],1
	je	$L20027
	mov	al,[bp-12]	;c
	add	al,32
	jmp	SHORT $L20028
$L20027:
	mov	al,[bp-12]	;c
$L20028:
	les	bx,[bp-8]	;bufp
	inc	WORD PTR [bp-8]	;bufp
	mov	es:[bx],al
; Line 183
	jmp	$I138
$WB142:
; Line 184
	mov	es,$T20023
	mov	ax,WORD PTR es:_endbufp
	mov	dx,WORD PTR es:_endbufp+2
	cmp	[bp-8],ax	;bufp
	jb	$I149
; Line 185
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;xfile
	mov	ax,OFFSET DGROUP:$SG150
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 186
$I149:
	dec	WORD PTR [bp-8]	;bufp
	mov	ax,[bp-8]	;bufp
	mov	dx,[bp-6]
	mov	es,$T20023
	mov	WORD PTR es:_endbufp,ax
	mov	WORD PTR es:_endbufp+2,dx
; Line 188
	mov	ax,OFFSET DGROUP:$SG151
	push	ds
	push	ax
	call	FAR PTR _mktemp
	add	sp,4
	mov	es,$T20030
	mov	WORD PTR es:_sortfile,ax
	mov	WORD PTR es:_sortfile+2,dx
; Line 189
	mov	ax,OFFSET DGROUP:$SG153
	push	ds
	push	ax
	push	dx
	push	WORD PTR es:_sortfile
	call	FAR PTR _fopen
	add	sp,8
	mov	es,$T20031
	mov	WORD PTR es:_sortptr,ax
	mov	WORD PTR es:_sortptr+2,dx
	or	ax,dx
	jne	$I152
; Line 190
	mov	es,$T20030
	push	WORD PTR es:_sortfile+2
	push	WORD PTR es:_sortfile
	mov	ax,OFFSET DGROUP:$SG154
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 191
$I152:
	mov	es,$T20015
	mov	ax,WORD PTR es:_infile
	or	ax,WORD PTR es:_infile+2
	je	$I155
	mov	ax,OFFSET DGROUP:$SG156
	push	ds
	push	ax
	push	WORD PTR es:_infile+2
	push	WORD PTR es:_infile
	call	FAR PTR _fopen
	add	sp,8
	mov	WORD PTR _inptr,ax
	mov	WORD PTR _inptr+2,dx
	or	ax,dx
	jne	$I155
; Line 192
	mov	es,$T20015
	push	WORD PTR es:_infile+2
	push	WORD PTR es:_infile
	mov	ax,OFFSET DGROUP:$SG157
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 193
$I155:
	call	FAR PTR _getline
	mov	[bp-16],ax	;pend
	mov	[bp-14],dx
	or	ax,dx
	je	$WB159
; Line 194
	push	dx
	push	WORD PTR [bp-16]	;pend
	call	FAR PTR _cmpline
	add	sp,4
	jmp	SHORT $I155
$WB159:
; Line 195
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	call	FAR PTR _fclose
	add	sp,4
; Line 196
	call	FAR PTR _fork
	cwd	
	mov	[bp-24],ax	;pid
	mov	[bp-22],dx
	cmp	ax,-1
	je	$SC167
	or	ax,ax
	je	$SC169
	jmp	SHORT $SD177
$SC167:
; Line 198
	push	WORD PTR _empty+2
	push	WORD PTR _empty
	mov	ax,OFFSET DGROUP:$SG168
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 199
$SC169:
; Line 201
	push	WORD PTR 0
	mov	es,$T20030
	push	WORD PTR es:_sortfile+2
	push	WORD PTR es:_sortfile
	mov	ax,OFFSET DGROUP:$SG171
	push	ds
	push	ax
	push	WORD PTR es:_sortfile+2
	push	WORD PTR es:_sortfile
	mov	ax,OFFSET DGROUP:$SG172
	push	ds
	push	ax
	mov	ax,OFFSET DGROUP:$SG173
	push	ds
	push	ax
	mov	ax,OFFSET DGROUP:$SG174
	push	ds
	push	ax
	push	WORD PTR _sortopt+2
	push	WORD PTR _sortopt
	mov	ax,OFFSET DGROUP:$SG175
	push	ds
	push	ax
	mov	ax,OFFSET DGROUP:$SG176
	push	ds
	push	ax
	call	FAR PTR _execl
	add	sp,38
; Line 202
$SD177:
; Line 203
	mov	ax,OFFSET _status
	mov	dx,SEG _status
	push	dx
	push	ax
	call	FAR PTR _wait
	add	sp,4
	cwd	
	cmp	dx,[bp-22]
	jne	$SD177
	cmp	ax,[bp-24]	;pid
	jne	$SD177
; Line 205
	call	FAR PTR _getsort
; Line 206
	mov	es,$T20030
	les	bx,DWORD PTR es:_sortfile
	cmp	BYTE PTR es:[bx],0
	je	$I182
; Line 207
	mov	es,$T20030
	push	WORD PTR es:_sortfile+2
	push	bx
	call	FAR PTR _unlink
	add	sp,4
; Line 208
$I182:
	push	WORD PTR 0
	call	FAR PTR _exit
	add	sp,2
; Line 209
	pop	si
	leave	
	ret	

_main	ENDP
;	s = 6
;	arg = 10
; Line 211
	PUBLIC	_msg
_msg	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 214
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;arg
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;s
	mov	ax,OFFSET DGROUP:$SG189
	push	ds
	push	ax
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
; Line 215
	leave	
	ret	

_msg	ENDP
;	s = 6
;	arg = 10
; Line 218
	PUBLIC	_diag
_diag	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 220
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;arg
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;s
	call	FAR PTR _msg
	add	sp,8
; Line 221
	push	WORD PTR 1
	call	FAR PTR _exit
; Line 222
	leave	
	ret	

_diag	ENDP
; Line 224
	PUBLIC	_getline
_getline	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,12
	call	FAR PTR __chkstk
	push	si
;	endlinep = -4
;	c = -8
;	linep = -12
; Line 228
	mov	ax,WORD PTR _mlen
	add	ax,OFFSET _line
	mov	[bp-4],ax	;endlinep
	mov	[bp-2],SEG _line
; Line 229
	mov	WORD PTR [bp-12],OFFSET _line	;linep
	mov	[bp-10],SEG _line
; Line 231
$WC197:
	les	bx,DWORD PTR _inptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20033
	les	bx,DWORD PTR _inptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	bl,es:[si]
	sub	bh,bh
	sub	cx,cx
	jmp	SHORT $L20034
$L20033:
	push	WORD PTR _inptr+2
	push	WORD PTR _inptr
	call	FAR PTR __filbuf
	add	sp,4
	cwd	
	mov	bx,ax
	mov	cx,dx
$L20034:
	mov	[bp-8],bx	;c
	mov	[bp-6],cx
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$WC197
; Line 233
	cmp	cx,-1
	jne	$I199
	cmp	bx,-1
	jne	$I199
; Line 234
$L20127:
	sub	ax,ax
	cwd	
	jmp	$EX193
$I199:
	push	WORD PTR _inptr+2
	push	WORD PTR _inptr
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;c
	call	FAR PTR _ungetc
	add	sp,8
; Line 236
$WC201:
	les	bx,DWORD PTR _inptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20035
	les	bx,DWORD PTR _inptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	sub	ah,ah
	sub	dx,dx
	jmp	SHORT $L20036
$L20035:
	push	WORD PTR _inptr+2
	push	WORD PTR _inptr
	call	FAR PTR __filbuf
	add	sp,4
	cwd	
$L20036:
	mov	[bp-8],ax	;c
	mov	[bp-6],dx
	cmp	dx,-1
	jne	$L20037
	cmp	ax,-1
	je	$L20127
$L20037:
; Line 237
	mov	ax,[bp-8]	;c
	cmp	ax,9
	je	$SC207
	cmp	ax,10
	je	$SC209
; Line 247
	mov	ax,[bp-4]	;endlinep
	mov	dx,[bp-2]
	cmp	[bp-12],ax	;linep
	jae	$WC201
; Line 248
	les	bx,[bp-12]	;linep
	inc	WORD PTR [bp-12]	;linep
	mov	al,[bp-8]	;c
	mov	es:[bx],al
; Line 249
	jmp	SHORT $WC201
$SC207:
; Line 239
	mov	ax,[bp-4]	;endlinep
	mov	dx,[bp-2]
	cmp	[bp-12],ax	;linep
	jae	$WC201
; Line 240
	les	bx,[bp-12]	;linep
	inc	WORD PTR [bp-12]	;linep
	mov	BYTE PTR es:[bx],32
; Line 250
	jmp	$WC201
$SC209:
; Line 243
	dec	WORD PTR [bp-12]	;linep
	les	bx,[bp-12]	;linep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$SC209
; Line 244
	inc	WORD PTR [bp-12]	;linep
	les	bx,[bp-12]	;linep
	mov	BYTE PTR es:[bx],10
; Line 245
	mov	ax,[bp-12]	;linep
	mov	dx,[bp-10]
$EX193:
	pop	si
	leave	
	ret	

_getline	ENDP
;	pend = 6
; Line 254
	PUBLIC	_cmpline
_cmpline	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,20
	call	FAR PTR __chkstk
;	pstrt = -4
;	cp = -8
;	flag = -12
;	hp = -16
;	pchar = -20
; Line 259
	mov	WORD PTR [bp-20],OFFSET _line	;pchar
	mov	[bp-18],SEG _line
; Line 260
	mov	es,$T20002
	mov	ax,WORD PTR es:_rflag
	or	ax,WORD PTR es:_rflag+2
	je	$WB223
; Line 261
$WC222:
	mov	ax,[bp+6]	;pend
	mov	dx,[bp+8]
	cmp	[bp-20],ax	;pchar
	jae	$WB223
	les	bx,[bp-20]	;pchar
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$WB223
; Line 262
	inc	WORD PTR [bp-20]	;pchar
	jmp	SHORT $WC222
$WB223:
; Line 263
	mov	ax,[bp+6]	;pend
	mov	dx,[bp+8]
	cmp	[bp-20],ax	;pchar
	jb	$JCC2575
	jmp	$WB225
$JCC2575:
; Line 265
	les	bx,[bp-20]	;pchar
	inc	WORD PTR [bp-20]	;pchar
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20017
	cmp	BYTE PTR es:_btable[bx],0
	jne	$WB223
; Line 266
	dec	WORD PTR [bp-20]	;pchar
	mov	ax,[bp-20]	;pchar
	mov	dx,[bp-18]
	mov	[bp-4],ax	;pstrt
	mov	[bp-2],dx
; Line 268
	mov	WORD PTR [bp-12],1	;flag
	mov	WORD PTR [bp-10],0
; Line 269
$WC227:
	mov	ax,[bp-12]	;flag
	or	ax,[bp-10]
	je	$WB223
; Line 270
	les	bx,[bp-20]	;pchar
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20017
	cmp	BYTE PTR es:_btable[bx],0
	jne	$JCC2656
	jmp	$I237
$JCC2656:
; Line 271
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;pchar
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;pstrt
	call	FAR PTR _hash
	add	sp,8
	shl	ax,2
	add	ax,OFFSET _hasht
	mov	[bp-16],ax	;hp
	mov	[bp-14],SEG _hasht
; Line 272
	dec	WORD PTR [bp-20]	;pchar
; Line 273
$WC230:
	les	bx,[bp-16]	;hp
	add	WORD PTR [bp-16],4	;hp
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-8],ax	;cp
	mov	[bp-6],dx
	or	ax,dx
	je	$WB231
; Line 274
	cmp	[bp-14],SEG _hasht
	jne	$I232
	cmp	WORD PTR [bp-16],OFFSET _hasht+8192	;hp
	jne	$I232
; Line 275
	mov	WORD PTR [bp-16],OFFSET _hasht	;hp
	mov	[bp-14],SEG _hasht
; Line 277
$I232:
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;cp
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;pchar
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;pstrt
	call	FAR PTR _cmpword
	add	sp,12
	or	ax,ax
	je	$WC230
; Line 279
	mov	es,$T20009
	mov	ax,WORD PTR es:_ignore
	or	ax,WORD PTR es:_ignore+2
	jne	$I235
	mov	es,$T20007
	mov	ax,WORD PTR es:_only
	or	ax,WORD PTR es:_only+2
	je	$I235
; Line 280
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;pend
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;pstrt
	call	FAR PTR _putline
	add	sp,8
; Line 281
$I235:
	sub	ax,ax
	mov	[bp-10],ax
	mov	[bp-12],ax	;flag
; Line 282
$WB231:
; Line 286
	mov	ax,[bp-12]	;flag
	or	ax,[bp-10]
	je	$I237
; Line 287
	mov	es,$T20009
	mov	ax,WORD PTR es:_ignore
	or	ax,WORD PTR es:_ignore+2
	jne	$I239
	mov	es,$T20007
	mov	ax,WORD PTR es:_only
	or	ax,WORD PTR es:_only+2
	jne	$I238
$I239:
; Line 288
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;pend
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;pstrt
	call	FAR PTR _putline
	add	sp,8
; Line 289
$I238:
	sub	ax,ax
	mov	[bp-10],ax
	mov	[bp-12],ax	;flag
; Line 291
$I237:
; Line 292
	inc	WORD PTR [bp-20]	;pchar
; Line 293
	jmp	$WC227
$WB225:
; Line 295
	leave	
	ret	

_cmpline	ENDP
;	cpp = 6
;	pend = 10
;	hpp = 14
; Line 297
	PUBLIC	_cmpword
_cmpword	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2
	call	FAR PTR __chkstk
;	c = -2
; Line 300
$WC245:
	les	bx,[bp+14]	;hpp
	cmp	BYTE PTR es:[bx],0
	je	$WB246
; Line 301
	les	bx,[bp+6]	;cpp
	inc	WORD PTR [bp+6]	;cpp
	mov	al,es:[bx]
	mov	[bp-2],al	;c
; Line 302
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],1
	je	$L20038
	cbw	
	add	ax,32
	jmp	SHORT $L20039
$L20038:
	mov	al,[bp-2]	;c
	cbw	
$L20039:
	les	bx,[bp+14]	;hpp
	inc	WORD PTR [bp+14]	;hpp
	mov	cx,ax
	mov	al,es:[bx]
	cbw	
	cmp	cx,ax
	je	$WC245
; Line 303
$L20128:
	sub	ax,ax
	jmp	SHORT $EX243
$WB246:
; Line 305
	dec	WORD PTR [bp+6]	;cpp
	mov	ax,[bp+10]	;pend
	mov	dx,[bp+12]
	cmp	[bp+8],dx
	jne	$L20128
	cmp	[bp+6],ax	;cpp
	jne	$L20128
	mov	ax,1
$EX243:
	leave	
	ret	

_cmpword	ENDP
;	strt = 6
;	end = 10
; Line 309
	PUBLIC	_putline
_putline	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
	push	si
;	cp = -4
; Line 312
	mov	ax,[bp+6]	;strt
	mov	dx,[bp+8]
	mov	[bp-4],ax	;cp
	mov	[bp-2],dx
$F253:
	mov	ax,[bp+10]	;end
	mov	dx,[bp+12]
	cmp	[bp-4],ax	;cp
	jb	$JCC3042
	jmp	$FB255
$JCC3042:
; Line 313
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20040
	les	bx,[bp-4]	;cp
	mov	al,es:[bx]
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	es:[si],al
$L20129:
	sub	ah,ah
	sub	dx,dx
	jmp	$L20043
$L20040:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	test	BYTE PTR es:[bx+16],128
	je	$L20042
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	neg	ax
	adc	dx,0
	neg	dx
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	cmp	dx,es:[bx+14]
	jg	$L20042
	jl	$L20047
	cmp	ax,es:[bx+12]
	jae	$L20042
$L20047:
	les	bx,[bp-4]	;cp
	mov	al,es:[bx]
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	es:[bx],al
	cmp	al,10
	je	$L20045
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	jmp	SHORT $L20129
$L20045:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	jmp	SHORT $L20130
$L20042:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	les	bx,[bp-4]	;cp
$L20130:
	mov	al,es:[bx]
	sub	ah,ah
	push	ax
	call	FAR PTR __flsbuf
	add	sp,6
	cwd	
$L20043:
	inc	WORD PTR [bp-4]	;cp
	jmp	$F253
$FB255:
; Line 315
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20048
	mov	al,32
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	es:[si],al
$L20131:
	sub	ah,ah
	sub	dx,dx
	jmp	$L20051
$L20048:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	test	BYTE PTR es:[bx+16],128
	je	$L20050
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	neg	ax
	adc	dx,0
	neg	dx
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	cmp	dx,es:[bx+14]
	jg	$L20050
	jl	$L20055
	cmp	ax,es:[bx+12]
	jae	$L20050
$L20055:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	al,32
	mov	es:[bx],al
	cmp	al,10
	je	$L20053
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	jmp	SHORT $L20131
$L20053:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	al,es:[bx]
	sub	ah,ah
	push	ax
	jmp	SHORT $L20132
$L20050:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	push	WORD PTR 32
$L20132:
	call	FAR PTR __flsbuf
	add	sp,6
	cwd	
$L20051:
; Line 316
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20056
	mov	al,127
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	es:[si],al
$L20133:
	sub	ah,ah
	sub	dx,dx
	jmp	$L20059
$L20056:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	test	BYTE PTR es:[bx+16],128
	je	$L20058
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	neg	ax
	adc	dx,0
	neg	dx
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	cmp	dx,es:[bx+14]
	jg	$L20058
	jl	$L20063
	cmp	ax,es:[bx+12]
	jae	$L20058
$L20063:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	al,127
	mov	es:[bx],al
	cmp	al,10
	je	$L20061
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	jmp	SHORT $L20133
$L20061:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	al,es:[bx]
	sub	ah,ah
	push	ax
	jmp	SHORT $L20134
$L20058:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	push	WORD PTR 127
$L20134:
	call	FAR PTR __flsbuf
	add	sp,6
	cwd	
$L20059:
; Line 317
	mov	WORD PTR [bp-4],OFFSET _line	;cp
	mov	[bp-2],SEG _line
$F258:
	mov	ax,[bp+6]	;strt
	mov	dx,[bp+8]
	cmp	[bp-4],ax	;cp
	jb	$JCC3753
	jmp	$FB260
$JCC3753:
; Line 318
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20064
	les	bx,[bp-4]	;cp
	mov	al,es:[bx]
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	es:[si],al
$L20135:
	sub	ah,ah
	sub	dx,dx
	jmp	$L20067
$L20064:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	test	BYTE PTR es:[bx+16],128
	je	$L20066
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	neg	ax
	adc	dx,0
	neg	dx
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	cmp	dx,es:[bx+14]
	jg	$L20066
	jl	$L20071
	cmp	ax,es:[bx+12]
	jae	$L20066
$L20071:
	les	bx,[bp-4]	;cp
	mov	al,es:[bx]
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	es:[bx],al
	cmp	al,10
	je	$L20069
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	jmp	SHORT $L20135
$L20069:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	jmp	SHORT $L20136
$L20066:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	les	bx,[bp-4]	;cp
$L20136:
	mov	al,es:[bx]
	sub	ah,ah
	push	ax
	call	FAR PTR __flsbuf
	add	sp,6
	cwd	
$L20067:
	inc	WORD PTR [bp-4]	;cp
	jmp	$F258
$FB260:
; Line 319
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20072
	mov	al,10
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	es:[si],al
$L20137:
	sub	ah,ah
	sub	dx,dx
	jmp	$L20075
$L20072:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	test	BYTE PTR es:[bx+16],128
	je	$L20074
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	neg	ax
	adc	dx,0
	neg	dx
	mov	es,$T20031
	mov	es,WORD PTR es:_sortptr+2
	cmp	dx,es:[bx+14]
	jg	$L20074
	jl	$L20079
	cmp	ax,es:[bx+12]
	jae	$L20074
$L20079:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	al,10
	mov	es:[bx],al
	cmp	al,al
	je	$L20077
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	jmp	SHORT $L20137
$L20077:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	les	bx,DWORD PTR es:_sortptr
	les	bx,es:[bx+4]
	mov	al,es:[bx]
	sub	ah,ah
	push	ax
	jmp	SHORT $L20138
$L20074:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	push	WORD PTR 10
$L20138:
	call	FAR PTR __flsbuf
	add	sp,6
	cwd	
$L20075:
; Line 320
	pop	si
	leave	
	ret	

_putline	ENDP
; Line 322
PTX_TEXT      ENDS
CONST      SEGMENT
$T20081	DW SEG _halflen 
CONST      ENDS
PTX_TEXT      SEGMENT
	PUBLIC	_getsort
_getsort	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,52
	call	FAR PTR __chkstk
	push	si
;	c = -4
;	tilde = -8
;	p1a = -12
;	p2a = -16
;	p1b = -20
;	p3a = -24
;	p2b = -28
;	p4a = -32
;	p3b = -36
;	linep = -40
;	w = -44
;	p4b = -48
;	ref = -52
; Line 328
	mov	ax,OFFSET DGROUP:$SG279
	push	ds
	push	ax
	mov	es,$T20030
	push	WORD PTR es:_sortfile+2
	push	WORD PTR es:_sortfile
	call	FAR PTR _fopen
	add	sp,8
	mov	es,$T20031
	mov	WORD PTR es:_sortptr,ax
	mov	WORD PTR es:_sortptr+2,dx
	or	ax,dx
	jne	$I278
; Line 329
	mov	es,$T20030
	push	WORD PTR es:_sortfile+2
	push	WORD PTR es:_sortfile
	mov	ax,OFFSET DGROUP:$SG280
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 330
$I278:
	push	WORD PTR 0
	push	WORD PTR 2
	mov	ax,WORD PTR _llen
	mov	dx,WORD PTR _llen+2
	sub	ax,WORD PTR _gutter
	sbb	dx,WORD PTR _gutter+2
	push	dx
	push	ax
	call	FAR PTR __ldiv
	mov	es,$T20081
	mov	WORD PTR es:_halflen,ax
	mov	WORD PTR es:_halflen+2,dx
; Line 331
$L20140:
	mov	WORD PTR [bp-40],OFFSET _line	;linep
	mov	[bp-38],SEG _line
; Line 332
$WC281:
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20082
	mov	es,$T20031
	les	bx,DWORD PTR es:_sortptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	sub	ah,ah
	sub	dx,dx
	jmp	SHORT $L20083
$L20082:
	mov	es,$T20031
	push	WORD PTR es:_sortptr+2
	push	WORD PTR es:_sortptr
	call	FAR PTR __filbuf
	add	sp,4
	cwd	
$L20083:
	mov	[bp-4],ax	;c
	mov	[bp-2],dx
	cmp	dx,-1
	jne	$L20084
	cmp	ax,-1
	jne	$JCC4448
	jmp	$WB282
$JCC4448:
$L20084:
; Line 333
	mov	ax,[bp-4]	;c
	cmp	ax,10
	je	$L20139
	cmp	ax,34
	jne	$JCC4464
	jmp	$SC315
$JCC4464:
	cmp	ax,127
	je	$JCC4472
	jmp	$SD316
$JCC4472:
; Line 335
	mov	ax,[bp-40]	;linep
	mov	dx,[bp-38]
	mov	[bp-8],ax	;tilde
	mov	[bp-6],dx
; Line 392
	jmp	$WC281
$WC289:
; Line 339
	dec	WORD PTR [bp-40]	;linep
$L20139:
	les	bx,[bp-40]	;linep
	mov	al,es:[bx-1]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$WC289
; Line 340
	mov	ax,[bp-8]	;tilde
	mov	dx,[bp-6]
	mov	[bp-52],ax	;ref
	mov	[bp-50],dx
; Line 341
	mov	es,$T20002
	mov	ax,WORD PTR es:_rflag
	or	ax,WORD PTR es:_rflag+2
	je	$I291
; Line 342
$WC292:
	mov	ax,[bp-40]	;linep
	mov	dx,[bp-38]
	cmp	[bp-52],ax	;ref
	jae	$WB293
	les	bx,[bp-52]	;ref
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$WB293
; Line 343
	inc	WORD PTR [bp-52]	;ref
	jmp	SHORT $WC292
$WB293:
; Line 344
	les	bx,[bp-52]	;ref
	inc	WORD PTR [bp-52]	;ref
	mov	BYTE PTR es:[bx],0
; Line 347
$I291:
	mov	es,$T20081
	mov	ax,WORD PTR es:_halflen
	mov	dx,WORD PTR es:_halflen+2
	sub	ax,1
	sbb	dx,0
	push	dx
	push	ax
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;tilde
	mov	ax,OFFSET _line
	mov	dx,SEG _line
	mov	[bp-24],ax	;p3a
	mov	[bp-22],dx
	push	dx
	push	ax
	call	FAR PTR _rtrim
	add	sp,12
	mov	[bp-36],ax	;p3b
	mov	[bp-34],dx
; Line 348
	sub	ax,[bp-24]	;p3a
	cwd	
	mov	es,$T20081
	mov	cx,WORD PTR es:_halflen
	mov	bx,WORD PTR es:_halflen+2
	sub	cx,1
	sbb	bx,0
	cmp	dx,bx
	jl	$I294
	jg	$L20085
	cmp	ax,cx
	jbe	$I294
$L20085:
; Line 349
	mov	es,$T20081
	mov	ax,WORD PTR es:_halflen
	add	ax,[bp-24]	;p3a
	mov	dx,[bp-22]
	dec	ax
	mov	[bp-36],ax	;p3b
	mov	[bp-34],dx
; Line 350
$I294:
	mov	es,$T20081
	mov	ax,WORD PTR es:_halflen
	mov	dx,WORD PTR es:_halflen+2
	sub	ax,1
	sbb	dx,0
	push	dx
	push	ax
	mov	ax,[bp-40]	;linep
	mov	dx,[bp-38]
	mov	[bp-28],ax	;p2b
	mov	[bp-26],dx
	push	dx
	push	ax
	push	WORD PTR [bp-50]
	push	WORD PTR [bp-52]	;ref
	call	FAR PTR _ltrim
	add	sp,12
	mov	[bp-16],ax	;p2a
	mov	[bp-14],dx
; Line 351
	mov	ax,[bp-28]	;p2b
	sub	ax,[bp-16]	;p2a
	cwd	
	mov	es,$T20081
	mov	cx,WORD PTR es:_halflen
	mov	bx,WORD PTR es:_halflen+2
	sub	cx,1
	sbb	bx,0
	cmp	dx,bx
	jl	$I295
	jg	$L20086
	cmp	ax,cx
	jbe	$I295
$L20086:
; Line 352
	mov	ax,[bp-28]	;p2b
	mov	dx,[bp-26]
	mov	es,$T20081
	sub	ax,WORD PTR es:_halflen
	dec	ax
	mov	[bp-16],ax	;p2a
	mov	[bp-14],dx
; Line 353
$I295:
; Line 354
	mov	ax,[bp-28]	;p2b
	sub	ax,[bp-16]	;p2a
	cwd	
	mov	es,$T20081
	mov	cx,WORD PTR es:_halflen
	mov	bx,WORD PTR es:_halflen+2
	sub	cx,ax
	sbb	bx,dx
	sub	cx,WORD PTR _gap
	sbb	bx,WORD PTR _gap+2
	mov	[bp-44],cx	;w
	mov	[bp-42],bx
	push	bx
	push	cx
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;tilde
	les	bx,[bp-36]	;p3b
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	je	$L20087
	mov	ax,1
	jmp	SHORT $L20088
$L20087:
	sub	ax,ax
$L20088:
	add	ax,[bp-36]	;p3b
	mov	dx,[bp-34]
	mov	[bp-12],ax	;p1a
	mov	[bp-10],dx
	push	dx
	push	ax
	call	FAR PTR _rtrim
	add	sp,12
	mov	[bp-20],ax	;p1b
	mov	[bp-18],dx
; Line 355
	sub	ax,[bp-12]	;p1a
	cwd	
	cmp	dx,[bp-42]
	jl	$I296
	jg	$L20089
	cmp	ax,[bp-44]	;w
	jbe	$I296
$L20089:
; Line 356
	mov	ax,[bp-12]	;p1a
	mov	dx,[bp-10]
	mov	[bp-20],ax	;p1b
	mov	[bp-18],dx
; Line 357
$I296:
; Line 358
	mov	ax,[bp-36]	;p3b
	sub	ax,[bp-24]	;p3a
	cwd	
	mov	es,$T20081
	mov	cx,WORD PTR es:_halflen
	mov	bx,WORD PTR es:_halflen+2
	sub	cx,ax
	sbb	bx,dx
	sub	cx,WORD PTR _gap
	sbb	bx,WORD PTR _gap+2
	mov	[bp-44],cx	;w
	mov	[bp-42],bx
	push	bx
	push	cx
	les	bx,[bp-16]	;p2a
	mov	al,es:[bx-1]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	je	$L20090
	mov	ax,1
	jmp	SHORT $L20091
$L20090:
	sub	ax,ax
$L20091:
	mov	cx,[bp-16]	;p2a
	mov	bx,[bp-14]
	sub	cx,ax
	mov	[bp-48],cx	;p4b
	mov	[bp-46],bx
	push	bx
	push	cx
	push	WORD PTR [bp-50]
	push	WORD PTR [bp-52]	;ref
	call	FAR PTR _ltrim
	add	sp,12
	mov	[bp-32],ax	;p4a
	mov	[bp-30],dx
; Line 359
	mov	ax,[bp-48]	;p4b
	sub	ax,[bp-32]	;p4a
	cwd	
	cmp	dx,[bp-42]
	jl	$I297
	jg	$L20092
	cmp	ax,[bp-44]	;w
	jbe	$I297
$L20092:
; Line 360
	mov	ax,[bp-48]	;p4b
	mov	dx,[bp-46]
	mov	[bp-32],ax	;p4a
	mov	[bp-30],dx
; Line 361
$I297:
	mov	ax,OFFSET DGROUP:$SG298
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 362
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;p1b
	push	WORD PTR [bp-10]
	push	WORD PTR [bp-12]	;p1a
	call	FAR PTR _putout
	add	sp,8
; Line 364
	mov	ax,[bp-8]	;tilde
	mov	dx,[bp-6]
	dec	ax
	cmp	dx,[bp-18]
	jne	$L20093
	cmp	ax,[bp-20]	;p1b
	je	$I300
$L20093:
	mov	ax,[bp-20]	;p1b
	mov	dx,[bp-18]
	cmp	[bp-10],dx
	jne	$L20094
	cmp	[bp-12],ax	;p1a
	je	$I300
$L20094:
; Line 365
	mov	ax,OFFSET DGROUP:$SG301
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 366
$I300:
	mov	ax,OFFSET DGROUP:$SG302
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 367
	mov	ax,[bp-48]	;p4b
	mov	dx,[bp-46]
	cmp	[bp-30],dx
	jne	$I303
	cmp	[bp-32],ax	;p4a
	jne	$I303
	mov	ax,[bp-52]	;ref
	mov	dx,[bp-50]
	cmp	[bp-14],dx
	jne	$L20095
	cmp	[bp-16],ax	;p2a
	je	$I303
$L20095:
	mov	ax,[bp-28]	;p2b
	mov	dx,[bp-26]
	cmp	[bp-14],dx
	jne	$L20096
	cmp	[bp-16],ax	;p2a
	je	$I303
$L20096:
; Line 368
	mov	ax,OFFSET DGROUP:$SG304
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 369
$I303:
	push	WORD PTR [bp-26]
	push	WORD PTR [bp-28]	;p2b
	push	WORD PTR [bp-14]
	push	WORD PTR [bp-16]	;p2a
	call	FAR PTR _putout
	add	sp,8
; Line 370
	mov	ax,OFFSET DGROUP:$SG305
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 371
	push	WORD PTR [bp-34]
	push	WORD PTR [bp-36]	;p3b
	push	WORD PTR [bp-22]
	push	WORD PTR [bp-24]	;p3a
	call	FAR PTR _putout
	add	sp,8
; Line 374
	mov	ax,[bp-20]	;p1b
	mov	dx,[bp-18]
	cmp	[bp-10],dx
	jne	$I306
	cmp	[bp-12],ax	;p1a
	jne	$I306
	inc	WORD PTR [bp-36]	;p3b
	mov	ax,[bp-8]	;tilde
	mov	dx,[bp-6]
	cmp	[bp-34],dx
	jne	$L20097
	cmp	[bp-36],ax	;p3b
	je	$I306
$L20097:
; Line 375
	mov	ax,OFFSET DGROUP:$SG307
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 376
$I306:
	mov	ax,OFFSET DGROUP:$SG308
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 377
	mov	ax,[bp-20]	;p1b
	mov	dx,[bp-18]
	cmp	[bp-10],dx
	jne	$I309
	cmp	[bp-12],ax	;p1a
	jne	$I309
	mov	ax,[bp-52]	;ref
	mov	dx,[bp-50]
	cmp	[bp-30],dx
	jne	$L20098
	cmp	[bp-32],ax	;p4a
	je	$I309
$L20098:
	mov	ax,[bp-48]	;p4b
	mov	dx,[bp-46]
	cmp	[bp-30],dx
	jne	$L20099
	cmp	[bp-32],ax	;p4a
	je	$I309
$L20099:
; Line 378
	mov	ax,OFFSET DGROUP:$SG310
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
; Line 379
$I309:
	push	WORD PTR [bp-46]
	push	WORD PTR [bp-48]	;p4b
	push	WORD PTR [bp-30]
	push	WORD PTR [bp-32]	;p4a
	call	FAR PTR _putout
	add	sp,8
; Line 380
	mov	es,$T20002
	mov	ax,WORD PTR es:_rflag
	or	ax,WORD PTR es:_rflag+2
	je	$I311
; Line 381
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;tilde
	mov	ax,OFFSET DGROUP:$SG312
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,12
; Line 382
	jmp	$L20140
$I311:
; Line 383
	mov	ax,OFFSET DGROUP:$SG314
	push	ds
	push	ax
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	call	FAR PTR _fprintf
	add	sp,8
	jmp	$L20140
$SC315:
; Line 388
	les	bx,[bp-40]	;linep
	inc	WORD PTR [bp-40]	;linep
	mov	al,[bp-4]	;c
	mov	es:[bx],al
; Line 389
$SD316:
; Line 390
	les	bx,[bp-40]	;linep
	inc	WORD PTR [bp-40]	;linep
	mov	al,[bp-4]	;c
	mov	es:[bx],al
; Line 391
	jmp	$WC281
$WB282:
; Line 393
	pop	si
	leave	
	ret	

_getsort	ENDP
;	a = 6
;	c = 10
;	d = 14
; Line 395
	PUBLIC	_rtrim
_rtrim	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
;	x = -4
;	b = -8
; Line 398
	mov	ax,[bp+10]	;c
	mov	dx,[bp+12]
	mov	[bp-8],ax	;b
	mov	[bp-6],dx
; Line 399
	mov	ax,[bp+6]	;a
	mov	dx,[bp+8]
	inc	ax
	mov	[bp-4],ax	;x
	mov	[bp-2],dx
$F323:
	mov	ax,[bp+10]	;c
	mov	dx,[bp+12]
	cmp	[bp-4],ax	;x
	ja	$FB325
	mov	ax,[bp-4]	;x
	sub	ax,[bp+6]	;a
	cmp	ax,[bp+14]	;d
	jg	$FB325
; Line 400
	mov	ax,[bp+10]	;c
	cmp	[bp-2],dx
	jne	$L20100
	cmp	[bp-4],ax	;x
	je	$I328
$L20100:
	les	bx,[bp-4]	;x
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	je	$FC324
$I328:
	les	bx,[bp-4]	;x
	mov	al,es:[bx-1]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$FC324
; Line 401
	mov	ax,[bp-4]	;x
	mov	dx,[bp-2]
	mov	[bp-8],ax	;b
	mov	[bp-6],dx
; Line 402
$FC324:
	inc	WORD PTR [bp-4]	;x
	jmp	SHORT $F323
$FB325:
	mov	ax,[bp+10]	;c
	mov	dx,[bp+12]
	cmp	[bp-8],ax	;b
	jae	$I329
	les	bx,[bp-8]	;b
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$I329
; Line 403
	inc	WORD PTR [bp-8]	;b
; Line 404
$I329:
	mov	ax,[bp-8]	;b
	mov	dx,[bp-6]
	leave	
	ret	

_rtrim	ENDP
;	c = 6
;	b = 10
;	d = 14
; Line 407
	PUBLIC	_ltrim
_ltrim	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
;	a = -4
;	x = -8
; Line 410
	mov	ax,[bp+6]	;c
	mov	dx,[bp+8]
	mov	[bp-4],ax	;a
	mov	[bp-2],dx
; Line 411
	mov	ax,[bp+10]	;b
	mov	dx,[bp+12]
	dec	ax
	mov	[bp-8],ax	;x
	mov	[bp-6],dx
$F336:
	mov	ax,[bp+6]	;c
	mov	dx,[bp+8]
	cmp	[bp-8],ax	;x
	jb	$FB338
	mov	ax,[bp+10]	;b
	sub	ax,[bp-8]	;x
	cmp	ax,[bp+14]	;d
	jg	$FB338
; Line 412
	les	bx,[bp-8]	;x
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$FC337
	mov	ax,[bp+6]	;c
	cmp	[bp-6],dx
	jne	$L20101
	cmp	[bp-8],ax	;x
	je	$I341
$L20101:
	les	bx,[bp-8]	;x
	mov	al,es:[bx-1]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	je	$FC337
$I341:
; Line 413
	mov	ax,[bp-8]	;x
	mov	dx,[bp-6]
	mov	[bp-4],ax	;a
	mov	[bp-2],dx
; Line 414
$FC337:
	dec	WORD PTR [bp-8]	;x
	jmp	SHORT $F336
$FB338:
	mov	ax,[bp+6]	;c
	mov	dx,[bp+8]
	cmp	[bp-4],ax	;a
	jbe	$I342
	les	bx,[bp-4]	;a
	mov	al,es:[bx-1]
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],8
	jne	$I342
; Line 415
	dec	WORD PTR [bp-4]	;a
; Line 416
$I342:
	mov	ax,[bp-4]	;a
	mov	dx,[bp-2]
	leave	
	ret	

_ltrim	ENDP
;	strt = 6
;	end = 10
; Line 419
	PUBLIC	_putout
_putout	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
	push	si
;	cp = -4
; Line 422
	mov	ax,[bp+6]	;strt
	mov	dx,[bp+8]
	mov	[bp-4],ax	;cp
	mov	[bp-2],dx
; Line 423
$F347:
	mov	ax,[bp+10]	;end
	mov	dx,[bp+12]
	cmp	[bp-4],ax	;cp
	jb	$JCC5976
	jmp	$FB349
$JCC5976:
; Line 424
	les	bx,DWORD PTR _outptr
	sub	WORD PTR es:[bx],1
	sbb	WORD PTR es:[bx+2],0
	cmp	WORD PTR es:[bx+2],0
	jl	$L20102
	les	bx,[bp-4]	;cp
	mov	al,es:[bx]
	les	bx,DWORD PTR _outptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	es:[si],al
$L20141:
	sub	ah,ah
	sub	dx,dx
	jmp	SHORT $L20105
$L20102:
	les	bx,DWORD PTR _outptr
	test	BYTE PTR es:[bx+16],128
	je	$L20104
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	neg	ax
	adc	dx,0
	neg	dx
	cmp	dx,es:[bx+14]
	jg	$L20104
	jl	$L20109
	cmp	ax,es:[bx+12]
	jae	$L20104
$L20109:
	les	bx,[bp-4]	;cp
	mov	al,es:[bx]
	les	bx,DWORD PTR _outptr
	les	bx,es:[bx+4]
	mov	es:[bx],al
	cmp	al,10
	je	$L20107
	les	bx,DWORD PTR _outptr
	mov	si,es:[bx+4]
	inc	WORD PTR es:[bx+4]
	mov	es,es:[bx+6]
	mov	al,es:[si]
	jmp	SHORT $L20141
$L20107:
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	les	bx,DWORD PTR _outptr
	les	bx,es:[bx+4]
	jmp	SHORT $L20142
$L20104:
	push	WORD PTR _outptr+2
	push	WORD PTR _outptr
	les	bx,[bp-4]	;cp
$L20142:
	mov	al,es:[bx]
	sub	ah,ah
	push	ax
	call	FAR PTR __flsbuf
	add	sp,6
	cwd	
$L20105:
; Line 425
	inc	WORD PTR [bp-4]	;cp
	jmp	$F347
$FB349:
; Line 426
	pop	si
	leave	
	ret	

_putout	ENDP
; Line 428
	PUBLIC	_onlongr
_onlongr	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 429
	mov	es,$T20030
	les	bx,DWORD PTR es:_sortfile
	cmp	BYTE PTR es:[bx],0
	je	$I352
; Line 430
	mov	es,$T20030
	push	WORD PTR es:_sortfile+2
	push	bx
	call	FAR PTR _unlink
	add	sp,4
; Line 431
$I352:
	push	WORD PTR 1
	call	FAR PTR _exit
; Line 432
	leave	
	ret	

_onlongr	ENDP
;	strtp = 6
;	endp = 10
; Line 434
	PUBLIC	_hash
_hash	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,18
	call	FAR PTR __chkstk
;	c = -2
;	cp = -6
;	i = -10
;	j = -14
;	k = -18
; Line 439
	mov	ax,[bp+10]	;endp
	sub	ax,[bp+6]	;strtp
	cmp	ax,1
	jne	$I361
; Line 440
	sub	ax,ax
	jmp	$EX355
$I361:
	mov	ax,[bp+6]	;strtp
	mov	dx,[bp+8]
	mov	[bp-6],ax	;cp
	mov	[bp-4],dx
; Line 442
	les	bx,[bp-6]	;cp
	inc	WORD PTR [bp-6]	;cp
	mov	al,es:[bx]
	mov	[bp-2],al	;c
; Line 443
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],1
	je	$L20110
	cbw	
	add	ax,32
	jmp	SHORT $L20143
$L20110:
	mov	al,[bp-2]	;c
	cbw	
$L20143:
	cwd	
	mov	[bp-10],ax	;i
	mov	[bp-8],dx
; Line 444
	les	bx,[bp-6]	;cp
	mov	al,es:[bx]
	mov	[bp-2],al	;c
; Line 445
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],1
	je	$L20112
	cbw	
	add	ax,32
	jmp	SHORT $L20144
$L20112:
	mov	al,[bp-2]	;c
	cbw	
$L20144:
	cwd	
	mov	[bp-14],ax	;j
	mov	[bp-12],dx
; Line 446
	push	dx
	push	ax
	lea	ax,[bp-10]	;i
	push	ss
	push	ax
	call	FAR PTR __almul
; Line 447
	dec	WORD PTR [bp+10]	;endp
	mov	ax,[bp+10]	;endp
	mov	dx,[bp+12]
	mov	[bp-6],ax	;cp
	mov	[bp-4],dx
; Line 448
	les	bx,[bp-6]	;cp
	dec	WORD PTR [bp-6]	;cp
	mov	al,es:[bx]
	mov	[bp-2],al	;c
; Line 449
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],1
	je	$L20115
	cbw	
	add	ax,32
	jmp	SHORT $L20145
$L20115:
	mov	al,[bp-2]	;c
	cbw	
$L20145:
	cwd	
	mov	[bp-18],ax	;k
	mov	[bp-16],dx
; Line 450
	les	bx,[bp-6]	;cp
	mov	al,es:[bx]
	mov	[bp-2],al	;c
; Line 451
	cbw	
	mov	bx,ax
	mov	es,$T20029
	test	BYTE PTR es:__ctype_[bx+1],1
	je	$L20117
	cbw	
	add	ax,32
	jmp	SHORT $L20146
$L20117:
	mov	al,[bp-2]	;c
	cbw	
$L20146:
	cwd	
	mov	[bp-14],ax	;j
	mov	[bp-12],dx
; Line 452
	push	WORD PTR [bp-16]
	push	WORD PTR [bp-18]	;k
	lea	ax,[bp-14]	;j
	push	ss
	push	ax
	call	FAR PTR __almul
; Line 453
	mov	ax,[bp-14]	;j
	mov	dx,[bp-12]
	mov	cl,2
	call	FAR PTR __lshr
	xor	ax,[bp-10]	;i
	xor	dx,[bp-8]
	and	ah,7
	sub	dx,dx
	mov	[bp-18],ax	;k
	mov	[bp-16],dx
; Line 454
$EX355:
	leave	
	ret	

_hash	ENDP
;	num = 6
PTX_TEXT      ENDS
CONST      SEGMENT
$T20121	DW SEG _hasht 
CONST      ENDS
PTX_TEXT      SEGMENT
;	strtp = 10
; Line 457
	PUBLIC	_storeh
_storeh	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	i = -4
; Line 461
	mov	ax,[bp+6]	;num
	mov	dx,[bp+8]
	mov	[bp-4],ax	;i
	mov	[bp-2],dx
$F366:
	cmp	WORD PTR [bp-2],0
	jg	$FB368
	jl	$F369
	cmp	WORD PTR [bp-4],2048	;i
	jae	$FB368
$F369:
; Line 462
	mov	bx,[bp-4]	;i
	shl	bx,2
	mov	es,$T20121
	mov	ax,WORD PTR es:_hasht[bx]
	or	ax,WORD PTR es:_hasht[bx+2]
	jne	$I370
; Line 463
$L20147:
	mov	bx,[bp-4]	;i
	shl	bx,2
	mov	ax,[bp+10]	;strtp
	mov	dx,[bp+12]
	mov	WORD PTR es:_hasht[bx],ax
	mov	WORD PTR es:_hasht[bx+2],dx
; Line 464
	sub	ax,ax
	jmp	SHORT $EX364
$I370:
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
	jmp	SHORT $F366
$FB368:
; Line 467
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;i
$F371:
	mov	ax,[bp+6]	;num
	mov	dx,[bp+8]
	cmp	[bp-2],dx
	jg	$FB373
	jl	$F374
	cmp	[bp-4],ax	;i
	jae	$FB373
$F374:
; Line 468
	mov	bx,[bp-4]	;i
	shl	bx,2
	mov	es,$T20121
	mov	ax,WORD PTR es:_hasht[bx]
	or	ax,WORD PTR es:_hasht[bx+2]
	je	$L20147
	add	WORD PTR [bp-4],1	;i
	adc	WORD PTR [bp-2],0
	jmp	SHORT $F371
$FB373:
; Line 473
	mov	ax,1
$EX364:
	leave	
	ret	

_storeh	ENDP
PTX_TEXT	ENDS
END
