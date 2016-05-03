;	Static Name Aliases
;
;	$S7_sccsid	EQU	sccsid
	TITLE   grep

	.286p
	.287
GREP_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
GREP_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: GREP_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _hflag
PUBLIC  _retcode
PUBLIC  _bittab
EXTRN	_exit:FAR
EXTRN	_fseek:FAR
EXTRN	_freopen:FAR
EXTRN	__chkstk:FAR
EXTRN	_fprintf:FAR
EXTRN	_perror:FAR
EXTRN	__filbuf:FAR
EXTRN	_printf:FAR
EXTRN	__lshr:FAR
EXTRN	_fflush:FAR
EXTRN	__iob:BYTE
EXTRN	__ctype_:BYTE
EXTRN	_expbuf:BYTE
EXTRN	_lnum:DWORD
EXTRN	_linebuf:BYTE
EXTRN	_ybuf:BYTE
EXTRN	_bflag:DWORD
EXTRN	_lflag:DWORD
EXTRN	_nflag:DWORD
EXTRN	_cflag:DWORD
EXTRN	_vflag:DWORD
EXTRN	_nfile:DWORD
EXTRN	_sflag:DWORD
EXTRN	_yflag:DWORD
EXTRN	_wflag:DWORD
EXTRN	_circf:DWORD
EXTRN	_blkno:DWORD
EXTRN	_tln:DWORD
EXTRN	_nsucc:DWORD
EXTRN	_braslist:BYTE
EXTRN	_braelist:BYTE
_DATA      SEGMENT
$SG70	DB	'grep: unknown flag',  0aH,  00H
$SG89	DB	'grep: argument too long',  0aH,  00H
	EVEN
$SG159	DB	'grep: RE error',  0aH,  00H
$SG167	DB	'r',  00H
$SG179	DB	'%s:',  00H
$SG180	DB	'%D',  0aH,  00H
$SG267	DB	'grep RE botch',  0aH,  00H
	EVEN
$SG273	DB	'%s',  0aH,  00H
$SG276	DB	'%s:',  00H
$SG278	DB	'%u:',  00H
$SG280	DB	'%ld:',  00H
	EVEN
$SG281	DB	'%s',  0aH,  00H
$S7_sccsid	DB	'@(#)grep.c',  09H, '4.6 (Berkeley) 5/14/84',  00H
	PUBLIC	_hflag
_hflag	DD	01H
	PUBLIC	_retcode
_retcode	DD	00H
	PUBLIC	_bittab
_bittab	DB	01H
	DB	02H
	DB	04H
	DB	08H
	DB	010H
	DB	020H
	DB	040H
	DB	080H
;	.comm _expbuf,0100H
;	.comm _lnum,04H
;	.comm _linebuf,0401H
	EVEN
;	.comm _ybuf,0100H
;	.comm _bflag,04H
;	.comm _lflag,04H
;	.comm _nflag,04H
;	.comm _cflag,04H
;	.comm _vflag,04H
;	.comm _nfile,04H
;	.comm _sflag,04H
;	.comm _yflag,04H
;	.comm _wflag,04H
;	.comm _circf,04H
;	.comm _blkno,04H
;	.comm _tln,04H
;	.comm _nsucc,04H
;	.comm _braslist,024H
;	.comm _braelist,024H
_DATA      ENDS
GREP_TEXT      SEGMENT
;	argc = 6
GREP_TEXT      ENDS
CONST      SEGMENT
$T20001	DW SEG _yflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20002	DW SEG _wflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20003	DW SEG _sflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20004	DW SEG _vflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20005	DW SEG _bflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20006	DW SEG _lflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20007	DW SEG _cflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20008	DW SEG _nflag 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20010	DW SEG __ctype_ 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20011	DW SEG _nfile 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20016	DW SEG _nsucc 
CONST      ENDS
GREP_TEXT      SEGMENT
;	argv = 8
; Line 51
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,8
	call	FAR PTR __chkstk
; Line 53
	jmp	$L20038
$WC51:
	add	WORD PTR [bp+8],4	;argv
	les	bx,[bp+8]	;argv
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],45
	je	$JCC28
	jmp	$WB52
$JCC28:
; Line 54
	les	bx,[bp+8]	;argv
	les	bx,es:[bx]
	mov	al,es:[bx+1]
	cbw	
	sub	ax,98
	cmp	ax,23
	jbe	$JCC50
	jmp	$SD68
$JCC50:
	add	ax,ax
	xchg	ax,bx
	jmp	WORD PTR cs:$L20009[bx]
$SC57:
; Line 57
	mov	es,$T20001
	add	WORD PTR es:_yflag,1
	adc	WORD PTR es:_yflag+2,0
; Line 58
	jmp	$L20038
$SC58:
; Line 60
	mov	es,$T20002
	add	WORD PTR es:_wflag,1
	adc	WORD PTR es:_wflag+2,0
; Line 61
	jmp	$L20038
$SC59:
; Line 63
	sub	ax,ax
	mov	WORD PTR _hflag+2,ax
	mov	WORD PTR _hflag,ax
; Line 64
	jmp	$L20038
$SC60:
; Line 66
	mov	es,$T20003
	add	WORD PTR es:_sflag,1
	adc	WORD PTR es:_sflag+2,0
; Line 67
	jmp	$L20038
$SC61:
; Line 69
	mov	es,$T20004
	add	WORD PTR es:_vflag,1
	adc	WORD PTR es:_vflag+2,0
; Line 70
	jmp	$L20038
$SC62:
; Line 72
	mov	es,$T20005
	add	WORD PTR es:_bflag,1
	adc	WORD PTR es:_bflag+2,0
; Line 73
	jmp	$L20038
$SC63:
; Line 75
	mov	es,$T20006
	add	WORD PTR es:_lflag,1
	adc	WORD PTR es:_lflag+2,0
; Line 76
	jmp	SHORT $L20038
$SC64:
; Line 78
	mov	es,$T20007
	add	WORD PTR es:_cflag,1
	adc	WORD PTR es:_cflag+2,0
