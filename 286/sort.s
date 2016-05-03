;	Static Name Aliases
;
;	$S7_sccsid	EQU	sccsid
	TITLE   sort

	.286p
	.287
SORT_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
SORT_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: SORT_TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
PUBLIC  _proto
PUBLIC  _error
PUBLIC  _dirtry
PUBLIC  _file
PUBLIC  _compare
PUBLIC  _fold
PUBLIC  _nofold
PUBLIC  _nonprint
PUBLIC  _dict
EXTRN	_getpid:FAR
EXTRN	_sbrk:FAR
EXTRN	_brk:FAR
EXTRN	_creat:FAR
EXTRN	_fputs:FAR
EXTRN	_close:FAR
EXTRN	_unlink:FAR
EXTRN	_fopen:FAR
EXTRN	_fclose:FAR
EXTRN	_fgets:FAR
EXTRN	_sprintf:FAR
EXTRN	_signal:FAR
EXTRN	__chkstk:FAR
EXTRN	_exit:FAR
EXTRN	_stat:FAR
EXTRN	_perror:FAR
EXTRN	_strlen:FAR
EXTRN	__filbuf:FAR
EXTRN	_fields:BYTE
EXTRN	_nfields:WORD
EXTRN	_end:BYTE
EXTRN	__iob:BYTE
EXTRN	_ibuf:BYTE
EXTRN	__ctype_:BYTE
EXTRN	_is:DWORD
EXTRN	_os:DWORD
EXTRN	_dirs:DWORD
EXTRN	_file1:BYTE
EXTRN	_filep:DWORD
EXTRN	_nfiles:WORD
EXTRN	_nlines:WORD
EXTRN	_ntext:WORD
EXTRN	_lspace:DWORD
EXTRN	_tspace:DWORD
EXTRN	_mflg:WORD
EXTRN	_cflg:WORD
EXTRN	_uflg:WORD
EXTRN	_outfil:DWORD
EXTRN	_unsafeout:WORD
EXTRN	_tabchar:BYTE
EXTRN	_eargc:WORD
EXTRN	_eargv:DWORD
EXTRN	_zero:BYTE
_DATA      SEGMENT
$SG8	DB	'@(#)sort.c',  09H, '4.11 (Berkeley) 6/3/86',  00H
$SG92	DB	'/usr/tmp',  00H
	EVEN
$SG93	DB	'/tmp',  00H
	EVEN
$SG160	DB	'-',  00H
$SG171	DB	00H
	EVEN
$SG172	DB	'too many keys',  00H
$SG186	DB	'-',  00H
$SG188	DB	00H
	EVEN
$SG189	DB	'can check only 1 file',  00H
$SG198	DB	'%s/stm%05uaa',  00H
	EVEN
$SG204	DB	00H
	EVEN
$SG205	DB	'can''t locate temp',  00H
$SG237	DB	'r',  00H
$SG249	DB	'r',  00H
$SG253	DB	'line too long (skipped): ',  00H
$SG258	DB	'standard input',  00H
	EVEN
$SG259	DB	'missing newline before EOF in ',  00H
	EVEN
$SG295	DB	'r',  00H
$SG327	DB	'disorder:',  00H
$SG330	DB	'nonunique:',  00H
	EVEN
$SG349	DB	'w',  00H
$SG350	DB	'newfile: can''t create ',  00H
	EVEN
$SG359	DB	'w',  00H
$SG360	DB	'oldfile: can''t create ',  00H
	EVEN
$SG382	DB	'sort: ',  00H
	EVEN
$SG383	DB	0aH,  00H
$S7_sccsid	DD	OFFSET DGROUP:$SG8
	PUBLIC	_dirtry
_dirtry	DD	OFFSET DGROUP:$SG92
	DD	OFFSET DGROUP:$SG93
	DD	0H
	PUBLIC	_file
_file	DD	OFFSET _file1
	PUBLIC	_compare
_compare	DD	OFFSET _cmpa
	PUBLIC	_fold
_fold	DB	080H
	DB	081H
	DB	082H
	DB	083H
	DB	084H
	DB	085H
	DB	086H
	DB	087H
	DB	088H
	DB	089H
	DB	08aH
	DB	08bH
	DB	08cH
	DB	08dH
	DB	08eH
	DB	08fH
	DB	090H
	DB	091H
	DB	092H
	DB	093H
	DB	094H
	DB	095H
	DB	096H
	DB	097H
	DB	098H
	DB	099H
	DB	09aH
	DB	09bH
	DB	09cH
	DB	09dH
	DB	09eH
	DB	09fH
	DB	0a0H
	DB	0a1H
	DB	0a2H
	DB	0a3H
	DB	0a4H
	DB	0a5H
	DB	0a6H
	DB	0a7H
	DB	0a8H
	DB	0a9H
	DB	0aaH
	DB	0abH
	DB	0acH
	DB	0adH
	DB	0aeH
	DB	0afH
	DB	0b0H
	DB	0b1H
	DB	0b2H
	DB	0b3H
	DB	0b4H
	DB	0b5H
	DB	0b6H
	DB	0b7H
	DB	0b8H
	DB	0b9H
	DB	0baH
	DB	0bbH
	DB	0bcH
	DB	0bdH
	DB	0beH
	DB	0bfH
	DB	0c0H
	DB	0c1H
	DB	0c2H
	DB	0c3H
	DB	0c4H
	DB	0c5H
	DB	0c6H
	DB	0c7H
	DB	0c8H
	DB	0c9H
	DB	0caH
	DB	0cbH
	DB	0ccH
	DB	0cdH
	DB	0ceH
	DB	0cfH
	DB	0d0H
	DB	0d1H
	DB	0d2H
	DB	0d3H
	DB	0d4H
	DB	0d5H
	DB	0d6H
	DB	0d7H
	DB	0d8H
	DB	0d9H
	DB	0daH
	DB	0dbH
	DB	0dcH
	DB	0ddH
	DB	0deH
	DB	0dfH
	DB	0e0H
	DB	0e1H
	DB	0e2H
	DB	0e3H
	DB	0e4H
	DB	0e5H
	DB	0e6H
	DB	0e7H
	DB	0e8H
	DB	0e9H
	DB	0eaH
	DB	0ebH
	DB	0ecH
	DB	0edH
	DB	0eeH
	DB	0efH
	DB	0f0H
	DB	0f1H
	DB	0f2H
	DB	0f3H
	DB	0f4H
	DB	0f5H
	DB	0f6H
	DB	0f7H
	DB	0f8H
	DB	0f9H
	DB	0faH
	DB	0fbH
	DB	0fcH
	DB	0fdH
	DB	0feH
	DB	0ffH
	DB	00H
	DB	01H
	DB	02H
	DB	03H
	DB	04H
	DB	05H
	DB	06H
	DB	07H
	DB	08H
	DB	09H
	DB	0aH
	DB	0bH
	DB	0cH
	DB	0dH
	DB	0eH
	DB	0fH
	DB	010H
	DB	011H
	DB	012H
	DB	013H
	DB	014H
	DB	015H
	DB	016H
	DB	017H
	DB	018H
	DB	019H
	DB	01aH
	DB	01bH
	DB	01cH
	DB	01dH
	DB	01eH
	DB	01fH
	DB	020H
	DB	021H
	DB	022H
	DB	023H
	DB	024H
	DB	025H
	DB	026H
	DB	027H
	DB	028H
	DB	029H
	DB	02aH
	DB	02bH
	DB	02cH
	DB	02dH
	DB	02eH
	DB	02fH
	DB	030H
	DB	031H
	DB	032H
	DB	033H
	DB	034H
	DB	035H
	DB	036H
	DB	037H
	DB	038H
	DB	039H
	DB	03aH
	DB	03bH
	DB	03cH
	DB	03dH
	DB	03eH
	DB	03fH
	DB	040H
	DB	041H
	DB	042H
	DB	043H
	DB	044H
	DB	045H
	DB	046H
	DB	047H
	DB	048H
	DB	049H
	DB	04aH
	DB	04bH
	DB	04cH
	DB	04dH
	DB	04eH
	DB	04fH
	DB	050H
	DB	051H
	DB	052H
	DB	053H
	DB	054H
	DB	055H
	DB	056H
	DB	057H
	DB	058H
	DB	059H
	DB	05aH
	DB	05bH
	DB	05cH
	DB	05dH
	DB	05eH
	DB	05fH
	DB	060H
	DB	041H
	DB	042H
	DB	043H
	DB	044H
	DB	045H
	DB	046H
	DB	047H
	DB	048H
	DB	049H
	DB	04aH
	DB	04bH
	DB	04cH
	DB	04dH
	DB	04eH
	DB	04fH
	DB	050H
	DB	051H
	DB	052H
	DB	053H
	DB	054H
	DB	055H
	DB	056H
	DB	057H
	DB	058H
	DB	059H
	DB	05aH
	DB	07bH
	DB	07cH
	DB	07dH
	DB	07eH
	DB	07fH
	PUBLIC	_nofold
_nofold	DB	080H
	DB	081H
	DB	082H
	DB	083H
	DB	084H
	DB	085H
	DB	086H
	DB	087H
	DB	088H
	DB	089H
	DB	08aH
	DB	08bH
	DB	08cH
	DB	08dH
	DB	08eH
	DB	08fH
	DB	090H
	DB	091H
	DB	092H
	DB	093H
	DB	094H
	DB	095H
	DB	096H
	DB	097H
	DB	098H
	DB	099H
	DB	09aH
	DB	09bH
	DB	09cH
	DB	09dH
	DB	09eH
	DB	09fH
	DB	0a0H
	DB	0a1H
	DB	0a2H
	DB	0a3H
	DB	0a4H
	DB	0a5H
	DB	0a6H
	DB	0a7H
	DB	0a8H
	DB	0a9H
	DB	0aaH
	DB	0abH
	DB	0acH
	DB	0adH
	DB	0aeH
	DB	0afH
	DB	0b0H
	DB	0b1H
	DB	0b2H
	DB	0b3H
	DB	0b4H
	DB	0b5H
	DB	0b6H
	DB	0b7H
	DB	0b8H
	DB	0b9H
	DB	0baH
	DB	0bbH
	DB	0bcH
	DB	0bdH
	DB	0beH
	DB	0bfH
	DB	0c0H
	DB	0c1H
	DB	0c2H
	DB	0c3H
	DB	0c4H
	DB	0c5H
	DB	0c6H
	DB	0c7H
	DB	0c8H
	DB	0c9H
	DB	0caH
	DB	0cbH
	DB	0ccH
	DB	0cdH
	DB	0ceH
	DB	0cfH
	DB	0d0H
	DB	0d1H
	DB	0d2H
	DB	0d3H
	DB	0d4H
	DB	0d5H
	DB	0d6H
	DB	0d7H
	DB	0d8H
	DB	0d9H
	DB	0daH
	DB	0dbH
	DB	0dcH
	DB	0ddH
	DB	0deH
	DB	0dfH
	DB	0e0H
	DB	0e1H
	DB	0e2H
	DB	0e3H
	DB	0e4H
	DB	0e5H
	DB	0e6H
	DB	0e7H
	DB	0e8H
	DB	0e9H
	DB	0eaH
	DB	0ebH
	DB	0ecH
	DB	0edH
	DB	0eeH
	DB	0efH
	DB	0f0H
	DB	0f1H
	DB	0f2H
	DB	0f3H
	DB	0f4H
	DB	0f5H
	DB	0f6H
	DB	0f7H
	DB	0f8H
	DB	0f9H
	DB	0faH
	DB	0fbH
	DB	0fcH
	DB	0fdH
	DB	0feH
	DB	0ffH
	DB	00H
	DB	01H
	DB	02H
	DB	03H
	DB	04H
	DB	05H
	DB	06H
	DB	07H
	DB	08H
	DB	09H
	DB	0aH
	DB	0bH
	DB	0cH
	DB	0dH
	DB	0eH
	DB	0fH
	DB	010H
	DB	011H
	DB	012H
	DB	013H
	DB	014H
	DB	015H
	DB	016H
	DB	017H
	DB	018H
	DB	019H
	DB	01aH
	DB	01bH
	DB	01cH
	DB	01dH
	DB	01eH
	DB	01fH
	DB	020H
	DB	021H
	DB	022H
	DB	023H
	DB	024H
	DB	025H
	DB	026H
	DB	027H
	DB	028H
	DB	029H
	DB	02aH
	DB	02bH
	DB	02cH
	DB	02dH
	DB	02eH
	DB	02fH
	DB	030H
	DB	031H
	DB	032H
	DB	033H
	DB	034H
	DB	035H
	DB	036H
	DB	037H
	DB	038H
	DB	039H
	DB	03aH
	DB	03bH
	DB	03cH
	DB	03dH
	DB	03eH
	DB	03fH
	DB	040H
	DB	041H
	DB	042H
	DB	043H
	DB	044H
	DB	045H
	DB	046H
	DB	047H
	DB	048H
	DB	049H
	DB	04aH
	DB	04bH
	DB	04cH
	DB	04dH
	DB	04eH
	DB	04fH
	DB	050H
	DB	051H
	DB	052H
	DB	053H
	DB	054H
	DB	055H
	DB	056H
	DB	057H
	DB	058H
	DB	059H
	DB	05aH
	DB	05bH
	DB	05cH
	DB	05dH
	DB	05eH
	DB	05fH
	DB	060H
	DB	061H
	DB	062H
	DB	063H
	DB	064H
	DB	065H
	DB	066H
	DB	067H
	DB	068H
	DB	069H
	DB	06aH
	DB	06bH
	DB	06cH
	DB	06dH
	DB	06eH
	DB	06fH
	DB	070H
	DB	071H
	DB	072H
	DB	073H
	DB	074H
	DB	075H
	DB	076H
	DB	077H
	DB	078H
	DB	079H
	DB	07aH
	DB	07bH
	DB	07cH
	DB	07dH
	DB	07eH
	DB	07fH
	PUBLIC	_nonprint
