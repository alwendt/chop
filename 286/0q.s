;	Static Name Aliases
;
	TITLE   0q

	.286p
	.287
0Q_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
0Q_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: 0Q_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
EXTRN	_printf:FAR
EXTRN	__chkstk:FAR
EXTRN	_up:BYTE
EXTRN	_down:BYTE
EXTRN	_rows:BYTE
EXTRN	_x:BYTE
_DATA      SEGMENT
$SG18	DB	'%d %d',  0aH,  00H
	EVEN
;	.comm _up,03cH
;	.comm _down,03cH
;	.comm _rows,020H
;	.comm _x,020H
_DATA      ENDS
0Q_TEXT      SEGMENT
;	c = 6
0Q_TEXT      ENDS
CONST      SEGMENT
$T20001	DW SEG _up 
CONST      ENDS
0Q_TEXT      SEGMENT
0Q_TEXT      ENDS
CONST      SEGMENT
$T20002	DW SEG _down 
CONST      ENDS
0Q_TEXT      SEGMENT
0Q_TEXT      ENDS
CONST      SEGMENT
$T20003	DW SEG _rows 
CONST      ENDS
0Q_TEXT      SEGMENT
; Line 6
	PUBLIC	_queens
_queens	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	r = -4
; Line 7
	sub	ax,ax
	mov	[bp-2],ax
	mov	[bp-4],ax	;r
; Line 8
	mov	bx,ax
	sub	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20001
	mov	ax,3
	cwd	
	mov	WORD PTR es:_up[bx+28],ax
	mov	WORD PTR es:_up[bx+30],dx
	mov	bx,[bp-4]	;r
	add	bx,[bp+6]	;c
	shl	bx,2
	mov	es,$T20002
	mov	WORD PTR es:_down[bx],ax
	mov	WORD PTR es:_down[bx+2],dx
	mov	bx,[bp-4]	;r
	shl	bx,2
	mov	es,$T20003
	mov	WORD PTR es:_rows[bx],ax
	mov	WORD PTR es:_rows[bx+2],dx
; Line 9
	leave	
	ret	

_queens	ENDP
; Line 12
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 13
	push	WORD PTR 1
	call	FAR PTR _queens
	add	sp,2
; Line 14
	mov	es,$T20002
	push	WORD PTR es:_down+2
	push	WORD PTR es:_down
	mov	es,$T20003
	push	WORD PTR es:_rows+2
	push	WORD PTR es:_rows
	mov	ax,OFFSET DGROUP:$SG18
	push	ds
	push	ax
	call	FAR PTR _printf
; Line 15
	leave	
	ret	

_main	ENDP
0Q_TEXT	ENDS
END