; Line 79
	jmp	SHORT $L20038
$SC65:
; Line 81
	mov	es,$T20008
	add	WORD PTR es:_nflag,1
	adc	WORD PTR es:_nflag+2,0
; Line 82
	jmp	SHORT $L20038
$SC66:
; Line 84
	dec	WORD PTR [bp+6]	;argc
; Line 85
	add	WORD PTR [bp+8],4	;argv
; Line 86
	jmp	SHORT $WB52
$SD68:
; Line 88
	push	WORD PTR 0
	push	WORD PTR 0
	mov	ax,OFFSET DGROUP:$SG70
	push	ds
	push	ax
	call	FAR PTR _errexit
	add	sp,8
; Line 89
	jmp	SHORT $L20038
$L20009:
		DW	$SC62
		DW	$SC64
		DW	$SD68
		DW	$SC66
		DW	$SD68
		DW	$SD68
		DW	$SC59
		DW	$SC57
		DW	$SD68
		DW	$SD68
		DW	$SC63
		DW	$SD68
		DW	$SC65
		DW	$SD68
		DW	$SD68
		DW	$SD68
		DW	$SD68
		DW	$SC60
		DW	$SD68
		DW	$SD68
		DW	$SC61
		DW	$SC58
		DW	$SD68
		DW	$SC57
$L20038:
	dec	WORD PTR [bp+6]	;argc
	cmp	WORD PTR [bp+6],0	;argc
	jle	$JCC306
	jmp	$WC51
$JCC306:
$WB52:
; Line 92
	cmp	WORD PTR [bp+6],0	;argc
	jg	$I71
; Line 93
	push	WORD PTR 2
	call	FAR PTR _exit
	add	sp,2
; Line 94
;	p = -4
;	s = -8
$I71:
	mov	es,$T20001
	mov	ax,WORD PTR es:_yflag
	or	ax,WORD PTR es:_yflag+2
	jne	$JCC340
	jmp	$I73
$JCC340:
; Line 96
	mov	WORD PTR [bp-8],OFFSET _ybuf	;s
	mov	[bp-6],SEG _ybuf
	les	bx,[bp+8]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-4],ax	;p
	mov	[bp-2],dx
	jmp	$L20039
$F76:
; Line 97
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],92
	jne	$I79
; Line 98
	inc	WORD PTR [bp-4]	;p
	mov	al,es:[bx]
	les	bx,[bp-8]	;s
	inc	WORD PTR [bp-8]	;s
	mov	es:[bx],al
; Line 99
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],0
	jne	$JCC405
	jmp	$I87
$JCC405:
	jmp	SHORT $L20041
$I79:
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],91
	jne	$I82
; Line 102
$WC83:
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],0
	je	$I87
	cmp	BYTE PTR es:[bx],93
	je	$I87
; Line 103
	inc	WORD PTR [bp-4]	;p
	mov	al,es:[bx]
	les	bx,[bp-8]	;s
	inc	WORD PTR [bp-8]	;s
	mov	es:[bx],al
	jmp	SHORT $WC83
$I82:
	les	bx,[bp-4]	;p
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20010
	test	BYTE PTR es:__ctype_[bx+1],2
	je	$I86
; Line 105
	les	bx,[bp-8]	;s
	inc	WORD PTR [bp-8]	;s
	mov	BYTE PTR es:[bx],91
; Line 106
	les	bx,[bp-4]	;p
	mov	al,es:[bx]
	sub	al,32
	les	bx,[bp-8]	;s
	inc	WORD PTR [bp-8]	;s
	mov	es:[bx],al
; Line 107
	les	bx,[bp-4]	;p
	inc	WORD PTR [bp-4]	;p
	mov	al,es:[bx]
	les	bx,[bp-8]	;s
	inc	WORD PTR [bp-8]	;s
	mov	es:[bx],al
; Line 108
	les	bx,[bp-8]	;s
	inc	WORD PTR [bp-8]	;s
	mov	BYTE PTR es:[bx],93
; Line 109
	jmp	SHORT $I87
$I86:
; Line 110
	les	bx,[bp-4]	;p
$L20041:
	inc	WORD PTR [bp-4]	;p
	mov	al,es:[bx]
	les	bx,[bp-8]	;s
	inc	WORD PTR [bp-8]	;s
	mov	es:[bx],al
$I87:
; Line 111
	mov	ax,OFFSET _ybuf+256
	mov	dx,SEG _ybuf
	sub	ax,5
	cmp	ax,[bp-8]	;s
	ja	$L20039
; Line 112
	push	WORD PTR 0
	push	WORD PTR 0
	mov	ax,OFFSET DGROUP:$SG89
	push	ds
	push	ax
	call	FAR PTR _errexit
	add	sp,8
; Line 113
$L20039:
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],0
	je	$JCC587
	jmp	$F76
$JCC587:
; Line 114
	les	bx,[bp-8]	;s
	mov	BYTE PTR es:[bx],0
; Line 115
	les	bx,[bp+8]	;argv
	mov	WORD PTR es:[bx],OFFSET _ybuf
	mov	es:[bx+2],SEG _ybuf
; Line 117
$I73:
	les	bx,[bp+8]	;argv
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _compile
	add	sp,4
; Line 118
	dec	WORD PTR [bp+6]	;argc
	mov	ax,[bp+6]	;argc
	cwd	
	mov	es,$T20011
	mov	WORD PTR es:_nfile,ax
	mov	WORD PTR es:_nfile+2,dx
; Line 119
	or	ax,ax
	jg	$L20040
; Line 120
	mov	es,$T20006
	mov	ax,WORD PTR es:_lflag
	or	ax,WORD PTR es:_lflag+2
	je	$I92
; Line 121
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 122
$I92:
	push	WORD PTR 0
	push	WORD PTR 0
	call	FAR PTR _execute
	add	sp,4
; Line 123
	jmp	SHORT $I94
$WC95:
; Line 124
	add	WORD PTR [bp+8],4	;argv
; Line 125
	les	bx,[bp+8]	;argv
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _execute
	add	sp,4