_nonprint	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	00H
	DB	00H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	01H
	PUBLIC	_dict
_dict	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	00H
	DB	00H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	00H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	DB	01H
	PUBLIC	_proto
_proto	DD	OFFSET DGROUP:_nofold+128
	DD	OFFSET _zero+128
	DW	00H
	DW	01H
	DW	00H
	DW	00H
	DW	00H
	DW	0ffffH
	DW	00H
	DW	00H
	PUBLIC	_error
_error	DW	01H
;	.comm _fields,0f0H
;	.comm _nfields,02H
	EVEN
;	.comm _ibuf,0400H
;	.comm _is,04H
;	.comm _os,04H
;	.comm _dirs,04H
;	.comm _file1,01eH
;	.comm _filep,04H
;	.comm _nfiles,02H
;	.comm _nlines,02H
;	.comm _ntext,02H
;	.comm _lspace,04H
;	.comm _tspace,04H
;	.comm _mflg,02H
;	.comm _cflg,02H
;	.comm _uflg,02H
;	.comm _outfil,04H
;	.comm _unsafeout,02H
;	.comm _tabchar,01H
	EVEN
;	.comm _eargc,02H
;	.comm _eargv,04H
;	.comm _zero,0100H
_DATA      ENDS
SORT_TEXT      SEGMENT
;	argc = 6
SORT_TEXT      ENDS
CONST      SEGMENT
$T20001	DW SEG _eargv 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20002	DW SEG _eargc 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20003	DW SEG _outfil 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20006	DW SEG _nfields 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20009	DW SEG _cflg 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20010	DW SEG _lspace 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20011	DW SEG _nlines 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20012	DW SEG _ntext 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20013	DW SEG _tspace 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20014	DW SEG _dirs 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20015	DW SEG _filep 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20019	DW SEG _nfiles 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20020	DW SEG _mflg 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20023	DW SEG _unsafeout 
CONST      ENDS
SORT_TEXT      SEGMENT
;	argv = 8
; Line 507
	PUBLIC	_main
_main	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,20
	call	FAR PTR __chkstk
	push	si
;	p = -4
;	q = -8
;	ep = -12
;	i = -14
;	arg = -18
;	a = -20
; Line 516
	call	FAR PTR _copyproto
; Line 517
	mov	es,$T20001
	mov	ax,[bp+8]	;argv
	mov	dx,[bp+10]
	mov	WORD PTR es:_eargv,ax
	mov	WORD PTR es:_eargv+2,dx
; Line 518
	jmp	$I174
$WC148:
; Line 519
	add	WORD PTR [bp+8],4	;argv
	les	bx,[bp+8]	;argv
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],45
	je	$JCC53
	jmp	$I150
$JCC53:
	les	bx,[bp+8]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-18],ax	;arg
	mov	[bp-16],dx
$F151:
; Line 520
	inc	WORD PTR [bp-18]	;arg
	les	bx,[bp-18]	;arg
	mov	al,es:[bx]
	cbw	
	or	ax,ax
	je	$SC158
	cmp	ax,84
	je	$SC163
	cmp	ax,111
	je	$SC161
; Line 537
	mov	es,$T20006
	cmp	es:_nfields,0
	jg	$JCC108
	jmp	$L20004
$JCC108:
	mov	ax,1
	jmp	$L20005
$SC158:
; Line 522
	les	bx,[bp-18]	;arg
	cmp	BYTE PTR es:[bx-1],45
	je	$JCC127
	jmp	$I174
$JCC127:
; Line 523
	mov	es,$T20002
	mov	bx,es:_eargc
	inc	es:_eargc
	shl	bx,2
	mov	es,$T20001
	les	si,DWORD PTR es:_eargv
	mov	ax,OFFSET DGROUP:$SG160
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],ds
; Line 540
	jmp	$I174
$SC161:
; Line 527
	dec	WORD PTR [bp+6]	;argc
	cmp	WORD PTR [bp+6],0	;argc
	jle	$F151
; Line 528
	add	WORD PTR [bp+8],4	;argv
	les	bx,[bp+8]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	es,$T20003
	mov	WORD PTR es:_outfil,ax
	mov	WORD PTR es:_outfil+2,dx
; Line 529
	jmp	$F151
$SC163:
; Line 532
	dec	WORD PTR [bp+6]	;argc
	cmp	WORD PTR [bp+6],0	;argc
	jg	$JCC217
	jmp	$F151
$JCC217:
; Line 533
	add	WORD PTR [bp+8],4	;argv
	les	bx,[bp+8]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	WORD PTR _dirtry,ax
	mov	WORD PTR _dirtry+2,dx
; Line 534
	jmp	$F151
$L20004:
	sub	ax,ax
$L20005:
	push	ax
$L20047:
	les	bx,[bp+8]	;argv
	inc	WORD PTR es:[bx]
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _field
	add	sp,6
; Line 538
	jmp	SHORT $I174
$I150:
	les	bx,[bp+8]	;argv
	les	bx,es:[bx]
	cmp	BYTE PTR es:[bx],43
	jne	$I168
; Line 542
	mov	es,$T20006
	inc	es:_nfields
	cmp	es:_nfields,10
	jl	$I169
; Line 543
	mov	ax,OFFSET DGROUP:$SG171
	push	ds
	push	ax
	mov	ax,OFFSET DGROUP:$SG172
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 544
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 546
$I169:
	call	FAR PTR _copyproto
; Line 547
	push	WORD PTR 0
	jmp	SHORT $L20047
$I168:
; Line 549
	les	bx,[bp+8]	;argv
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	es,$T20002
	mov	bx,es:_eargc
	inc	es:_eargc
	shl	bx,2
	mov	es,$T20001
	les	si,DWORD PTR es:_eargv
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],dx
$I174:
; Line 550
	dec	WORD PTR [bp+6]	;argc
	cmp	WORD PTR [bp+6],0	;argc
	jle	$JCC388
	jmp	$WC148
$JCC388:
; Line 551
	mov	WORD PTR [bp-8],OFFSET _fields	;q
	mov	[bp-6],SEG _fields
; Line 552
	mov	WORD PTR [bp-20],1	;a
$F175:
	mov	es,$T20006
	mov	ax,es:_nfields
	cmp	[bp-20],ax	;a
	jle	$JCC419
	jmp	$FB177
$JCC419:
; Line 553
	imul	ax,WORD PTR [bp-20],24	;a
	add	ax,OFFSET _fields
	mov	[bp-4],ax	;p
	mov	[bp-2],SEG _fields
; Line 554
	les	bx,[bp-4]	;p
	mov	ax,WORD PTR _proto
	mov	dx,WORD PTR _proto+2
	cmp	es:[bx+2],dx
	jne	$FC176
	cmp	es:[bx],ax
	jne	$FC176
	mov	ax,WORD PTR _proto+4
	mov	dx,WORD PTR _proto+6
	cmp	es:[bx+6],dx
	jne	$FC176
	cmp	es:[bx+4],ax
	je	$I180
$FC176:
	inc	WORD PTR [bp-20]	;a
	jmp	SHORT $F175
$I180:
	les	bx,[bp-4]	;p
	mov	ax,WORD PTR _proto+8
	cmp	es:[bx+8],ax
	jne	$FC176
	mov	ax,WORD PTR _proto+10
	cmp	es:[bx+10],ax
	jne	$FC176
	mov	ax,WORD PTR _proto+12
	cmp	es:[bx+12],ax
	jne	$FC176
	mov	ax,WORD PTR _proto+14
	cmp	es:[bx+14],ax
	jne	$FC176
	les	bx,[bp-8]	;q
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-4]	;p
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 561
	les	bx,[bp-8]	;q
	mov	ax,es:[bx+4]
	mov	dx,es:[bx+6]
	les	bx,[bp-4]	;p
	mov	es:[bx+4],ax
	mov	es:[bx+6],dx
; Line 562
	les	bx,[bp-8]	;q
	mov	ax,es:[bx+8]
	les	bx,[bp-4]	;p
	mov	es:[bx+8],ax
; Line 563
	les	bx,[bp-8]	;q
	mov	ax,es:[bx+10]
	les	bx,[bp-4]	;p
	mov	es:[bx+10],ax
; Line 564
	les	bx,[bp-8]	;q
	mov	ax,es:[bx+12]
	les	bx,[bp-4]	;p
	mov	es:[bx+14],ax
	les	bx,[bp-4]	;p
	mov	es:[bx+12],ax
; Line 565
	jmp	$FC176
$FB177:
; Line 566
	mov	es,$T20002
	cmp	es:_eargc,0
	jne	$I185
; Line 567
	mov	bx,es:_eargc
	inc	es:_eargc
	shl	bx,2
	mov	es,$T20001
	les	si,DWORD PTR es:_eargv
	mov	ax,OFFSET DGROUP:$SG186
	mov	es:[bx][si],ax
	mov	es:[bx+2][si],ds
; Line 568
$I185:
	mov	es,$T20009
	cmp	es:_cflg,0
	je	$I187
	mov	es,$T20002
	cmp	es:_eargc,1
	jle	$I187
; Line 569
	mov	ax,OFFSET DGROUP:$SG188
	push	ds
	push	ax
	mov	ax,OFFSET DGROUP:$SG189
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 570
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 572
$I187:
	call	FAR PTR _safeoutfil
; Line 574
	mov	WORD PTR [bp-12],OFFSET _end	;ep
	mov	[bp-10],SEG _end
; Line 575
	push	WORD PTR 0
	call	FAR PTR _sbrk
	add	sp,2
	mov	es,$T20010
	mov	WORD PTR es:_lspace,ax
	mov	WORD PTR es:_lspace+2,dx
; Line 576
	jmp	SHORT $L20045
$WC191:
; Line 577
	sub	WORD PTR [bp-12],512	;ep
$L20045:
	push	WORD PTR [bp-10]
	push	WORD PTR [bp-12]	;ep
	call	FAR PTR _brk
	add	sp,4
	inc	ax
	je	$WC191
; Line 579
	mov	ax,[bp-12]	;ep
	mov	es,$T20010
	sub	ax,WORD PTR es:_lspace
	mov	[bp-20],ax	;a
; Line 580
	mov	es,$T20011
	sub	ax,1024
	mov	es:_nlines,ax
; Line 581
	mov	cx,20
	sub	dx,dx
	div	cx
	mov	es:_nlines,ax
; Line 582
	shl	ax,4
	mov	es,$T20012
	mov	es:_ntext,ax
; Line 583
	mov	es,$T20011
	mov	ax,es:_nlines
	shl	ax,1
	mov	es,$T20010
	add	ax,WORD PTR es:_lspace
	mov	dx,WORD PTR es:_lspace+2
	mov	es,$T20013
	mov	WORD PTR es:_tspace,ax
	mov	WORD PTR es:_tspace+2,dx