; Line 126
$L20040:
	dec	WORD PTR [bp+6]	;argc
	cmp	WORD PTR [bp+6],0	;argc
	jge	$WC95
$I94:
; Line 127
	mov	ax,WORD PTR _retcode
	or	ax,WORD PTR _retcode+2
	je	$L20012
	mov	ax,WORD PTR _retcode
	mov	dx,WORD PTR _retcode+2
	jmp	SHORT $L20013
$L20012:
	mov	es,$T20016
	mov	ax,WORD PTR es:_nsucc
	or	ax,WORD PTR es:_nsucc+2
	jne	$L20014
	mov	ax,1
	jmp	SHORT $L20015
$L20014:
	sub	ax,ax
$L20015:
	cwd	
$L20013:
	push	dx
	push	ax
	call	FAR PTR _exit
; Line 128
	leave	
	ret	

_main	ENDP
;	astr = 6
GREP_TEXT      ENDS
CONST      SEGMENT
$T20017	DW SEG _circf 
CONST      ENDS
GREP_TEXT      SEGMENT
; Line 130
	PUBLIC	_compile
_compile	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,46
	call	FAR PTR __chkstk
	push	di
	push	si
;	lastep = -4
;	c = -8
;	cclcnt = -12
;	ep = -16
;	neg = -18
;	bracket = -28
;	numbra = -30
;	closed = -34
;	sp = -38
;	bracketp = -42
;	cstart = -46
; Line 141
	mov	WORD PTR [bp-16],OFFSET _expbuf	;ep
	mov	[bp-14],SEG _expbuf
; Line 142
	mov	ax,[bp+6]	;astr
	mov	dx,[bp+8]
	mov	[bp-38],ax	;sp
	mov	[bp-36],dx
; Line 143
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;lastep
; Line 144
	lea	ax,[bp-28]	;bracket
	mov	[bp-42],ax	;bracketp
	mov	[bp-40],ss
; Line 145
	sub	al,al
	mov	[bp-30],al	;numbra
	cbw	
	cwd	
	mov	[bp-34],ax	;closed
	mov	[bp-32],dx
; Line 146
	les	bx,[bp-38]	;sp
	cmp	BYTE PTR es:[bx],94
	jne	$I110
; Line 147
	mov	es,$T20017
	add	WORD PTR es:_circf,1
	adc	WORD PTR es:_circf+2,0
; Line 148
	inc	WORD PTR [bp-38]	;sp
; Line 150
$I110:
	mov	es,$T20002
	mov	ax,WORD PTR es:_wflag
	or	ax,WORD PTR es:_wflag+2
	je	$I111
; Line 151
$L20043:
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],14
; Line 152
$I111:
; Line 153
	cmp	WORD PTR [bp-16],OFFSET _expbuf+256	;ep
	jb	$JCC898
	jmp	$cerror116
$JCC898:
; Line 154
	les	bx,[bp-38]	;sp
	inc	WORD PTR [bp-38]	;sp
	mov	al,es:[bx]
	cbw	
	cwd	
	mov	[bp-8],ax	;c
	mov	[bp-6],dx
	or	dx,dx
	jne	$L20018
	cmp	ax,42
	je	$I117
$L20018:
; Line 156
	mov	ax,[bp-16]	;ep
	mov	dx,[bp-14]
	mov	[bp-4],ax	;lastep
	mov	[bp-2],dx
; Line 157
$I117:
	mov	ax,[bp-8]	;c
	or	ax,ax
	je	$SC122
	cmp	ax,36
	jne	$JCC951
	jmp	$SC129
$JCC951:
	cmp	ax,42
	je	$SC125
	cmp	ax,46
	je	$SC124
	cmp	ax,91
	jne	$JCC969
	jmp	$SC131
$JCC969:
	cmp	ax,92
	jne	$JCC977
	jmp	$SC148
$JCC977:
$I156:
; Line 242
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],2
; Line 243
$L20045:
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	al,[bp-8]	;c
	jmp	$L20042
$SC122:
; Line 159
	mov	es,$T20002
	mov	ax,WORD PTR es:_wflag
	or	ax,WORD PTR es:_wflag+2
	je	$I123
; Line 160
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],15
; Line 161
$I123:
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],11
; Line 162
	jmp	$EX98
$SC124:
; Line 164
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],4
; Line 165
	jmp	$I111
$SC125:
; Line 168
	mov	ax,[bp-4]	;lastep
	or	ax,[bp-2]
	je	$I156
	les	bx,[bp-4]	;lastep
	cmp	BYTE PTR es:[bx],1
	je	$I156
	cmp	BYTE PTR es:[bx],12
	je	$I156
	cmp	BYTE PTR es:[bx],14
	je	$I156
	cmp	BYTE PTR es:[bx],15
	je	$I156
; Line 169
	or	BYTE PTR es:[bx],1
; Line 171
	jmp	$I111
$SC129:
; Line 173
	les	bx,[bp-38]	;sp
	cmp	BYTE PTR es:[bx],0
	jne	$I156
; Line 174
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],10
; Line 176
	jmp	$I111
$SC131:
; Line 178
	mov	ax,[bp-16]	;ep
	mov	dx,[bp-14]
	add	ax,17
	mov	cx,OFFSET _expbuf+256
	mov	bx,SEG _expbuf
	cmp	ax,cx
	jb	$JCC1136
	jmp	$cerror116
$JCC1136:
; Line 179
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],6
; Line 181
	mov	BYTE PTR [bp-18],0	;neg
; Line 182
	les	bx,[bp-38]	;sp
	inc	WORD PTR [bp-38]	;sp
	mov	al,es:[bx]
	cbw	
	cwd	
	mov	[bp-8],ax	;c
	mov	[bp-6],dx
	or	dx,dx
	jne	$I133
	cmp	ax,94
	jne	$I133
; Line 183
	mov	BYTE PTR [bp-18],1	;neg
; Line 184
	mov	bx,[bp-38]	;sp
	inc	WORD PTR [bp-38]	;sp
	mov	al,es:[bx]
	cbw	
	cwd	
	mov	[bp-8],ax	;c
	mov	[bp-6],dx
; Line 186
$I133:
	mov	ax,[bp-38]	;sp
	mov	dx,[bp-36]
	mov	[bp-46],ax	;cstart
	mov	[bp-44],dx
; Line 187
$D134:
; Line 188
	mov	ax,[bp-8]	;c
	or	ax,[bp-6]
	jne	$JCC1220
	jmp	$cerror116
$JCC1220:
; Line 189
	cmp	WORD PTR [bp-6],0
	jne	$I138
	cmp	WORD PTR [bp-8],45	;c
	jne	$I138
	mov	ax,[bp-46]	;cstart
	mov	dx,[bp-44]
	cmp	[bp-38],ax	;sp
	jbe	$I138
	les	bx,[bp-38]	;sp
	cmp	BYTE PTR es:[bx],93
	je	$I138
; Line 191
	mov	al,es:[bx-2]
	cbw	
	cwd	
	mov	[bp-8],ax	;c
	mov	[bp-6],dx
$F139:
	les	bx,[bp-38]	;sp
	mov	al,es:[bx]
	cbw	
	cwd	
	cmp	dx,[bp-6]
	jl	$FB141
	jg	$F142
	cmp	ax,[bp-8]	;c
	jbe	$FB141
$F142:
; Line 192
	mov	ax,[bp-8]	;c
	mov	dx,[bp-6]
	mov	cl,3
	call	FAR PTR __lshr
	mov	bx,ax
	les	si,[bp-16]	;ep
	mov	di,[bp-8]	;c
	and	di,7
	mov	al,BYTE PTR _bittab[di]
	or	es:[bx][si],al
	add	WORD PTR [bp-8],1	;c
	adc	WORD PTR [bp-6],0
	jmp	SHORT $F139
$FB141:
; Line 193
	inc	WORD PTR [bp-38]	;sp
; Line 195
$I138:
	mov	ax,[bp-8]	;c
	mov	dx,[bp-6]
	mov	cl,3
	call	FAR PTR __lshr
	mov	bx,ax
	les	si,[bp-16]	;ep
	mov	di,[bp-8]	;c
	and	di,7
	mov	al,BYTE PTR _bittab[di]
	or	es:[bx][si],al
; Line 196
	les	bx,[bp-38]	;sp
	inc	WORD PTR [bp-38]	;sp
	mov	al,es:[bx]
	cbw	
	cwd	
	mov	[bp-8],ax	;c
	mov	[bp-6],dx
	or	dx,dx
	je	$JCC1385
	jmp	$D134
$JCC1385:
	cmp	ax,93
	je	$JCC1393
	jmp	$D134
$JCC1393:
; Line 197
	cmp	BYTE PTR [bp-18],0	;neg
	je	$I143
; Line 198
	sub	ax,ax
	mov	[bp-10],ax
	mov	[bp-12],ax	;cclcnt
$F144:
	cmp	WORD PTR [bp-10],0
	jg	$FB146
	jl	$F147
	cmp	WORD PTR [bp-12],16	;cclcnt
	jae	$FB146
$F147:
; Line 199
	mov	bx,[bp-12]	;cclcnt
	les	si,[bp-16]	;ep
	xor	BYTE PTR es:[bx][si],255
	add	WORD PTR [bp-12],1	;cclcnt
	adc	WORD PTR [bp-10],0
	jmp	SHORT $F144
$FB146:
; Line 200
	les	bx,[bp-16]	;ep
	and	BYTE PTR es:[bx],254
; Line 202
$I143:
	add	WORD PTR [bp-16],16	;ep
; Line 203
	jmp	$I111
$SC148:
; Line 205
	les	bx,[bp-38]	;sp
	inc	WORD PTR [bp-38]	;sp
	mov	al,es:[bx]
	cbw	
	cwd	
	mov	[bp-8],ax	;c
	mov	[bp-6],dx
	or	ax,dx
	jne	$JCC1479
	jmp	$cerror116
$JCC1479:
; Line 206
	or	dx,dx
	jne	$I150
	cmp	WORD PTR [bp-8],60	;c
	jne	$JCC1492
	jmp	$L20043
$JCC1492:
$I150:
	cmp	WORD PTR [bp-6],0
	jne	$I151
	cmp	WORD PTR [bp-8],62	;c
	jne	$I151
; Line 212
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],15
; Line 213
	jmp	$I111
$I151:
	cmp	WORD PTR [bp-6],0
	jne	$I152
	cmp	WORD PTR [bp-8],40	;c
	jne	$I152
; Line 216
	cmp	BYTE PTR [bp-30],9	;numbra
	jl	$JCC1538
	jmp	$cerror116
$JCC1538:
; Line 217
	les	bx,[bp-42]	;bracketp
	inc	WORD PTR [bp-42]	;bracketp
	mov	al,[bp-30]	;numbra
	mov	es:[bx],al
; Line 220
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],1
; Line 221
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	al,[bp-30]	;numbra
	inc	BYTE PTR [bp-30]	;numbra
$L20042:
	mov	es:[bx],al
; Line 222
	jmp	$I111
$I152:
	cmp	WORD PTR [bp-6],0
	jne	$I154
	cmp	WORD PTR [bp-8],41	;c
	jne	$I154
; Line 225
	lea	ax,[bp-28]	;bracket
	mov	cx,ss
	cmp	[bp-42],ax	;bracketp
	jbe	$cerror116
; Line 226
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],12
; Line 229
	dec	WORD PTR [bp-42]	;bracketp
	les	bx,[bp-42]	;bracketp
	mov	al,es:[bx]
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	es:[bx],al
; Line 230
	add	WORD PTR [bp-34],1	;closed
	adc	WORD PTR [bp-32],0
; Line 231
	jmp	$I111
$I154:
	cmp	WORD PTR [bp-6],0
	jge	$JCC1648
	jmp	$I156
$JCC1648:
	jg	$L20022
	cmp	WORD PTR [bp-8],49	;c
	jae	$JCC1659
	jmp	$I156
$JCC1659:
$L20022:
	cmp	WORD PTR [bp-6],0
	jle	$JCC1668
	jmp	$I156