; Line 584
	mov	WORD PTR [bp-20],-1	;a
; Line 585
	mov	es,$T20014
	mov	ax,OFFSET DGROUP:_dirtry
	mov	WORD PTR es:_dirs,ax
	mov	WORD PTR es:_dirs+2,ds
$F193:
	mov	es,$T20014
	les	bx,DWORD PTR es:_dirs
	mov	ax,es:[bx]
	or	ax,es:[bx+2]
	je	$FB195
; Line 586
	call	FAR PTR _getpid
	push	ax
	mov	es,$T20014
	les	bx,DWORD PTR es:_dirs
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	mov	ax,OFFSET DGROUP:$SG198
	push	ds
	push	ax
	mov	es,$T20015
	mov	ax,OFFSET _file1
	mov	dx,SEG _file1
	mov	WORD PTR es:_filep,ax
	mov	WORD PTR es:_filep+2,dx
	push	dx
	push	ax
	call	FAR PTR _sprintf
	add	sp,14
; Line 587
	jmp	SHORT $L20048
$WC199:
; Line 588
	mov	es,$T20015
	inc	WORD PTR es:_filep
$L20048:
	mov	es,$T20015
	les	bx,DWORD PTR es:_filep
	cmp	BYTE PTR es:[bx],0
	jne	$WC199
; Line 589
	mov	es,$T20015
	sub	WORD PTR es:_filep,2
; Line 590
	push	WORD PTR 384
	push	WORD PTR _file+2
	push	WORD PTR _file
	call	FAR PTR _creat
	add	sp,6
	mov	[bp-20],ax	;a
	or	ax,ax
	jge	$JCC1015
	jmp	$FC194
$JCC1015:
; Line 591
$FB195:
; Line 593
	cmp	WORD PTR [bp-20],0	;a
	jge	$I203
; Line 594
	mov	ax,OFFSET DGROUP:$SG204
	push	ds
	push	ax
	mov	ax,OFFSET DGROUP:$SG205
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 595
	push	WORD PTR 1
	call	FAR PTR _exit
	add	sp,2
; Line 597
$I203:
	push	WORD PTR [bp-20]	;a
	call	FAR PTR _close
	add	sp,2
; Line 598
	push	WORD PTR _file+2
	push	WORD PTR _file
	call	FAR PTR _unlink
	add	sp,4
; Line 599
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 1
	call	FAR PTR _signal
	add	sp,6
	or	dx,dx
	jne	$L20016
	cmp	ax,1
	je	$I208
$L20016:
; Line 600
	push	SEG _term
	push	OFFSET WORD PTR _term
	push	WORD PTR 1
	call	FAR PTR _signal
	add	sp,6
; Line 601
$I208:
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 2
	call	FAR PTR _signal
	add	sp,6
	or	dx,dx
	jne	$L20017
	cmp	ax,1
	je	$I209
$L20017:
; Line 602
	push	SEG _term
	push	OFFSET WORD PTR _term
	push	WORD PTR 2
	call	FAR PTR _signal
	add	sp,6
; Line 603
$I209:
	push	SEG _term
	push	OFFSET WORD PTR _term
	push	WORD PTR 13
	call	FAR PTR _signal
	add	sp,6
; Line 604
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 15
	call	FAR PTR _signal
	add	sp,6
	or	dx,dx
	jne	$L20018
	cmp	ax,1
	je	$I210
$L20018:
; Line 605
	push	SEG _term
	push	OFFSET WORD PTR _term
	push	WORD PTR 15
	call	FAR PTR _signal
	add	sp,6
; Line 606
$I210:
	mov	es,$T20002
	mov	ax,es:_eargc
	mov	es,$T20019
	mov	es:_nfiles,ax
; Line 607
	mov	es,$T20020
	cmp	es:_mflg,0
	jne	$I211
	mov	es,$T20009
	cmp	es:_cflg,0
	jne	$I211
; Line 608
	call	FAR PTR _sort
; Line 609
	mov	ax,OFFSET __iob
	mov	dx,SEG __iob
	push	dx
	push	ax
	call	FAR PTR _fclose
	add	sp,4
; Line 611
$I211:
	mov	es,$T20020
	mov	ax,es:_mflg
	mov	es,$T20009
	or	ax,es:_cflg
	je	$L20021
	sub	ax,ax
	jmp	SHORT $L20022
$FC194:
	mov	es,$T20014
	add	WORD PTR es:_dirs,4
	jmp	$F193
$L20021:
	mov	es,$T20002
	mov	ax,es:_eargc
$L20022:
	mov	[bp-20],ax	;a
	add	ax,7
	mov	es,$T20019
	cmp	ax,es:_nfiles
	jl	$F218
	mov	es,$T20023
	cmp	es:_unsafeout,0
	je	$FB216
	mov	es,$T20002
	mov	ax,es:_eargc
	cmp	[bp-20],ax	;a
	jge	$FB216
$F218:
; Line 612
	mov	ax,[bp-20]	;a
	add	ax,7
	mov	[bp-14],ax	;i
; Line 613
	mov	es,$T20019
	mov	ax,es:_nfiles
	cmp	[bp-14],ax	;i
	jl	$I219
; Line 614
	mov	[bp-14],ax	;i
; Line 615
$I219:
	call	FAR PTR _newfile
; Line 616
	push	WORD PTR [bp-14]	;i
	push	WORD PTR [bp-20]	;a
	call	FAR PTR _merge
	add	sp,4
; Line 617
	mov	ax,[bp-14]	;i
	jmp	SHORT $L20022
$FB216:
; Line 618
	mov	es,$T20019
	mov	ax,es:_nfiles
	cmp	[bp-20],ax	;a
	je	$I222
; Line 619
	call	FAR PTR _oldfile
; Line 620
	mov	es,$T20019
	push	es:_nfiles
	push	WORD PTR [bp-20]	;a
	call	FAR PTR _merge
	add	sp,4
; Line 622
$I222:
	mov	_error,0
; Line 623
	call	FAR PTR _term
; Line 624
	pop	si
	leave	
	ret	

_main	ENDP
; Line 627
SORT_TEXT      ENDS
CONST      SEGMENT
$T20024	DW SEG _is 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20029	DW SEG _os 
CONST      ENDS
SORT_TEXT      SEGMENT
	PUBLIC	_sort
_sort	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,24
	call	FAR PTR __chkstk
	push	si
;	c = -2
;	len = -4
;	lines = -6
;	lp = -10
;	text = -12
;	cp = -16
;	f = -20
;	done = -22
;	i = -24
; Line 631
	mov	WORD PTR [bp-22],0	;done
; Line 632
	mov	WORD PTR [bp-24],0	;i
; Line 636
	push	WORD PTR [bp-24]	;i
	inc	WORD PTR [bp-24]	;i
	call	FAR PTR _setfil
	add	sp,2
	mov	[bp-20],ax	;f
	mov	[bp-18],dx
	or	ax,dx
	jne	$I234
; Line 637
	mov	es,$T20024
	mov	WORD PTR es:_is,OFFSET __iob
	mov	WORD PTR es:_is+2,SEG __iob
; Line 638
	jmp	SHORT $I236
$I234:
	mov	ax,OFFSET DGROUP:$SG237
	push	ds
	push	ax
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;f
	call	FAR PTR _fopen
	add	sp,8
	mov	es,$T20024
	mov	WORD PTR es:_is,ax
	mov	WORD PTR es:_is+2,dx
	or	ax,dx
	jne	$I236
; Line 639
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;f
	call	FAR PTR _cant
	add	sp,4
; Line 641
$I236:
; Line 642
	mov	es,$T20013
	mov	ax,WORD PTR es:_tspace
	mov	dx,WORD PTR es:_tspace+2
	mov	[bp-16],ax	;cp
	mov	[bp-14],dx
; Line 643
	mov	es,$T20010
	mov	ax,WORD PTR es:_lspace
	mov	dx,WORD PTR es:_lspace+2
	mov	[bp-10],ax	;lp
	mov	[bp-8],dx
; Line 644
	mov	es,$T20011
	mov	ax,es:_nlines
	mov	[bp-6],ax	;lines
; Line 645
	mov	es,$T20012
	mov	ax,es:_ntext
	mov	[bp-12],ax	;text
; Line 646
$WC242:
	cmp	WORD PTR [bp-6],0	;lines
	jle	$WB243
	cmp	WORD PTR [bp-12],0	;text
	jle	$WB243
; Line 647
	mov	es,$T20024
	push	WORD PTR es:_is+2
	push	WORD PTR es:_is
	push	WORD PTR 1024
	push	WORD PTR [bp-14]
	push	WORD PTR [bp-16]	;cp
	call	FAR PTR _fgets
	add	sp,10
	or	ax,dx
	je	$JCC1683
	jmp	$I244
$JCC1683:
; Line 648
	mov	es,$T20002
	mov	ax,es:_eargc
	cmp	[bp-24],ax	;i
	jl	$I245
; Line 649
	inc	WORD PTR [bp-22]	;done
; Line 650
$WB243:
; Line 680
	push	WORD PTR [bp-8]
	push	WORD PTR [bp-10]	;lp
	mov	es,$T20010
	push	WORD PTR es:_lspace+2
	push	WORD PTR es:_lspace
	call	FAR PTR _qsort
	add	sp,8
; Line 681
	cmp	WORD PTR [bp-22],0	;done
	je	$I262
	mov	es,$T20002
	mov	ax,es:_eargc
	mov	es,$T20019
	cmp	es:_nfiles,ax
	jne	$JCC1755
	jmp	$I261
$JCC1755:
$I262:
; Line 682
	call	FAR PTR _newfile
; Line 683
	jmp	$I263
$I245:
	mov	es,$T20024
	push	WORD PTR es:_is+2
	push	WORD PTR es:_is
	call	FAR PTR _fclose
	add	sp,4
; Line 653
	push	WORD PTR [bp-24]	;i
	inc	WORD PTR [bp-24]	;i
	call	FAR PTR _setfil
	add	sp,2
	mov	[bp-20],ax	;f
	mov	[bp-18],dx
	or	ax,dx
	jne	$I246
; Line 654
	mov	es,$T20024
	mov	WORD PTR es:_is,OFFSET __iob
	mov	WORD PTR es:_is+2,SEG __iob
; Line 655
	jmp	$WC242
$I246:
	mov	ax,OFFSET DGROUP:$SG249
	push	ds
	push	ax
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;f
	call	FAR PTR _fopen
	add	sp,8
	mov	es,$T20024
	mov	WORD PTR es:_is,ax
	mov	WORD PTR es:_is+2,dx
	or	ax,dx
	je	$JCC1869
	jmp	$WC242
$JCC1869:
; Line 656
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;f
	call	FAR PTR _cant
	add	sp,4
; Line 657
	jmp	$WC242
$I244:
	les	bx,[bp-10]	;lp
	add	WORD PTR [bp-10],4	;lp
	mov	ax,[bp-16]	;cp
	mov	dx,[bp-14]
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 660
	push	WORD PTR [bp-14]
	push	WORD PTR [bp-16]	;cp
	call	FAR PTR _strlen
	add	sp,4
	inc	ax
	mov	[bp-4],ax	;len
; Line 661
	mov	si,ax
	les	bx,[bp-16]	;cp
	cmp	BYTE PTR es:[bx-2][si],10
	jne	$JCC1939
	jmp	$I251
$JCC1939:
; Line 662
	cmp	ax,1024
	jne	$I252
; Line 663
	push	es
	push	bx
	mov	ax,OFFSET DGROUP:$SG253
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 664
$WC255:
	mov	es,$T20024
	les	bx,DWORD PTR es:_is
	dec	WORD PTR es:[bx]
	cmp	WORD PTR es:[bx],0
	jl	$L20025
	mov	es,$T20024
	les	bx,DWORD PTR es:_is
	mov	si,es:[bx+2]
	inc	WORD PTR es:[bx+2]
	mov	es,es:[bx+4]
	mov	al,es:[si]
	sub	ah,ah
	jmp	SHORT $L20026
$L20025:
	mov	es,$T20024
	push	WORD PTR es:_is+2
	push	WORD PTR es:_is
	call	FAR PTR __filbuf
	add	sp,4
$L20026:
	mov	[bp-2],al	;c
	inc	al
	je	$WB256
	cmp	BYTE PTR [bp-2],10	;c
	jne	$WC255