$JCC1668:
	jl	$L20023
	cmp	WORD PTR [bp-8],57	;c
	jbe	$JCC1679
	jmp	$I156
$JCC1679:
$L20023:
; Line 234
	sub	WORD PTR [bp-8],49	;c
	sbb	WORD PTR [bp-6],0
	mov	ax,[bp-34]	;closed
	mov	dx,[bp-32]
	cmp	[bp-6],dx
	jl	$I157
	jg	$cerror116
	cmp	[bp-8],ax	;c
	jae	$cerror116
; Line 235
$I157:
	les	bx,[bp-16]	;ep
	inc	WORD PTR [bp-16]	;ep
	mov	BYTE PTR es:[bx],18
	jmp	$L20045
$cerror116:
; Line 247
	push	WORD PTR 0
	push	WORD PTR 0
	mov	ax,OFFSET DGROUP:$SG159
	push	ds
	push	ax
	call	FAR PTR _errexit
	add	sp,8
; Line 248
$EX98:
	pop	si
	pop	di
	leave	
	ret	

_compile	ENDP
;	file = 6
GREP_TEXT      ENDS
CONST      SEGMENT
$T20025	DW SEG _lnum 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20026	DW SEG _tln 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20030	DW SEG __iob 
CONST      ENDS
GREP_TEXT      SEGMENT
; Line 250
	PUBLIC	_execute
_execute	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,12
	call	FAR PTR __chkstk
;	c = -4
;	p1 = -8
;	p2 = -12
; Line 254
	mov	ax,[bp+6]	;file
	or	ax,[bp+8]
	je	$I166
; Line 255
	mov	ax,OFFSET __iob
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG167
	push	ds
	push	ax
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;file
	call	FAR PTR _freopen
	add	sp,12
	or	ax,dx
	jne	$I166
; Line 256
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;file
	call	FAR PTR _perror
	add	sp,4
; Line 257
	mov	WORD PTR _retcode,2
	mov	WORD PTR _retcode+2,0
; Line 259
$I166:
; Line 260
	mov	es,$T20025
	sub	ax,ax
	mov	WORD PTR es:_lnum+2,ax
	mov	WORD PTR es:_lnum,ax
; Line 261
	mov	es,$T20026
	mov	WORD PTR es:_tln+2,ax
	mov	WORD PTR es:_tln,ax
; Line 262
$F169:
; Line 263
	mov	es,$T20025
	add	WORD PTR es:_lnum,1
	adc	WORD PTR es:_lnum+2,0
; Line 264
	mov	WORD PTR [bp-8],OFFSET _linebuf	;p1
	mov	[bp-6],SEG _linebuf
; Line 265
$WC173:
	mov	es,$T20030
	sub	WORD PTR es:__iob,1
	sbb	WORD PTR es:__iob+2,0
	cmp	WORD PTR es:__iob+2,0
	jl	$L20027
	mov	bx,WORD PTR es:__iob+4
	inc	WORD PTR es:__iob+4
	mov	es,WORD PTR es:__iob+6
	mov	al,es:[bx]
	sub	ah,ah
	sub	dx,dx
	jmp	SHORT $L20028
$L20027:
	mov	ax,OFFSET __iob
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR __filbuf
	add	sp,4
	cwd	
$L20028:
	mov	[bp-4],ax	;c
	mov	[bp-2],dx
	or	dx,dx
	jne	$L20029
	cmp	ax,10
	jne	$JCC1950
	jmp	$WB174
$JCC1950:
$L20029:
; Line 266
	cmp	WORD PTR [bp-2],-1
	jne	$I175
	cmp	WORD PTR [bp-4],-1	;c
	jne	$I175
; Line 267
	mov	es,$T20007
	mov	ax,WORD PTR es:_cflag
	or	ax,WORD PTR es:_cflag+2
	jne	$JCC1980
	jmp	$EX161
$JCC1980:
; Line 268
	mov	es,$T20011
	cmp	WORD PTR es:_nfile+2,0
	jl	$I177
	jg	$L20031
	cmp	WORD PTR es:_nfile,1
	jbe	$I177
$L20031:
; Line 269
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;file
	mov	ax,OFFSET DGROUP:$SG179
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 270
$I177:
	mov	es,$T20026
	push	WORD PTR es:_tln+2
	push	WORD PTR es:_tln
	mov	ax,OFFSET DGROUP:$SG180
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 271
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fflush
	add	sp,4
; Line 273
	jmp	$EX161
$I175:
	les	bx,[bp-8]	;p1
	inc	WORD PTR [bp-8]	;p1
	mov	al,[bp-4]	;c
	mov	es:[bx],al
; Line 276
	cmp	WORD PTR [bp-8],OFFSET _linebuf+1023	;p1
	jae	$JCC2089
	jmp	$WC173
$JCC2089:
; Line 277
$WB174:
; Line 279
	les	bx,[bp-8]	;p1
	inc	WORD PTR [bp-8]	;p1
	mov	BYTE PTR es:[bx],0
; Line 280
	mov	WORD PTR [bp-8],OFFSET _linebuf	;p1
	mov	[bp-6],SEG _linebuf
; Line 281
	mov	WORD PTR [bp-12],OFFSET _expbuf	;p2
	mov	[bp-10],SEG _expbuf
; Line 282
	mov	es,$T20017
	mov	ax,WORD PTR es:_circf
	or	ax,WORD PTR es:_circf+2
	je	$I183
; Line 283
	push	WORD PTR [bp-10]
	push	WORD PTR [bp-12]	;p2
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;p1
	call	FAR PTR _advance
	add	sp,8
	or	ax,ax
	jne	$JCC2161
	jmp	$nfound187
$JCC2161:
; Line 284
	jmp	SHORT $found186
$I183:
	les	bx,[bp-12]	;p2
	cmp	BYTE PTR es:[bx],2
	jne	$I188
; Line 289
	mov	al,es:[bx+1]
	cbw	
	cwd	
	mov	[bp-4],ax	;c
	mov	[bp-2],dx