; Line 665
$WB256:
; Line 666
	sub	WORD PTR [bp-10],4	;lp
; Line 667
	jmp	$WC242
$I252:
; Line 670
	mov	ax,[bp-20]	;f
	or	ax,[bp-18]
	je	$L20027
	mov	ax,[bp-20]	;f
	mov	dx,[bp-18]
	jmp	SHORT $L20028
$L20027:
	mov	ax,OFFSET DGROUP:$SG258
	mov	dx,ds
$L20028:
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG259
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 672
	inc	WORD PTR [bp-4]	;len
; Line 673
	mov	si,[bp-4]	;len
	les	bx,[bp-16]	;cp
	mov	BYTE PTR es:[bx-2][si],10
; Line 674
	mov	si,[bp-4]	;len
	les	bx,[bp-16]	;cp
	mov	BYTE PTR es:[bx-1][si],0
; Line 676
$I251:
	mov	ax,[bp-4]	;len
	add	[bp-16],ax	;cp
; Line 677
	dec	WORD PTR [bp-6]	;lines
; Line 678
	sub	[bp-12],ax	;text
; Line 679
	jmp	$WC242
$I261:
; Line 684
	call	FAR PTR _oldfile
$I263:
; Line 685
	mov	es,$T20029
	les	bx,DWORD PTR es:_os
	and	BYTE PTR es:[bx+12],207
; Line 686
$WC264:
	mov	es,$T20010
	mov	ax,WORD PTR es:_lspace
	mov	dx,WORD PTR es:_lspace+2
	cmp	[bp-10],ax	;lp
	jbe	$WB265
; Line 687
	cmp	[bp-10],ax	;lp
	jbe	$WB265
	sub	WORD PTR [bp-10],4	;lp
	les	bx,[bp-10]	;lp
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-16],ax	;cp
	mov	[bp-14],dx
; Line 689
	les	bx,[bp-16]	;cp
	cmp	BYTE PTR es:[bx],0
	je	$I267
; Line 690
	mov	es,$T20029
	push	WORD PTR es:_os+2
	push	WORD PTR es:_os
	push	dx
	push	ax
	call	FAR PTR _fputs
	add	sp,8
; Line 691
$I267:
	mov	es,$T20029
	les	bx,DWORD PTR es:_os
	test	BYTE PTR es:[bx+12],32
	je	$WC264
; Line 692
	mov	_error,1
; Line 693
	call	FAR PTR _term
; Line 695
	jmp	SHORT $WC264
$WB265:
; Line 696
	mov	es,$T20029
	push	WORD PTR es:_os+2
	push	WORD PTR es:_os
	call	FAR PTR _fclose
	add	sp,4
; Line 697
	cmp	WORD PTR [bp-22],0	;done
	jne	$JCC2278
	jmp	$I236
$JCC2278:
; Line 698
	pop	si
	leave	
	ret	

_sort	ENDP
;	a = 6
SORT_TEXT      ENDS
CONST      SEGMENT
$T20030	DW SEG _ibuf 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20031	DW SEG _uflg 
CONST      ENDS
SORT_TEXT      SEGMENT
;	b = 8
; Line 707
	PUBLIC	_merge
_merge	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,34
	call	FAR PTR __chkstk
;	muflg = -2
;	cp = -6
;	p = -10
;	f = -14
;	dp = -18
;	i = -20
;	j = -22
;	k = -24
;	ip = -28
;	l = -30
;	jp = -34
; Line 717
	mov	es,$T20010
	mov	ax,WORD PTR es:_lspace
	mov	dx,WORD PTR es:_lspace+2
	mov	[bp-10],ax	;p
	mov	[bp-8],dx
; Line 718
	mov	WORD PTR [bp-22],0	;j
; Line 719
	mov	ax,[bp+6]	;a
	mov	[bp-20],ax	;i
$F288:
	mov	ax,[bp+8]	;b
	cmp	[bp-20],ax	;i
	jl	$JCC2333
	jmp	$FB290
$JCC2333:
; Line 720
	push	WORD PTR [bp-20]	;i
	call	FAR PTR _setfil
	add	sp,2
	mov	[bp-14],ax	;f
	mov	[bp-12],dx
; Line 721
	or	ax,dx
	jne	$I292
; Line 722
	les	bx,[bp-10]	;p
	mov	WORD PTR es:[bx+1024],OFFSET __iob
	mov	es:[bx+1026],SEG __iob
; Line 723
	jmp	SHORT $I294
$I292:
	mov	ax,OFFSET DGROUP:$SG295
	push	ds
	push	ax
	push	WORD PTR [bp-12]
	push	WORD PTR [bp-14]	;f
	call	FAR PTR _fopen
	add	sp,8
	les	bx,[bp-10]	;p
	mov	es:[bx+1024],ax
	mov	es:[bx+1026],dx
	or	ax,dx
	jne	$I294
; Line 724
	push	WORD PTR [bp-12]
	push	WORD PTR [bp-14]	;f
	call	FAR PTR _cant
	add	sp,4
; Line 725
$I294:
	mov	bx,[bp-22]	;j
	shl	bx,2
	mov	es,$T20030
	mov	ax,[bp-10]	;p
	mov	dx,[bp-8]
	mov	WORD PTR es:_ibuf[bx],ax
	mov	WORD PTR es:_ibuf[bx+2],dx
; Line 726
	les	bx,[bp-10]	;p
	push	WORD PTR es:[bx+1026]
	push	WORD PTR es:[bx+1024]
	push	WORD PTR 1024
	push	es
	push	bx
	call	FAR PTR _fgets
	add	sp,10
	or	ax,dx
	je	$I296
	inc	WORD PTR [bp-22]	;j
; Line 727
$I296:
	add	WORD PTR [bp-10],1028	;p
; Line 728
	inc	WORD PTR [bp-20]	;i
	jmp	$F288
$FB290:
; Line 731
	mov	ax,[bp-22]	;j
	mov	[bp-20],ax	;i
; Line 732
	mov	bx,ax
	shl	bx,2
	lea	ax,WORD PTR _ibuf[bx]
	mov	dx,SEG _ibuf
	push	dx
	push	ax
	mov	ax,OFFSET _ibuf
	push	dx
	push	ax
	call	FAR PTR _qsort
	add	sp,8
; Line 733
	mov	WORD PTR [bp-30],0	;l
; Line 734
	jmp	$I303
$WC300:
; Line 735
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	mov	ax,WORD PTR es:_ibuf[bx]
	mov	dx,WORD PTR es:_ibuf[bx+2]
	mov	[bp-6],ax	;cp
	mov	[bp-4],dx
; Line 736
	les	bx,[bp-6]	;cp
	cmp	BYTE PTR es:[bx],0
	jne	$I303
; Line 737
	mov	WORD PTR [bp-30],1	;l
; Line 738
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	les	bx,DWORD PTR es:_ibuf[bx]
	push	WORD PTR es:[bx+1026]
	push	WORD PTR es:[bx+1024]
	push	WORD PTR 1024
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	push	WORD PTR es:_ibuf[bx+2]
	push	WORD PTR es:_ibuf[bx]
	call	FAR PTR _fgets
	add	sp,10
	or	ax,dx
	jne	$I303
; Line 739
	mov	ax,[bp-20]	;i
	mov	[bp-24],ax	;k
; Line 740
	jmp	SHORT $L20049
$WC304:
; Line 741
	mov	bx,[bp-24]	;k
	shl	bx,2
	mov	es,$T20030
	mov	ax,WORD PTR es:_ibuf[bx]
	mov	dx,WORD PTR es:_ibuf[bx+2]
	mov	bx,[bp-24]	;k
	shl	bx,2
	mov	WORD PTR es:_ibuf[bx-4],ax
	mov	WORD PTR es:_ibuf[bx-2],dx
$L20049:
	inc	WORD PTR [bp-24]	;k
	mov	ax,[bp-22]	;j
	cmp	[bp-24],ax	;k
	jl	$WC304
; Line 742
	dec	WORD PTR [bp-22]	;j
; Line 744
$I303:
; Line 745
	mov	ax,[bp-20]	;i
	dec	WORD PTR [bp-20]	;i
	or	ax,ax
	je	$JCC2705
	jmp	$WC300
$JCC2705:
; Line 746
	cmp	WORD PTR [bp-30],0	;l
	je	$JCC2714
	jmp	$FB290
$JCC2714:
; Line 748
	mov	es,$T20029
	les	bx,DWORD PTR es:_os
	and	BYTE PTR es:[bx+12],207
; Line 749
	mov	es,$T20020
	mov	ax,es:_mflg
	mov	es,$T20031
	and	ax,es:_uflg
	mov	es,$T20009
	or	ax,es:_cflg
	mov	[bp-2],ax	;muflg
; Line 750
	mov	ax,[bp-22]	;j
	mov	[bp-20],ax	;i
; Line 751
	jmp	$L20052
$WC306:
; Line 752
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	mov	ax,WORD PTR es:_ibuf[bx-4]
	mov	dx,WORD PTR es:_ibuf[bx-2]
	mov	[bp-6],ax	;cp
	mov	[bp-4],dx
; Line 754
	mov	es,$T20009
	cmp	es:_cflg,0
	jne	$I310
	mov	es,$T20031
	cmp	es:_uflg,0
	je	$I309
	cmp	WORD PTR [bp-2],0	;muflg
	jne	$I309
	cmp	WORD PTR [bp-20],1	;i
	je	$I309
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	push	WORD PTR es:_ibuf[bx-6]
	push	WORD PTR es:_ibuf[bx-8]
	mov	bx,[bp-20]	;i
	shl	bx,2
	push	WORD PTR es:_ibuf[bx-2]
	push	WORD PTR es:_ibuf[bx-4]
	call	FAR PTR _compare
	add	sp,8
	or	ax,ax
	je	$I310
$I309:
; Line 755
	mov	es,$T20029
	push	WORD PTR es:_os+2
	push	WORD PTR es:_os
	push	WORD PTR [bp-4]
	push	WORD PTR [bp-6]	;cp
	call	FAR PTR _fputs
	add	sp,8
; Line 756
	mov	es,$T20029
	les	bx,DWORD PTR es:_os
	test	BYTE PTR es:[bx+12],32
	je	$I310
; Line 757
	mov	_error,1
; Line 758
	call	FAR PTR _term
; Line 760
$I310:
; Line 761
	cmp	WORD PTR [bp-2],0	;muflg
	je	$I311
; Line 762
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	mov	ax,WORD PTR es:_ibuf[bx-4]
	mov	dx,WORD PTR es:_ibuf[bx-2]
	mov	[bp-6],ax	;cp
	mov	[bp-4],dx
; Line 763
	mov	ax,[bp-10]	;p
	mov	dx,[bp-8]
	mov	[bp-18],ax	;dp
	mov	[bp-16],dx
; Line 764
$D312:
; Line 765
	les	bx,[bp-6]	;cp
	inc	WORD PTR [bp-6]	;cp
	mov	al,es:[bx]
	les	bx,[bp-18]	;dp
	inc	WORD PTR [bp-18]	;dp
	mov	es:[bx],al
	cmp	al,10
	jne	$D312
; Line 767
$I311:
; Line 768
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	les	bx,DWORD PTR es:_ibuf[bx-4]
	push	WORD PTR es:[bx+1026]
	push	WORD PTR es:[bx+1024]
	push	WORD PTR 1024
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	push	WORD PTR es:_ibuf[bx-2]
	push	WORD PTR es:_ibuf[bx-4]
	call	FAR PTR _fgets
	add	sp,10
	or	ax,dx
	jne	$I320
; Line 769
	dec	WORD PTR [bp-20]	;i
; Line 770
	cmp	WORD PTR [bp-20],0	;i
	jne	$JCC3068
	jmp	$L20052
$JCC3068:
; Line 793
	cmp	WORD PTR [bp-20],1	;i
	jne	$I320
; Line 773
	mov	es,$T20031
	mov	ax,es:_uflg
	mov	[bp-2],ax	;muflg
; Line 774
$I320:
; Line 775
	mov	ax,[bp-20]	;i
	shl	ax,2
	add	ax,OFFSET _ibuf
	mov	[bp-28],ax	;ip
	mov	[bp-26],SEG _ibuf
; Line 776
$WC321:
	sub	WORD PTR [bp-28],4	;ip
	cmp	WORD PTR [bp-28],OFFSET _ibuf	;ip
	jbe	$WB322
	les	bx,[bp-28]	;ip
	push	WORD PTR es:[bx-2]
	push	WORD PTR es:[bx-4]
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _compare
	add	sp,8
	or	ax,ax
	jge	$WB322
; Line 777
	les	bx,[bp-28]	;ip
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-34],ax	;jp
	mov	[bp-32],dx
; Line 778
	mov	ax,es:[bx-4]
	mov	dx,es:[bx-2]
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 779
	les	bx,[bp-28]	;ip
	mov	ax,[bp-34]	;jp
	mov	dx,[bp-32]
	mov	es:[bx-4],ax
	mov	es:[bx-2],dx
; Line 780
	jmp	SHORT $WC321
$WB322:
; Line 781
	cmp	WORD PTR [bp-2],0	;muflg
	jne	$JCC3201
	jmp	$L20052
$JCC3201:
; Line 782
	push	WORD PTR [bp-8]
	push	WORD PTR [bp-10]	;p
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	push	WORD PTR es:_ibuf[bx-2]
	push	WORD PTR es:_ibuf[bx-4]
	call	FAR PTR _compare
	add	sp,8
	mov	[bp-22],ax	;j
; Line 784
	mov	es,$T20009
	cmp	es:_cflg,0
	je	$I324
; Line 785
	or	ax,ax
	jle	$I325
; Line 786
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	push	WORD PTR es:_ibuf[bx-2]
	push	WORD PTR es:_ibuf[bx-4]
	mov	ax,OFFSET DGROUP:$SG327
$L20053:
	push	ds
	push	ax
	call	FAR PTR _disorder
	add	sp,8
; Line 787
	jmp	SHORT $L20052
$I325:
	mov	es,$T20031
	cmp	es:_uflg,0
	je	$L20052
	cmp	WORD PTR [bp-22],0	;j
	jne	$L20052
; Line 788
	mov	bx,[bp-20]	;i
	shl	bx,2
	mov	es,$T20030
	push	WORD PTR es:_ibuf[bx-2]
	push	WORD PTR es:_ibuf[bx-4]
	mov	ax,OFFSET DGROUP:$SG330
	jmp	SHORT $L20053
$I324:
	cmp	WORD PTR [bp-22],0	;j
	jne	$JCC3340
	jmp	$I311
$JCC3340:
; Line 790
$L20052:
	cmp	WORD PTR [bp-20],0	;i
	jle	$JCC3349
	jmp	$WC306
$JCC3349:
; Line 794
	mov	es,$T20010
	mov	ax,WORD PTR es:_lspace
	mov	dx,WORD PTR es:_lspace+2
	mov	[bp-10],ax	;p
	mov	[bp-8],dx
; Line 795
	mov	ax,[bp+6]	;a
	mov	[bp-20],ax	;i
	jmp	SHORT $L20051
$F333:
; Line 796
	les	bx,[bp-10]	;p
	push	WORD PTR es:[bx+1026]
	push	WORD PTR es:[bx+1024]
	call	FAR PTR _fclose
	add	sp,4
; Line 797
	add	WORD PTR [bp-10],1028	;p
; Line 798
	mov	es,$T20002
	mov	ax,es:_eargc
	cmp	[bp-20],ax	;i
	jl	$FC334
; Line 799
	push	WORD PTR [bp-20]	;i
	call	FAR PTR _setfil
	add	sp,2
	push	dx
	push	ax
	call	FAR PTR _unlink
	add	sp,4
; Line 800
$FC334:
	inc	WORD PTR [bp-20]	;i
$L20051:
	mov	ax,[bp+8]	;b
	cmp	[bp-20],ax	;i
	jl	$F333
; Line 801
	mov	es,$T20029
	push	WORD PTR es:_os+2
	push	WORD PTR es:_os
	call	FAR PTR _fclose
; Line 802
	leave	
	ret	

_merge	ENDP
;	s = 6
;	t = 10
; Line 805
	PUBLIC	_disorder
_disorder	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	u = -4
; Line 808
	mov	ax,[bp+10]	;t
	mov	dx,[bp+12]
	mov	[bp-4],ax	;u
	mov	[bp-2],dx
	jmp	SHORT $L20054
$F342:
	inc	WORD PTR [bp-4]	;u
$L20054:
	les	bx,[bp-4]	;u
	cmp	BYTE PTR es:[bx],10
	jne	$F342
; Line 809
	mov	BYTE PTR es:[bx],0
; Line 810
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;t
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;s
	call	FAR PTR _diag
	add	sp,8
; Line 811
	call	FAR PTR _term
; Line 812
	leave	
	ret	

_disorder	ENDP
; Line 815
	PUBLIC	_newfile
_newfile	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,4
	call	FAR PTR __chkstk
;	f = -4
; Line 818
	mov	es,$T20019
	push	es:_nfiles
	call	FAR PTR _setfil
	add	sp,2
	mov	[bp-4],ax	;f
	mov	[bp-2],dx
; Line 819
	mov	ax,OFFSET DGROUP:$SG349
	push	ds
	push	ax
	push	dx
	push	WORD PTR [bp-4]	;f
	call	FAR PTR _fopen
	add	sp,8
	mov	es,$T20029
	mov	WORD PTR es:_os,ax
	mov	WORD PTR es:_os+2,dx
	or	ax,dx
	jne	$I348
; Line 820
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;f
	mov	ax,OFFSET DGROUP:$SG350
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 821
	call	FAR PTR _term
; Line 823
$I348:
	mov	es,$T20019
	inc	es:_nfiles
; Line 824
	leave	
	ret	

_newfile	ENDP
;	i = 6
; Line 828
	PUBLIC	_setfil
_setfil	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
	push	si
; Line 830
	mov	es,$T20002
	mov	ax,es:_eargc
	cmp	[bp+6],ax	;i
	jge	$I353
; Line 831
	mov	bx,[bp+6]	;i
	shl	bx,2
	mov	es,$T20001
	les	si,DWORD PTR es:_eargv
	les	bx,es:[bx][si]
	cmp	BYTE PTR es:[bx],45
	jne	$I354
	mov	bx,[bp+6]	;i
	shl	bx,2
	mov	es,$T20001
	mov	es,WORD PTR es:_eargv+2
	les	bx,es:[bx][si]
	cmp	BYTE PTR es:[bx+1],0
	jne	$I354
; Line 832
	sub	ax,ax
	cwd	
	jmp	SHORT $EX352
$I354:
; Line 834
	mov	bx,[bp+6]	;i
	shl	bx,2
	mov	es,$T20001
	les	si,DWORD PTR es:_eargv
	mov	ax,es:[bx][si]
	mov	dx,es:[bx+2][si]
	jmp	SHORT $EX352
$I353:
	mov	es,$T20002
	mov	ax,es:_eargc
	sub	[bp+6],ax	;i
; Line 836
	mov	ax,[bp+6]	;i
	cwd	
	mov	cx,26
	idiv	cx
	add	al,97
	mov	es,$T20015
	les	bx,DWORD PTR es:_filep
	mov	es:[bx],al
; Line 837
	mov	ax,[bp+6]	;i
	cwd	
	idiv	cx
	add	dl,97
	mov	es,$T20015
	les	bx,DWORD PTR es:_filep
	mov	es:[bx+1],dl
; Line 838
	mov	ax,WORD PTR _file
	mov	dx,WORD PTR _file+2
$EX352:
	pop	si
	leave	
	ret	

_setfil	ENDP
; Line 842
	PUBLIC	_oldfile
_oldfile	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 844
	mov	es,$T20003
	mov	ax,WORD PTR es:_outfil
	or	ax,WORD PTR es:_outfil+2
	je	$I357
; Line 845
	mov	ax,OFFSET DGROUP:$SG359
	push	ds
	push	ax
	push	WORD PTR es:_outfil+2
	push	WORD PTR es:_outfil
	call	FAR PTR _fopen
	add	sp,8
	mov	es,$T20029
	mov	WORD PTR es:_os,ax
	mov	WORD PTR es:_os+2,dx
	or	ax,dx
	jne	$I361
; Line 846
	mov	es,$T20003
	push	WORD PTR es:_outfil+2
	push	WORD PTR es:_outfil
	mov	ax,OFFSET DGROUP:$SG360
	push	ds
	push	ax
	call	FAR PTR _diag
	add	sp,8
; Line 847
	call	FAR PTR _term
; Line 849
	jmp	SHORT $I361
$I357:
; Line 850
	mov	es,$T20029
	mov	WORD PTR es:_os,OFFSET __iob+16
	mov	WORD PTR es:_os+2,SEG __iob
$I361:
; Line 851
	leave	
	ret	

_oldfile	ENDP
; Line 854
	PUBLIC	_safeoutfil
_safeoutfil	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,110
	call	FAR PTR __chkstk
	push	si
;	ibuf = -54
;	i = -56
;	obuf = -110
; Line 858
	mov	es,$T20020
	cmp	es:_mflg,0
	jne	$JCC3953
	jmp	$FB372
$JCC3953:
	mov	es,$T20003
	mov	ax,WORD PTR es:_outfil
	or	ax,WORD PTR es:_outfil+2
	jne	$JCC3971
	jmp	$FB372
$JCC3971:
; Line 859
	lea	ax,[bp-110]	;obuf
	push	ss
	push	ax
	push	WORD PTR es:_outfil+2
	push	WORD PTR es:_outfil
	call	FAR PTR _stat
	add	sp,8
	inc	ax
	je	$FB372
; Line 861
	mov	es,$T20002
	mov	ax,es:_eargc
	sub	ax,7
	mov	[bp-56],ax	;i
$F370:
	mov	es,$T20002
	mov	ax,es:_eargc
	cmp	[bp-56],ax	;i
	jge	$FB372
; Line 863
	lea	ax,[bp-54]	;ibuf
	push	ss
	push	ax
	mov	bx,[bp-56]	;i
	shl	bx,2
	mov	es,$T20001
	les	si,DWORD PTR es:_eargv
	push	WORD PTR es:[bx+2][si]
	push	WORD PTR es:[bx][si]
	call	FAR PTR _stat
	add	sp,8
	inc	ax
	je	$FC371
; Line 866
	mov	ax,[bp-54]	;ibuf
	cmp	[bp-110],ax	;obuf
	jne	$FC371
	mov	ax,[bp-52]
	mov	dx,[bp-50]
	cmp	[bp-106],dx
	jne	$FC371
	cmp	[bp-108],ax
	jne	$FC371
; Line 867
	mov	es,$T20023
	inc	es:_unsafeout
; Line 868
$FC371:
	inc	WORD PTR [bp-56]	;i
	jmp	SHORT $F370
$FB372:
; Line 869
	pop	si
	leave	
	ret	

_safeoutfil	ENDP
;	f = 6
; Line 872
	PUBLIC	_cant
_cant	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 875
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;f
	call	FAR PTR _perror
	add	sp,4
; Line 876
	call	FAR PTR _term
; Line 877
	leave	
	ret	

_cant	ENDP
;	s = 6
;	t = 10
; Line 880
	PUBLIC	_diag
_diag	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 882
	mov	ax,OFFSET __iob+32
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG382
	push	ds
	push	ax
	call	FAR PTR _fputs
	add	sp,8
; Line 883
	mov	ax,OFFSET __iob+32
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;s
	call	FAR PTR _fputs
	add	sp,8
; Line 884
	mov	ax,OFFSET __iob+32
	mov	dx,SEG __iob
	push	dx
	push	ax
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;t
	call	FAR PTR _fputs
	add	sp,8
; Line 885
	mov	ax,OFFSET __iob+32
	mov	dx,SEG __iob
	push	dx
	push	ax
	mov	ax,OFFSET DGROUP:$SG383
	push	ds
	push	ax
	call	FAR PTR _fputs
; Line 886
	leave	
	ret	

_diag	ENDP
; Line 889
	PUBLIC	_term
_term	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,2
	call	FAR PTR __chkstk
;	i = -2
; Line 892
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 2
	call	FAR PTR _signal
	add	sp,6
; Line 893
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 1
	call	FAR PTR _signal
	add	sp,6
; Line 894
	push	WORD PTR 0
	push	WORD PTR 1
	push	WORD PTR 15
	call	FAR PTR _signal
	add	sp,6