; Line 290
$D189:
; Line 291
	les	bx,[bp-8]	;p1
	mov	al,es:[bx]
	cbw	
	cwd	
	cmp	dx,[bp-2]
	jne	$I193
	cmp	ax,[bp-4]	;c
	je	$I192
; Line 292
$I193:
	les	bx,[bp-8]	;p1
	inc	WORD PTR [bp-8]	;p1
	cmp	BYTE PTR es:[bx],0
	jne	$D189
; Line 296
	jmp	SHORT $nfound187
$I192:
	push	WORD PTR [bp-10]
	push	WORD PTR [bp-12]	;p2
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;p1
	call	FAR PTR _advance
	add	sp,8
	or	ax,ax
	je	$I193
; Line 294
$found186:
; Line 308
	mov	es,$T20004
	mov	ax,WORD PTR es:_vflag
	or	ax,WORD PTR es:_vflag+2
	je	$JCC2258
	jmp	$F169
$JCC2258:
; Line 309
$L20046:
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;file
	call	FAR PTR _succeed
	add	sp,4
; Line 310
	jmp	$F169
$I188:
; Line 300
	push	WORD PTR [bp-10]
	push	WORD PTR [bp-12]	;p2
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;p1
	call	FAR PTR _advance
	add	sp,8
	or	ax,ax
	jne	$found186
; Line 301
	les	bx,[bp-8]	;p1
	inc	WORD PTR [bp-8]	;p1
	cmp	BYTE PTR es:[bx],0
	jne	$I188
; Line 303
$nfound187:
; Line 304
	mov	es,$T20004
	mov	ax,WORD PTR es:_vflag
	or	ax,WORD PTR es:_vflag+2
	jne	$JCC2329
	jmp	$F169
$JCC2329:
	jmp	SHORT $L20046
$EX161:
	leave	
	ret	

_execute	ENDP
;	lp = 6
GREP_TEXT      ENDS
CONST      SEGMENT
$T20033	DW SEG _braslist 
CONST      ENDS
GREP_TEXT      SEGMENT
GREP_TEXT      ENDS
CONST      SEGMENT
$T20034	DW SEG _braelist 
CONST      ENDS
GREP_TEXT      SEGMENT
;	ep = 10
; Line 313
	PUBLIC	_advance
_advance	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,14
	call	FAR PTR __chkstk
	push	si