; Line 895
	mov	es,$T20002
	mov	ax,es:_eargc
	mov	es,$T20019
	cmp	es:_nfiles,ax
	jne	$I386
; Line 896
	inc	es:_nfiles
; Line 897
$I386:
	mov	es,$T20002
	mov	ax,es:_eargc
	mov	[bp-2],ax	;i
	jmp	SHORT $L20055
$F387:
; Line 898
	push	WORD PTR [bp-2]	;i
	call	FAR PTR _setfil
	add	sp,2
	push	dx
	push	ax
	call	FAR PTR _unlink
	add	sp,4
; Line 899
	inc	WORD PTR [bp-2]	;i
$L20055:
	mov	es,$T20019
	mov	ax,es:_nfiles
	cmp	[bp-2],ax	;i
	jle	$F387
; Line 900
	push	_error
	call	FAR PTR _exit
; Line 901
	leave	
	ret	

_term	ENDP
;	i = 6
SORT_TEXT      ENDS
CONST      SEGMENT
$T20034	DW SEG _tabchar 
CONST      ENDS
SORT_TEXT      SEGMENT
SORT_TEXT      ENDS
CONST      SEGMENT
$T20035	DW SEG __ctype_ 
CONST      ENDS
SORT_TEXT      SEGMENT
;	j = 10
; Line 904
	PUBLIC	_cmp
_cmp	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,54
	call	FAR PTR __chkstk
	push	si
;	pa = -4
;	pb = -8
;	sa = -10
;	sb = -12
;	code = -16
;	fp = -20
;	ipa = -24
;	ignore = -28
;	jpa = -32
;	ipb = -36
;	la = -40
;	jpb = -44
;	lb = -48
;	k = -50
;	a = -52
;	b = -54
; Line 917
	mov	es,$T20006
	cmp	es:_nfields,0
	jle	$L20032
	mov	ax,1
	jmp	SHORT $L20033
$L20032:
	sub	ax,ax
$L20033:
	mov	[bp-50],ax	;k
$F411:
	mov	es,$T20006
	mov	ax,es:_nfields
	cmp	[bp-50],ax	;k
	jle	$JCC4417
	jmp	$FB413
$JCC4417:
; Line 918
	imul	ax,WORD PTR [bp-50],24	;k
	add	ax,OFFSET _fields
	mov	[bp-20],ax	;fp
	mov	[bp-18],SEG _fields
; Line 919
	mov	ax,[bp+6]	;i
	mov	dx,[bp+8]
	mov	[bp-4],ax	;pa
	mov	[bp-2],dx
; Line 920
	mov	ax,[bp+10]	;j
	mov	dx,[bp+12]
	mov	[bp-8],ax	;pb
	mov	[bp-6],dx
; Line 921
	cmp	WORD PTR [bp-50],0	;k
	je	$I415
; Line 922
	push	WORD PTR 1
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;fp
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;pa
	call	FAR PTR _skip
	add	sp,10
	mov	[bp-40],ax	;la
	mov	[bp-38],dx
; Line 923
	push	WORD PTR 0
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;fp
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;pa
	call	FAR PTR _skip
	add	sp,10
	mov	[bp-4],ax	;pa
	mov	[bp-2],dx
; Line 924
	push	WORD PTR 1
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;fp
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;pb
	call	FAR PTR _skip
	add	sp,10
	mov	[bp-48],ax	;lb
	mov	[bp-46],dx
; Line 925
	push	WORD PTR 0
	push	WORD PTR [bp-18]
	push	WORD PTR [bp-20]	;fp
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;pb
	call	FAR PTR _skip
	add	sp,10
	mov	[bp-8],ax	;pb
	mov	[bp-6],dx
; Line 926
	jmp	SHORT $I416
$I415:
; Line 927
	push	WORD PTR [bp-2]
	push	WORD PTR [bp-4]	;pa
	call	FAR PTR _eol
	add	sp,4
	mov	[bp-40],ax	;la
	mov	[bp-38],dx
; Line 928
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;pb
	call	FAR PTR _eol
	add	sp,4
	mov	[bp-48],ax	;lb
	mov	[bp-46],dx
; Line 929
$I416:
; Line 930
	les	bx,[bp-20]	;fp
	cmp	WORD PTR es:[bx+8],0
	jne	$JCC4629
	jmp	$I417
$JCC4629:
; Line 931
	mov	es,$T20034
	cmp	es:_tabchar,0
	je	$I420
; Line 932
	mov	ax,[bp-40]	;la
	mov	dx,[bp-38]
	cmp	[bp-4],ax	;pa
	jae	$I419
	mov	al,es:_tabchar
	les	bx,[bp-4]	;pa
	cmp	es:[bx],al
	jne	$I419
; Line 933
	inc	WORD PTR [bp-4]	;pa
; Line 934
$I419:
	mov	ax,[bp-48]	;lb
	mov	dx,[bp-46]
	cmp	[bp-8],ax	;pb
	jae	$I420
	mov	es,$T20034
	mov	al,es:_tabchar
	les	bx,[bp-8]	;pb
	cmp	es:[bx],al
	jne	$I420
; Line 935
	inc	WORD PTR [bp-8]	;pb
; Line 936
$I420:
; Line 937
	les	bx,[bp-4]	;pa
	cmp	BYTE PTR es:[bx],32
	je	$WB423
	cmp	BYTE PTR es:[bx],9
	jne	$WB422
$WB423:
; Line 938
	inc	WORD PTR [bp-4]	;pa
	jmp	SHORT $I420
$WB422:
; Line 939
	les	bx,[bp-8]	;pb
	cmp	BYTE PTR es:[bx],32
	je	$WB426
	cmp	BYTE PTR es:[bx],9
	jne	$WB425
$WB426:
; Line 940
	inc	WORD PTR [bp-8]	;pb
	jmp	SHORT $WB422
$WB425:
; Line 941
	les	bx,[bp-20]	;fp
	mov	ax,es:[bx+10]
	mov	[bp-12],ax	;sb
	mov	[bp-10],ax	;sa
; Line 942
	les	bx,[bp-4]	;pa
	cmp	BYTE PTR es:[bx],45
	jne	$I427
; Line 943
	inc	WORD PTR [bp-4]	;pa
; Line 944
	neg	ax
	mov	[bp-10],ax	;sa
; Line 946
$I427:
	les	bx,[bp-8]	;pb
	cmp	BYTE PTR es:[bx],45
	jne	$I428
; Line 947
	inc	WORD PTR [bp-8]	;pb
; Line 948
	mov	ax,[bp-12]	;sb
	neg	ax
	mov	[bp-12],ax	;sb
; Line 950
$I428:
	mov	ax,[bp-4]	;pa
	mov	dx,[bp-2]
	mov	[bp-24],ax	;ipa
	mov	[bp-22],dx
$F429:
	mov	ax,[bp-40]	;la
	mov	dx,[bp-38]
	cmp	[bp-24],ax	;ipa
	jae	$FB431
	les	bx,[bp-24]	;ipa
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20035
	test	BYTE PTR es:__ctype_[bx+1],4
	je	$FB431
	inc	WORD PTR [bp-24]	;ipa
	jmp	SHORT $F429
$FB431:
; Line 951
	mov	ax,[bp-8]	;pb
	mov	dx,[bp-6]
	mov	[bp-36],ax	;ipb
	mov	[bp-34],dx
$F433:
	mov	ax,[bp-48]	;lb
	mov	dx,[bp-46]
	cmp	[bp-36],ax	;ipb
	jae	$FB435
	les	bx,[bp-36]	;ipb
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20035
	test	BYTE PTR es:__ctype_[bx+1],4
	je	$FB435
	inc	WORD PTR [bp-36]	;ipb
	jmp	SHORT $F433
$FB435:
; Line 952
	mov	ax,[bp-24]	;ipa
	mov	dx,[bp-22]
	mov	[bp-32],ax	;jpa
	mov	[bp-30],dx
; Line 953
	mov	ax,[bp-36]	;ipb
	mov	dx,[bp-34]
	mov	[bp-44],ax	;jpb
	mov	[bp-42],dx
; Line 954
	mov	WORD PTR [bp-52],0	;a
; Line 955
	mov	ax,[bp-12]	;sb
	cmp	[bp-10],ax	;sa
	jne	$WB439
; Line 956
$WC438:
	mov	ax,[bp-4]	;pa
	mov	dx,[bp-2]
	cmp	[bp-24],ax	;ipa
	jbe	$WB439
	mov	ax,[bp-8]	;pb
	mov	dx,[bp-6]
	cmp	[bp-36],ax	;ipb
	jbe	$WB439
; Line 957
	dec	WORD PTR [bp-24]	;ipa
	les	bx,[bp-24]	;ipa
	mov	al,es:[bx]
	cbw	
	dec	WORD PTR [bp-36]	;ipb
	les	bx,[bp-36]	;ipb
	mov	cx,ax
	mov	al,es:[bx]
	cbw	
	sub	ax,cx
	mov	[bp-54],ax	;b
	or	ax,ax
	je	$WC438
; Line 958
	mov	[bp-52],ax	;a
; Line 959
	jmp	SHORT $WC438
$WB439:
	mov	ax,[bp-4]	;pa
	mov	dx,[bp-2]
	cmp	[bp-24],ax	;ipa
	jbe	$WB442
; Line 960
	dec	WORD PTR [bp-24]	;ipa
	les	bx,[bp-24]	;ipa
	cmp	BYTE PTR es:[bx],48
	je	$WB439
; Line 961
$L20063:
	mov	ax,[bp-10]	;sa
$L20056:
	neg	ax
	jmp	$EX393
$WB442:
	mov	ax,[bp-8]	;pb
	mov	dx,[bp-6]
	cmp	[bp-36],ax	;ipb
	jbe	$WB445
; Line 963
	dec	WORD PTR [bp-36]	;ipb
	les	bx,[bp-36]	;ipb
	cmp	BYTE PTR es:[bx],48
	je	$WB442
; Line 964
$L20058:
	mov	ax,[bp-12]	;sb
	jmp	$EX393
$WB445:
	cmp	WORD PTR [bp-52],0	;a
	je	$I447
	mov	ax,[bp-52]	;a
$L20059:
	imul	WORD PTR [bp-10]	;sa
	jmp	$EX393
$I447:
	les	bx,[bp-32]	;jpa
	mov	[bp-4],bx	;pa
	mov	[bp-2],es
	cmp	BYTE PTR es:[bx],46
	jne	$I448
; Line 967
	inc	WORD PTR [bp-4]	;pa
; Line 968
$I448:
	les	bx,[bp-44]	;jpb
	mov	[bp-8],bx	;pb
	mov	[bp-6],es
	cmp	BYTE PTR es:[bx],46
	jne	$I449
; Line 969
	inc	WORD PTR [bp-8]	;pb
; Line 970
$I449:
	mov	ax,[bp-12]	;sb
	cmp	[bp-10],ax	;sa
	jne	$WB452
; Line 972
$WC451:
	mov	ax,[bp-40]	;la
	mov	dx,[bp-38]
	cmp	[bp-4],ax	;pa
	jae	$WB452
	les	bx,[bp-4]	;pa
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20035
	test	BYTE PTR es:__ctype_[bx+1],4
	je	$WB452
	mov	ax,[bp-48]	;lb
	mov	dx,[bp-46]
	cmp	[bp-8],ax	;pb
	jae	$WB452
	les	bx,[bp-8]	;pb
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20035
	test	BYTE PTR es:__ctype_[bx+1],4
	je	$WB452
; Line 973
	les	bx,[bp-4]	;pa
	inc	WORD PTR [bp-4]	;pa
	mov	al,es:[bx]
	cbw	
	les	bx,[bp-8]	;pb
	inc	WORD PTR [bp-8]	;pb
	mov	cx,ax
	mov	al,es:[bx]
	cbw	
	sub	ax,cx
	mov	[bp-52],ax	;a
	or	ax,ax
	je	$WC451
; Line 974
	jmp	$L20059
$WB452:
	mov	ax,[bp-40]	;la
	mov	dx,[bp-38]
	cmp	[bp-4],ax	;pa
	jae	$WB455
	les	bx,[bp-4]	;pa
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20035
	test	BYTE PTR es:__ctype_[bx+1],4
	je	$WB455
; Line 976
	les	bx,[bp-4]	;pa
	inc	WORD PTR [bp-4]	;pa
	cmp	BYTE PTR es:[bx],48
	je	$WB452
	jmp	$L20063
$WB455:
	mov	ax,[bp-48]	;lb
	mov	dx,[bp-46]
	cmp	[bp-8],ax	;pb
	jae	$FC412
	les	bx,[bp-8]	;pb
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20035
	test	BYTE PTR es:__ctype_[bx+1],4
	je	$FC412
; Line 979
	les	bx,[bp-8]	;pb
	inc	WORD PTR [bp-8]	;pb
	cmp	BYTE PTR es:[bx],48
	je	$WB455
	jmp	$L20058
$FC412:
	inc	WORD PTR [bp-50]	;k
	jmp	$F411
$I417:
	les	bx,[bp-20]	;fp
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-16],ax	;code
	mov	[bp-14],dx
; Line 984
	mov	ax,es:[bx+4]
	mov	dx,es:[bx+6]
	mov	[bp-28],ax	;ignore
	mov	[bp-26],dx
; Line 986
	jmp	SHORT $L20061
$WC461:
; Line 987
	inc	WORD PTR [bp-4]	;pa
$L20061:
	les	bx,[bp-4]	;pa
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	les	si,[bp-28]	;ignore
	cmp	BYTE PTR es:[bx][si],0
	jne	$WC461
; Line 988
	jmp	SHORT $L20062
$WC463:
; Line 989
	inc	WORD PTR [bp-8]	;pb
$L20062:
	les	bx,[bp-8]	;pb
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	les	si,[bp-28]	;ignore
	cmp	BYTE PTR es:[bx][si],0
	jne	$WC463
; Line 990
	mov	ax,[bp-40]	;la
	mov	dx,[bp-38]
	cmp	[bp-4],ax	;pa
	jae	$I466
	les	bx,[bp-4]	;pa
	cmp	BYTE PTR es:[bx],10
	jne	$I465
$I466:
; Line 991
	mov	ax,[bp-48]	;lb
	mov	dx,[bp-46]
	cmp	[bp-8],ax	;pb
	jae	$FC412
	les	bx,[bp-8]	;pb
	cmp	BYTE PTR es:[bx],10
	je	$FC412
; Line 992
	les	bx,[bp-20]	;fp
	mov	ax,es:[bx+10]
	jmp	$EX393
$I465:
	mov	ax,[bp-48]	;lb
	mov	dx,[bp-46]
	cmp	[bp-8],ax	;pb
	jae	$I470
	les	bx,[bp-8]	;pb
	cmp	BYTE PTR es:[bx],10
	jne	$I469
$I470:
; Line 995
	les	bx,[bp-20]	;fp
	mov	ax,es:[bx+10]
	jmp	$L20056
$I469:
	les	bx,[bp-4]	;pa
	inc	WORD PTR [bp-4]	;pa
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	les	si,[bp-16]	;code
	mov	al,es:[bx][si]
	cbw	
	les	bx,[bp-8]	;pb
	inc	WORD PTR [bp-8]	;pb
	mov	cx,ax
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,[bp-14]
	mov	al,es:[bx][si]
	cbw	
	sub	ax,cx
	mov	[bp-10],ax	;sa
	or	ax,ax
	jne	$JCC5505
	jmp	$L20061
$JCC5505:
; Line 997
	les	bx,[bp-20]	;fp
	mov	ax,es:[bx+10]
	jmp	$L20059
$FB413:
; Line 1000
	mov	es,$T20031
	cmp	es:_uflg,0
	je	$I472
; Line 1001
	sub	ax,ax
	jmp	SHORT $EX393
$I472:
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;j
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;i
	call	FAR PTR _cmpa
	add	sp,8
$EX393:
	pop	si
	leave	
	ret	

_cmp	ENDP
;	pa = 6
SORT_TEXT      ENDS
CONST      SEGMENT
$T20042	DW SEG _fields 
CONST      ENDS
SORT_TEXT      SEGMENT
;	pb = 10
; Line 1006
	PUBLIC	_cmpa
_cmpa	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 1008
	jmp	SHORT $L20064
$WC476:
; Line 1009
	les	bx,[bp+6]	;pa
	inc	WORD PTR [bp+6]	;pa
	cmp	BYTE PTR es:[bx],10
	jne	$I478
; Line 1010
	sub	ax,ax
	jmp	SHORT $L20041
$I478:
	inc	WORD PTR [bp+10]	;pb
; Line 1012
$L20064:
	les	bx,[bp+10]	;pb
	mov	al,es:[bx]
	les	bx,[bp+6]	;pa
	cmp	es:[bx],al
	je	$WC476
; Line 1018
	cmp	BYTE PTR es:[bx],10
	jne	$L20036
$L20065:
	mov	es,$T20042
	mov	ax,WORD PTR es:_fields+10
	jmp	SHORT $L20041
$L20036:
	les	bx,[bp+10]	;pb
	cmp	BYTE PTR es:[bx],10
	je	$L20066
	les	bx,[bp+6]	;pa
	mov	al,es:[bx]
	les	bx,[bp+10]	;pb
	cmp	es:[bx],al
	jg	$L20065
$L20066:
	mov	es,$T20042
	mov	ax,WORD PTR es:_fields+10
	neg	ax
$L20041:
	leave	
	ret	

_cmpa	ENDP
;	pp = 6
;	fp = 10
;	j = 14
; Line 1023
	PUBLIC	_skip
_skip	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,6
	call	FAR PTR __chkstk
	push	si
;	p = -4
;	i = -6
; Line 1029
	mov	ax,[bp+6]	;pp
	mov	dx,[bp+8]
	mov	[bp-4],ax	;p
	mov	[bp-2],dx
; Line 1030
	mov	si,[bp+14]	;j
	shl	si,1
	les	bx,[bp+10]	;fp
	mov	ax,es:[bx+16][si]
	mov	[bp-6],ax	;i
	or	ax,ax
	jge	$WB501
; Line 1031
	push	dx
	push	WORD PTR [bp-4]	;p
	call	FAR PTR _eol
	add	sp,4
	jmp	$EX482
$WC486:
; Line 1033
	mov	es,$T20034
	cmp	es:_tabchar,0
	je	$I488
; Line 1034
	jmp	SHORT $L20068
$WC489:
; Line 1035
	cmp	BYTE PTR es:[bx],10
	jne	$JCC5731
	jmp	$WB510
$JCC5731:
; Line 1036
	inc	WORD PTR [bp-4]	;p
; Line 1037
$L20068:
	mov	es,$T20034
	mov	al,es:_tabchar
	les	bx,[bp-4]	;p
	cmp	es:[bx],al
	jne	$WC489
; Line 1038
	cmp	WORD PTR [bp-6],0	;i
	jg	$I495
	cmp	WORD PTR [bp+14],0	;j
	jne	$WB501
$I495:
; Line 1039
	inc	WORD PTR [bp-4]	;p
; Line 1040
$WB501:
; Line 1048
	mov	ax,[bp-6]	;i
	dec	WORD PTR [bp-6]	;i
	or	ax,ax
	jg	$WC486
; Line 1049
	mov	es,$T20034
	cmp	es:_tabchar,0
	je	$I505
	mov	si,[bp+14]	;j
	shl	si,1
	les	bx,[bp+10]	;fp
	cmp	WORD PTR es:[bx+12][si],0
	je	$WB507
$I505:
; Line 1050
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],32
	je	$WB508
	cmp	BYTE PTR es:[bx],9
	jne	$WB507
$WB508:
; Line 1051
	inc	WORD PTR [bp-4]	;p
	jmp	SHORT $I505
$I488:
; Line 1041
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],32
	je	$WB499
	cmp	BYTE PTR es:[bx],9
	jne	$WB498
$WB499:
; Line 1042
	inc	WORD PTR [bp-4]	;p
	jmp	SHORT $I488
$WB498:
; Line 1043
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],32
	je	$WB501
	cmp	BYTE PTR es:[bx],9
	je	$WB501
; Line 1044
	cmp	BYTE PTR es:[bx],10
	je	$WB510
; Line 1045
	inc	WORD PTR [bp-4]	;p
; Line 1046
	jmp	SHORT $WB498
$WB507:
; Line 1052
	mov	si,[bp+14]	;j
	shl	si,1
	les	bx,[bp+10]	;fp
	mov	ax,es:[bx+20][si]
	mov	[bp-6],ax	;i
; Line 1053
$WC509:
	mov	ax,[bp-6]	;i
	dec	WORD PTR [bp-6]	;i
	or	ax,ax
	jle	$WB510
; Line 1054
	les	bx,[bp-4]	;p
	cmp	BYTE PTR es:[bx],10
	je	$WB510
; Line 1055
	inc	WORD PTR [bp-4]	;p
; Line 1057
	jmp	SHORT $WC509
$WB510:
; Line 1059
	mov	ax,[bp-4]	;p
	mov	dx,[bp-2]
$EX482:
	pop	si
	leave	
	ret	

_skip	ENDP
;	p = 6
; Line 1064
	PUBLIC	_eol
_eol	PROC FAR
	push	bp
	mov	bp,sp
	xor	ax,ax
	call	FAR PTR __chkstk
; Line 1066
	jmp	SHORT $L20069
$WC515:
	inc	WORD PTR [bp+6]	;p
$L20069:
	les	bx,[bp+6]	;p
	cmp	BYTE PTR es:[bx],10
	jne	$WC515
; Line 1067
	mov	ax,bx
	mov	dx,es
	leave	
	ret	

_eol	ENDP
; Line 1071
	PUBLIC	_copyproto
_copyproto	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,10
	call	FAR PTR __chkstk
;	p = -4
;	q = -8
;	i = -10
; Line 1075
	mov	ax,OFFSET DGROUP:_proto
	mov	[bp-4],ax	;p
	mov	[bp-2],ds
; Line 1076
	mov	es,$T20006
	imul	ax,es:_nfields,24
	add	ax,OFFSET _fields
	mov	[bp-8],ax	;q
	mov	[bp-6],SEG _fields
; Line 1077
	mov	WORD PTR [bp-10],0	;i
$F521:
; Line 1078
	les	bx,[bp-4]	;p
	add	WORD PTR [bp-4],2	;p
	mov	ax,es:[bx]
	les	bx,[bp-8]	;q
	add	WORD PTR [bp-8],2	;q
	mov	es:[bx],ax
	inc	WORD PTR [bp-10]	;i
	cmp	WORD PTR [bp-10],12	;i
	jl	$F521
; Line 1079
	leave	
	ret	

_copyproto	ENDP
;	s = 6
;	k = 10
; Line 1082
	PUBLIC	_field
_field	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,6
	call	FAR PTR __chkstk
	push	si
;	d = -2
;	p = -6
; Line 1086
	mov	es,$T20006
	imul	ax,es:_nfields,24
	add	ax,OFFSET _fields
	mov	[bp-6],ax	;p
	mov	[bp-4],SEG _fields
; Line 1087
	mov	WORD PTR [bp-2],0	;d
; Line 1088
$F530:
	les	bx,[bp+6]	;s
	cmp	BYTE PTR es:[bx],0
	jne	$JCC6073
	jmp	$FB532
$JCC6073:
; Line 1089
	mov	al,es:[bx]
	cbw	
	cmp	ax,102
	je	$SC541
	jle	$JCC6087
	jmp	$L20043
$JCC6087:
	or	ax,ax
	jne	$JCC6094
	jmp	$FB532
$JCC6094:
	cmp	ax,46
	jne	$JCC6102
	jmp	$SC550
$JCC6102:
	cmp	ax,98
	je	$SC539
	cmp	ax,99
	je	$SC543
	cmp	ax,100
	je	$SC540
	jmp	$SD552
$SC539:
; Line 1094
	mov	si,[bp+10]	;k
	shl	si,1
	les	bx,[bp-6]	;p
	inc	WORD PTR es:[bx+12][si]
; Line 1095
$SB535:
; Line 1139
	mov	WORD PTR _compare,OFFSET _cmp
	mov	WORD PTR _compare+2,SEG _cmp
; Line 1140
	jmp	SHORT $FC531
$SC540:
; Line 1098
	les	bx,[bp-6]	;p
	mov	ax,OFFSET DGROUP:_dict+128
$L20071:
	mov	es:[bx+4],ax
	mov	es:[bx+6],ds
; Line 1099
	jmp	SHORT $SB535