;	c = -2
;	curlp = -6
;	bbeg = -10
;	ct = -14
; Line 319
$F208:
	les	bx,[bp+10]	;ep
	inc	WORD PTR [bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	sub	ax,1
	cmp	ax,18
	jbe	$JCC2366
	jmp	$SD266
$JCC2366:
	add	ax,ax
	xchg	ax,bx
	jmp	WORD PTR cs:$L20035[bx]
$SC215:
; Line 321
	les	bx,[bp+6]	;lp
	inc	WORD PTR [bp+6]	;lp
	mov	al,es:[bx]
	les	bx,[bp+10]	;ep
	inc	WORD PTR [bp+10]	;ep
	cmp	es:[bx],al
$L20063:
	je	$F208
; Line 322
$L20047:
	sub	ax,ax
	jmp	$EX203
$SC217:
; Line 325
	les	bx,[bp+6]	;lp
	inc	WORD PTR [bp+6]	;lp
	cmp	BYTE PTR es:[bx],0
	je	$L20047
; Line 326
	jmp	SHORT $F208
$SC219:
; Line 329
	les	bx,[bp+6]	;lp
	cmp	BYTE PTR es:[bx],0
$L20062:
	jne	$L20047
; Line 330
	jmp	SHORT $F208
$SC221:
; Line 333
	mov	ax,1
	jmp	$EX203
$SC222:
; Line 335
	les	bx,[bp+6]	;lp
	inc	WORD PTR [bp+6]	;lp
	mov	al,es:[bx]
	and	al,127
	mov	[bp-2],al	;c
; Line 336
	mov	bl,al
	and	bx,7
	mov	al,BYTE PTR _bittab[bx]
	cbw	
	mov	cx,ax
	mov	al,[bp-2]	;c
	cbw	
	mov	bx,ax
	sar	bx,3
	les	si,[bp+10]	;ep
	mov	al,es:[bx][si]
	cbw	
	test	ax,cx
	je	$L20047
; Line 337
	add	WORD PTR [bp+10],16	;ep
; Line 338
	jmp	$F208
$SC224:
; Line 342
	les	bx,[bp+10]	;ep
	inc	WORD PTR [bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20033
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	mov	WORD PTR es:_braslist[bx],ax
	mov	WORD PTR es:_braslist[bx+2],dx
; Line 343
	jmp	$F208
$SC225:
; Line 345
	les	bx,[bp+10]	;ep
	inc	WORD PTR [bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20034
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	mov	WORD PTR es:_braelist[bx],ax
	mov	WORD PTR es:_braelist[bx+2],dx
; Line 346
	jmp	$F208
$SC226:
; Line 348
	les	bx,[bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20033
	mov	ax,WORD PTR es:_braslist[bx]
	mov	dx,WORD PTR es:_braslist[bx+2]
	mov	[bp-10],ax	;bbeg
	mov	[bp-8],dx
; Line 349
	les	bx,[bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20034
	mov	ax,WORD PTR es:_braelist[bx]
	or	ax,WORD PTR es:_braelist[bx+2]
	jne	$JCC2623
	jmp	$L20047
$JCC2623:
	les	bx,[bp+10]	;ep
	inc	WORD PTR [bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20034
	mov	ax,WORD PTR es:_braelist[bx]
	sub	ax,[bp-10]	;bbeg
	cwd	
	mov	[bp-14],ax	;ct
	mov	[bp-12],dx
; Line 352
	push	dx
	push	ax
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;lp
	push	WORD PTR [bp-8]
	push	WORD PTR [bp-10]	;bbeg
	call	FAR PTR _ecmp
	add	sp,12
	or	ax,ax
	jne	$JCC2686
	jmp	$L20047
$JCC2686:
; Line 353
	mov	ax,[bp-14]	;ct
	add	[bp+6],ax	;lp
; Line 354
	jmp	$F208
$SC230:
; Line 358
	les	bx,[bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20033
	mov	ax,WORD PTR es:_braslist[bx]
	mov	dx,WORD PTR es:_braslist[bx+2]
	mov	[bp-10],ax	;bbeg
	mov	[bp-8],dx
; Line 359
	les	bx,[bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20034
	mov	ax,WORD PTR es:_braelist[bx]
	or	ax,WORD PTR es:_braelist[bx+2]
	jne	$JCC2758
	jmp	$L20047
$JCC2758:
	les	bx,[bp+10]	;ep
	inc	WORD PTR [bp+10]	;ep
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	shl	bx,2
	mov	es,$T20034
	mov	ax,WORD PTR es:_braelist[bx]
	sub	ax,[bp-10]	;bbeg
	cwd	
	mov	[bp-14],ax	;ct
	mov	[bp-12],dx
; Line 362
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	mov	[bp-6],ax	;curlp
	mov	[bp-4],dx
; Line 363
	jmp	SHORT $L20061
$WC232:
; Line 364
	mov	ax,[bp-14]	;ct
	add	[bp+6],ax	;lp
$L20061:
	push	WORD PTR [bp-12]
	push	WORD PTR [bp-14]	;ct
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;lp
	push	WORD PTR [bp-8]
	push	WORD PTR [bp-10]	;bbeg
	call	FAR PTR _ecmp
	add	sp,12
	or	ax,ax
	jne	$WC232
; Line 365
$WC234:
	mov	ax,[bp-6]	;curlp
	mov	dx,[bp-4]
	cmp	[bp+6],ax	;lp
	jae	$JCC2856
	jmp	$L20047
$JCC2856:
; Line 366
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;ep
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;lp
	call	FAR PTR _advance
	add	sp,8
	or	ax,ax
	je	$JCC2883
	jmp	$SC221
$JCC2883:
	mov	ax,[bp-14]	;ct
	sub	[bp+6],ax	;lp
; Line 368
	jmp	SHORT $WC234
$SC237:
; Line 371
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	mov	[bp-6],ax	;curlp
	mov	[bp-4],dx
; Line 372
$WC238:
	les	bx,[bp+6]	;lp
	inc	WORD PTR [bp+6]	;lp
	cmp	BYTE PTR es:[bx],0
	jne	$WC238
$star240:
; Line 387
	dec	WORD PTR [bp+6]	;lp
	mov	ax,[bp-6]	;curlp
	mov	dx,[bp-4]
	cmp	[bp+8],dx
	jne	$I248
	cmp	[bp+6],ax	;lp
	jne	$I248
; Line 388
	jmp	$F208
$SC241:
; Line 375
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	mov	[bp-6],ax	;curlp
	mov	[bp-4],dx
; Line 376
$WC242:
	les	bx,[bp+10]	;ep
	mov	al,es:[bx]
	les	bx,[bp+6]	;lp
	inc	WORD PTR [bp+6]	;lp
	cmp	es:[bx],al
	je	$WC242
; Line 377
	inc	WORD PTR [bp+10]	;ep
; Line 378
	jmp	SHORT $star240
$SC244:
; Line 380
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	mov	[bp-6],ax	;curlp
	mov	[bp-4],dx
; Line 381
$D245:
; Line 382
	les	bx,[bp+6]	;lp
	inc	WORD PTR [bp+6]	;lp
	mov	al,es:[bx]
	and	al,127
	mov	[bp-2],al	;c
; Line 383
	mov	bl,al
	and	bx,7
	mov	al,BYTE PTR _bittab[bx]
	cbw	
	mov	cx,ax
	mov	al,[bp-2]	;c
	cbw	
	mov	bx,ax
	sar	bx,3
	les	si,[bp+10]	;ep
	mov	al,es:[bx][si]
	cbw	
	test	ax,cx
	jne	$D245
; Line 384
	add	WORD PTR [bp+10],16	;ep
; Line 385
	jmp	SHORT $star240
$I248:
	les	bx,[bp+10]	;ep
	cmp	BYTE PTR es:[bx],2
	jne	$I249
; Line 391
	mov	al,es:[bx+1]
	mov	[bp-2],al	;c
; Line 392
$D250:
; Line 393
	les	bx,[bp+6]	;lp
	mov	al,[bp-2]	;c
	cmp	es:[bx],al
	jne	$DC251
; Line 394
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;ep
	push	es
	push	bx
	call	FAR PTR _advance
	add	sp,8
	or	ax,ax
	je	$JCC3086
	jmp	$SC221
$JCC3086:
$DC251:
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	dec	WORD PTR [bp+6]	;lp
	cmp	ax,[bp-6]	;curlp
	ja	$D250
	jmp	$L20047
$I249:
; Line 401
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;ep
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;lp
	call	FAR PTR _advance
	add	sp,8
	or	ax,ax
	je	$JCC3130
	jmp	$SC221
$JCC3130:
	mov	ax,[bp+6]	;lp
	mov	dx,[bp+8]
	dec	WORD PTR [bp+6]	;lp
	cmp	ax,[bp-6]	;curlp
	ja	$I249
	jmp	$L20047
$SC259:
; Line 406
	cmp	[bp+8],SEG _expbuf
	jne	$I260
	cmp	WORD PTR [bp+6],OFFSET _expbuf	;lp
	jne	$JCC3164
	jmp	$F208
$JCC3164:
; Line 407
$I260:
	les	bx,[bp+6]	;lp
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20010
	test	BYTE PTR es:__ctype_[bx+1],3
	jne	$I262
	les	bx,[bp+6]	;lp
	cmp	BYTE PTR es:[bx],95
	je	$I262
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20010
	test	BYTE PTR es:__ctype_[bx+1],4
	jne	$JCC3215
	jmp	$L20047
$JCC3215:
$I262:
; Line 409
	les	bx,[bp+6]	;lp
	mov	al,es:[bx-1]
	cbw	
	mov	bx,ax
	mov	es,$T20010
	test	BYTE PTR es:__ctype_[bx+1],3
	je	$JCC3240
	jmp	$L20047
$JCC3240:
	les	bx,[bp+6]	;lp
	cmp	BYTE PTR es:[bx-1],95
	jne	$JCC3253
	jmp	$L20047
$JCC3253:
	mov	al,es:[bx-1]
	cbw	
	mov	bx,ax
	mov	es,$T20010
	test	BYTE PTR es:__ctype_[bx+1],4
	jmp	$L20063
$SC264:
; Line 413
	les	bx,[bp+6]	;lp
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20010
	test	BYTE PTR es:__ctype_[bx+1],3
	je	$JCC3297
	jmp	$L20047
$JCC3297:
	les	bx,[bp+6]	;lp
	cmp	BYTE PTR es:[bx],95
	jne	$JCC3309
	jmp	$L20047
$JCC3309:
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20010
	test	BYTE PTR es:__ctype_[bx+1],4
	jmp	$L20062
$SD266:
; Line 417
	push	WORD PTR 0
	push	WORD PTR 0
	mov	ax,OFFSET DGROUP:$SG267
	push	ds
	push	ax
	call	FAR PTR _errexit
	add	sp,8
; Line 418
	jmp	$F208
$L20035:
		DW	$SC224
		DW	$SC215
		DW	$SC241
		DW	$SC217
		DW	$SC237
		DW	$SC222
		DW	$SC244
		DW	$SD266
		DW	$SD266
		DW	$SC219
		DW	$SC221
		DW	$SC225
		DW	$SD266
		DW	$SC259
		DW	$SC264
		DW	$SD266
		DW	$SD266
		DW	$SC226
		DW	$SC230
	jmp	$F208
$EX203:
	pop	si
	leave	
	ret	

_advance	ENDP
;	f = 6
GREP_TEXT      ENDS
CONST      SEGMENT
$T20037	DW SEG _blkno 
CONST      ENDS
GREP_TEXT      SEGMENT
; Line 421
	PUBLIC	_succeed
_succeed	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 423
	mov	es,$T20016
	mov	WORD PTR es:_nsucc,1
	mov	WORD PTR es:_nsucc+2,0
; Line 424
	mov	es,$T20003
	mov	ax,WORD PTR es:_sflag
	or	ax,WORD PTR es:_sflag+2
	je	$JCC3438
	jmp	$EX269
$JCC3438:
; Line 425
	mov	es,$T20007
	mov	ax,WORD PTR es:_cflag
	or	ax,WORD PTR es:_cflag+2
	je	$I271
; Line 427
	mov	es,$T20026
	add	WORD PTR es:_tln,1
	adc	WORD PTR es:_tln+2,0
; Line 428
	jmp	$EX269
$I271:
	mov	es,$T20006
	mov	ax,WORD PTR es:_lflag
	or	ax,WORD PTR es:_lflag+2
	je	$I272
; Line 431
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;f
	mov	ax,OFFSET DGROUP:$SG273
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 432
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fflush
	add	sp,4
; Line 433
	push	WORD PTR 2
	push	WORD PTR 0
	push	WORD PTR 0
	mov	ax,OFFSET __iob
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fseek
	add	sp,10
; Line 434
	jmp	$EX269
$I272:
	mov	es,$T20011
	cmp	WORD PTR es:_nfile+2,0
	jl	$I275
	jg	$L20036
	cmp	WORD PTR es:_nfile,1
	jbe	$I275
$L20036:
	mov	ax,WORD PTR _hflag
	or	ax,WORD PTR _hflag+2
	je	$I275
; Line 437
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;f
	mov	ax,OFFSET DGROUP:$SG276
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 438
$I275:
	mov	es,$T20005
	mov	ax,WORD PTR es:_bflag
	or	ax,WORD PTR es:_bflag+2
	je	$I277
; Line 439
	mov	es,$T20037
	push	WORD PTR es:_blkno+2
	push	WORD PTR es:_blkno
	mov	ax,OFFSET DGROUP:$SG278
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 440
$I277:
	mov	es,$T20008
	mov	ax,WORD PTR es:_nflag
	or	ax,WORD PTR es:_nflag+2
	je	$I279
; Line 441
	mov	es,$T20025
	push	WORD PTR es:_lnum+2
	push	WORD PTR es:_lnum
	mov	ax,OFFSET DGROUP:$SG280
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 442
$I279:
	mov	ax,OFFSET _linebuf
	mov	dx,SEG _linebuf
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG281
	push	ds
	push	ax
	call	FAR PTR _printf
	add	sp,8
; Line 443
	mov	ax,OFFSET __iob+20
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fflush
	add	sp,4
; Line 444
$EX269:
	leave	
	ret	

_succeed	ENDP
;	a = 6
;	b = 10
;	count = 14
; Line 446
	PUBLIC	_ecmp
_ecmp	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	cc = -4
; Line 448
	mov	ax,[bp+14]	;count
	cwd	
	mov	[bp-4],ax	;cc
	mov	[bp-2],dx
; Line 449
$WC287:
	mov	ax,[bp-4]	;cc
	mov	dx,[bp-2]
	sub	WORD PTR [bp-4],1	;cc
	sbb	WORD PTR [bp-2],0
	or	ax,dx
	je	$WB288
; Line 450
	les	bx,[bp+10]	;b
	inc	WORD PTR [bp+10]	;b
	mov	al,es:[bx]
	les	bx,[bp+6]	;a
	inc	WORD PTR [bp+6]	;a
	cmp	es:[bx],al
	je	$WC287
	sub	ax,ax
	jmp	SHORT $EX285
$WB288:
	mov	ax,1
$EX285:
	leave	
	ret	

_ecmp	ENDP
;	s = 6
;	f = 10
; Line 454
	PUBLIC	_errexit
_errexit	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 456
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;f
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;s
	mov	ax,OFFSET __iob+40
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fprintf
	add	sp,12
; Line 457
	push	WORD PTR 2
	call	FAR PTR _exit
; Line 458
	leave	
	ret	

_errexit	ENDP
GREP_TEXT	ENDS
END