$SC541:
; Line 1102
	les	bx,[bp-6]	;p
	mov	ax,OFFSET DGROUP:_fold+128
	mov	es:[bx],ax
	mov	es:[bx+2],ds
; Line 1103
	jmp	SHORT $SB535
$SC542:
; Line 1105
	les	bx,[bp-6]	;p
	mov	ax,OFFSET DGROUP:_nonprint+128
	jmp	SHORT $L20071
$SC543:
; Line 1109
	mov	es,$T20009
	mov	es:_cflg,1
; Line 1110
$FC531:
	inc	WORD PTR [bp+6]	;s
	jmp	$F530
$SC544:
; Line 1113
	mov	es,$T20020
	mov	es:_mflg,1
; Line 1114
	jmp	SHORT $FC531
$SC545:
; Line 1117
	les	bx,[bp-6]	;p
	inc	WORD PTR es:[bx+8]
; Line 1118
	jmp	SHORT $SB535
$SC546:
; Line 1120
	inc	WORD PTR [bp+6]	;s
	les	bx,[bp+6]	;s
	mov	al,es:[bx]
	mov	es,$T20034
	mov	es:_tabchar,al
; Line 1121
	or	al,al
	jne	$FC531
	dec	WORD PTR [bp+6]	;s
; Line 1122
	jmp	SHORT $FC531
$SC548:
; Line 1125
	les	bx,[bp-6]	;p
	mov	WORD PTR es:[bx+10],-1
; Line 1126
	jmp	SHORT $FC531
$SC549:
; Line 1128
	mov	es,$T20031
	mov	es:_uflg,1
; Line 1129
	jmp	$SB535
$SC550:
; Line 1132
	mov	si,[bp+10]	;k
	shl	si,1
	les	bx,[bp-6]	;p
	cmp	WORD PTR es:[bx+16][si],-1
	jne	$I551
; Line 1133
	mov	si,[bp+10]	;k
	shl	si,1
	mov	WORD PTR es:[bx+16][si],0
; Line 1134
$I551:
	mov	WORD PTR [bp-2],2	;d
; Line 1136
$SD552:
; Line 1137
	lea	ax,[bp+6]	;s
	push	ss
	push	ax
	call	FAR PTR _number
	add	sp,4
	mov	si,[bp+10]	;k
	add	si,[bp-2]	;d
	shl	si,1
	les	bx,[bp-6]	;p
	mov	es:[bx+16][si],ax
; Line 1138
	jmp	$SB535
$L20043:
	cmp	ax,105
	jne	$JCC6345
	jmp	$SC542
$JCC6345:
	cmp	ax,109
	jne	$JCC6353
	jmp	$SC544
$JCC6353:
	cmp	ax,110
	jne	$JCC6361
	jmp	$SC545
$JCC6361:
	cmp	ax,114
	je	$SC548
	cmp	ax,116
	jne	$JCC6374
	jmp	$SC546
$JCC6374:
	cmp	ax,117
	je	$SC549
	jmp	SHORT $SD552
$FB532:
; Line 1141
	pop	si
	leave	
	ret	

_field	ENDP
;	ppa = 6
; Line 1144
	PUBLIC	_number
_number	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,6
	call	FAR PTR __chkstk
;	pa = -4
;	n = -6
; Line 1148
	les	bx,[bp+6]	;ppa
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-4],ax	;pa
	mov	[bp-2],dx
; Line 1149
	mov	WORD PTR [bp-6],0	;n
; Line 1150
	jmp	SHORT $L20072
$WC558:
; Line 1151
	les	bx,[bp-4]	;pa
	mov	al,es:[bx]
	cbw	
	imul	cx,WORD PTR [bp-6],10	;n
	add	cx,ax
	sub	cx,48
	mov	[bp-6],cx	;n
; Line 1152
	les	bx,[bp+6]	;ppa
	mov	ax,[bp-4]	;pa
	mov	dx,[bp-2]
	inc	WORD PTR [bp-4]	;pa
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 1153
$L20072:
	les	bx,[bp-4]	;pa
	mov	al,es:[bx]
	cbw	
	mov	bx,ax
	mov	es,$T20035
	test	BYTE PTR es:__ctype_[bx+1],4
	jne	$WC558
; Line 1154
	mov	ax,[bp-6]	;n
	leave	
	ret	

_number	ENDP
;	a = 6
;	l = 10
; Line 1161
	PUBLIC	_qsort
_qsort	PROC FAR
	push	bp
	mov	bp,sp
	mov	ax,28
	call	FAR PTR __chkstk
;	n = -2
;	c = -4
;	lp = -8
;	t = -12
;	i = -16
;	hp = -20
;	j = -24
;	k = -28
; Line 1172
$start571:
; Line 1173
	mov	ax,[bp+10]	;l
	sub	ax,[bp+6]	;a
	sar	ax,2
	mov	[bp-2],ax	;n
	cmp	ax,1
	ja	$JCC6513
	jmp	$EX562
$JCC6513:
; Line 1174
	shr	WORD PTR [bp-2],1	;n
; Line 1178
	mov	ax,[bp-2]	;n
	shl	ax,2
	add	ax,[bp+6]	;a
	mov	dx,[bp+8]
	mov	[bp-8],ax	;lp
	mov	[bp-6],dx
	mov	[bp-20],ax	;hp
	mov	[bp-18],dx
; Line 1179
	mov	ax,[bp+6]	;a
	mov	[bp-16],ax	;i
	mov	[bp-14],dx
; Line 1180
	mov	ax,[bp+10]	;l
	mov	dx,[bp+12]
	sub	ax,4
$L20074:
	mov	[bp-24],ax	;j
	mov	[bp-22],dx
; Line 1183
$F573:
; Line 1184
	mov	ax,[bp-8]	;lp
	mov	dx,[bp-6]
	cmp	[bp-16],ax	;i
	jb	$JCC6578
	jmp	$I578
$JCC6578:
; Line 1185
	les	bx,[bp-8]	;lp
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	les	bx,[bp-16]	;i
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _compare
	add	sp,8
	mov	[bp-4],ax	;c
	or	ax,ax
	jne	$I577
; Line 1186
	sub	WORD PTR [bp-8],4	;lp
; Line 1187
	les	bx,[bp-16]	;i
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-12],ax	;t
	mov	[bp-10],dx
	les	bx,[bp-8]	;lp
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-16]	;i
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	les	bx,[bp-8]	;lp
	mov	ax,[bp-12]	;t
	mov	dx,[bp-10]
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 1188
	jmp	SHORT $F573
$I577:
	cmp	WORD PTR [bp-4],0	;c
	jl	$JCC6679
	jmp	$I578
$JCC6679:
; Line 1191
$L20073:
	add	WORD PTR [bp-16],4	;i
; Line 1192
	jmp	SHORT $F573
$I581:
	cmp	WORD PTR [bp-4],0	;c
	jg	$JCC6694
	jmp	$I582
$JCC6694:
; Line 1204
	mov	ax,[bp-8]	;lp
	mov	dx,[bp-6]
	cmp	[bp-14],dx
	je	$JCC6708
	jmp	$I583
$JCC6708:
	cmp	[bp-16],ax	;i
	je	$JCC6716
	jmp	$I583
$JCC6716:
; Line 1205
	add	WORD PTR [bp-20],4	;hp
; Line 1206
	les	bx,[bp-16]	;i
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-12],ax	;t
	mov	[bp-10],dx
	les	bx,[bp-24]	;j
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-16]	;i
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	les	bx,[bp-20]	;hp
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-24]	;j
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	les	bx,[bp-20]	;hp
	mov	ax,[bp-12]	;t
	mov	dx,[bp-10]
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 1207
	add	WORD PTR [bp-8],4	;lp
	mov	ax,[bp-8]	;lp
	mov	dx,[bp-6]
	mov	[bp-16],ax	;i
	mov	[bp-14],dx
; Line 1208
$I578:
; Line 1197
	mov	ax,[bp-20]	;hp
	mov	dx,[bp-18]
	cmp	[bp-24],ax	;j
	ja	$JCC6822
	jmp	$I580
$JCC6822:
; Line 1198
	les	bx,[bp-24]	;j
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	les	bx,[bp-20]	;hp
	push	WORD PTR es:[bx+2]
	push	WORD PTR es:[bx]
	call	FAR PTR _compare
	add	sp,8
	mov	[bp-4],ax	;c
	or	ax,ax
	je	$JCC6859
	jmp	$I581
$JCC6859:
; Line 1199
	add	WORD PTR [bp-20],4	;hp
; Line 1200
	les	bx,[bp-20]	;hp
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-12],ax	;t
	mov	[bp-10],dx
	les	bx,[bp-24]	;j
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-20]	;hp
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	les	bx,[bp-24]	;j
	mov	ax,[bp-12]	;t
	mov	dx,[bp-10]
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 1201
	jmp	SHORT $I578
$I583:
	les	bx,[bp-16]	;i
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-12],ax	;t
	mov	[bp-10],dx
	les	bx,[bp-24]	;j
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-16]	;i
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	les	bx,[bp-24]	;j
	mov	ax,[bp-12]	;t
	mov	dx,[bp-10]
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 1211
	sub	WORD PTR [bp-24],4	;j
	jmp	$L20073
$I582:
	sub	WORD PTR [bp-24],4	;j
; Line 1216
	jmp	$I578
$I580:
	mov	ax,[bp-8]	;lp
	mov	dx,[bp-6]
	cmp	[bp-14],dx
	je	$JCC6997
	jmp	$I584
$JCC6997:
	cmp	[bp-16],ax	;i
	je	$JCC7005
	jmp	$I584
$JCC7005:
; Line 1221
	mov	es,$T20031
	cmp	es:_uflg,0
	je	$FB588
; Line 1222
	add	ax,4
	mov	[bp-28],ax	;k
	mov	[bp-26],dx
$F586:
	mov	ax,[bp-20]	;hp
	mov	dx,[bp-18]
	cmp	[bp-28],ax	;k
	ja	$FB588
	les	bx,[bp-28]	;k
	add	WORD PTR [bp-28],4	;k
	les	bx,es:[bx]
	mov	BYTE PTR es:[bx],0
	jmp	SHORT $F586
$FB588:
; Line 1223
	mov	ax,[bp-8]	;lp
	sub	ax,[bp+6]	;a
	sar	ax,2
	mov	cx,[bp+10]	;l
	sub	cx,[bp-20]	;hp
	sar	cx,2
	cmp	ax,cx
	jl	$I589
; Line 1224
	push	WORD PTR [bp+12]
	push	WORD PTR [bp+10]	;l
	mov	ax,[bp-20]	;hp
	mov	dx,[bp-18]
	add	ax,4
	push	dx
	push	ax
	call	FAR PTR _qsort
	add	sp,8
; Line 1225
	mov	ax,[bp-8]	;lp
	mov	dx,[bp-6]
	mov	[bp+10],ax	;l
	mov	[bp+12],dx
; Line 1226
	jmp	$start571
$I589:
; Line 1227
	push	WORD PTR [bp-6]
	push	WORD PTR [bp-8]	;lp
	push	WORD PTR [bp+8]
	push	WORD PTR [bp+6]	;a
	call	FAR PTR _qsort
	add	sp,8
; Line 1228
	mov	ax,[bp-20]	;hp
	mov	dx,[bp-18]
	add	ax,4
	mov	[bp+6],ax	;a
	mov	[bp+8],dx
; Line 1230
	jmp	$start571
$I584:
	sub	WORD PTR [bp-8],4	;lp
; Line 1235
	les	bx,[bp-24]	;j
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	mov	[bp-12],ax	;t
	mov	[bp-10],dx
	les	bx,[bp-16]	;i
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-24]	;j
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	les	bx,[bp-8]	;lp
	mov	ax,es:[bx]
	mov	dx,es:[bx+2]
	les	bx,[bp-16]	;i
	mov	es:[bx],ax
	mov	es:[bx+2],dx
	les	bx,[bp-8]	;lp
	mov	ax,[bp-12]	;t
	mov	dx,[bp-10]
	mov	es:[bx],ax
	mov	es:[bx+2],dx
; Line 1236
	sub	WORD PTR [bp-20],4	;hp
	mov	ax,[bp-20]	;hp
	mov	dx,[bp-18]
	jmp	$L20074
$EX562:
	leave	
	ret	

_qsort	ENDP
SORT_TEXT	ENDS
END
