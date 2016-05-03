static char *sccsid = "@(#)ptx.c	4.2 (Berkeley) 9/23/85";
extern	struct	_iobuf {
	int	_cnt;
	char	*_ptr;		
	char	*_base;		
	int	_bufsiz;
	short	_flag;
	char	_file;		
} _iob[];
struct _iobuf	*fopen();
struct _iobuf	*fdopen();
struct _iobuf	*freopen();
struct _iobuf	*popen();
long	ftell();
char	*fgets();
char	*gets();
char	*sprintf();		
extern	char	_ctype_[];
int	(*signal())();
struct	sigvec {
	int	(*sv_handler)();	
	int	sv_mask;		
	int	sv_flags;		
};
struct	sigstack {
	char	*ss_sp;			
	int	ss_onstack;		
};
struct	sigcontext {
	int	sc_onstack;		
	int	sc_mask;		
	int	sc_sp;			
	int	sc_fp;			
	int	sc_ap;			
	int	sc_pc;			
	int	sc_ps;			
};
extern char *calloc(), *mktemp();
extern char *getline();
int status;
char *hasht[2048];
char line[200];
char btable[128];
int ignore;
int only;
int llen = 72;
int gap = 3;
int gutter = 3;
int mlen = 200;
int wlen;
int rflag;
int halflen;
char *strtbufp, *endbufp;
char *empty = "";
char *infile;
struct _iobuf *inptr = (&_iob[0]);
char *outfile;
struct _iobuf *outptr = (&_iob[1]);
char *sortfile;	
char nofold[] = {'-', 'd', 't', 0177, 0};
char fold[] = {'-', 'd', 'f', 't', 0177, 0};
char *sortopt = nofold;
struct _iobuf *sortptr;
char *bfile;	
struct _iobuf *bptr;
main(argc,argv)
int argc;
char **argv;
{
	int c;
	char *bufp;
	int pid;
	char *pend;
	extern onintr();
	char *xfile;
	struct _iobuf *xptr;
	if(signal(1	,onintr)==	(int (*)())1)
		signal(1	,	(int (*)())1);
	if(signal(2	,onintr)==	(int (*)())1)
		signal(2	,	(int (*)())1);
	signal(13	,onintr);
	signal(15	,onintr);
	xfile = "/usr/lib/eign";
	argv++;
	while(argc>1 && **argv == '-') {
		switch (*++*argv){
		case 'r':
			rflag++;
			break;
		case 'f':
			sortopt = fold;
			break;
		case 'w':
			if(argc >= 2) {
				argc--;
				wlen++;
				llen = atoi(*++argv);
				if(llen == 0)
					diag("Wrong width:",*argv);
				if(llen > 200) {
					llen = 200;
					msg("Lines truncated to 200 chars.",empty);
				}
				break;
			}
		case 't':
			if(wlen == 0)
				llen = 100;
			break;
		case 'g':
			if(argc >=2) {
				argc--;
				gap = gutter = atoi(*++argv);
			}
			break;
		case 'i':
			if(only) 
				diag("Only file already given.",empty);
			if (argc>=2){
				argc--;
				ignore++;
				xfile = *++argv;
			}
			break;
		case 'o':
			if(ignore)
				diag("Ignore file already given",empty);
			if (argc>=2){
				only++;
				argc--;
				xfile = *++argv;
			}
			break;
		case 'b':
			if(argc>=2) {
				argc--;
				bfile = *++argv;
			}
			break;
		default:
			msg("Illegal argument:",*argv);
		}
		argc--;
		argv++;
	}
	if(argc>3)
		diag("Too many filenames",empty);
	else if(argc==3){
		infile = *argv++;
		outfile = *argv;
		if((outptr = fopen(outfile,"w")) == 0)
			diag("Cannot open output file:",outfile);
	} else if(argc==2) {
		infile = *argv;
		outfile = 0;
	}
	
	btable[' '] = 1;
	btable['\t'] = 1;
	btable['\n'] = 1;
	if(bfile) {
		if((bptr = fopen(bfile,"r")) == 0)
			diag("Cannot open break char file",bfile);
		while((c = 		(--(bptr)->_cnt>=0? (int)(*(unsigned char *)(bptr)->_ptr++):_filbuf(bptr))) != (-1))
			btable[c] = 1;
	}
	if((strtbufp = calloc(30,1024)) == 0)
		diag("Out of memory space",empty);
	bufp = strtbufp;
	endbufp = strtbufp+30*1024;
	if((xptr = fopen(xfile,"r")) == 0)
		diag("Cannot open  file",xfile);
	while(bufp < endbufp && (c = 		(--(xptr)->_cnt>=0? (int)(*(unsigned char *)(xptr)->_ptr++):_filbuf(xptr))) != (-1)) {
		if( (btable[c])) {
			if(storeh(hash(strtbufp,bufp),strtbufp))
				diag("Too many words",xfile);
			*bufp++ = '\0';
			strtbufp = bufp;
		}
		else {
			*bufp++ = (	((_ctype_+1)[c]&01)?	((c)-'A'+'a'):c);
		}
	}
	if (bufp >= endbufp)
		diag("Too many words in file",xfile);
	endbufp = --bufp;
	
	sortfile = mktemp("/tmp/ptxsXXXXX");
	if((sortptr = fopen(sortfile, "w")) == 0)
		diag("Cannot open output for sorting:",sortfile);
	if (infile!=0 && (inptr = fopen(infile,"r")) == 0)
		diag("Cannot open data: ",infile);
	while(pend=getline())
		cmpline(pend);
	fclose(sortptr);
	switch (pid = fork()){
	case -1:	
		diag("Cannot fork",empty);
	case 0:		
		execl("/usr/bin/sort", "/usr/bin/sort", sortopt, "+0", "-1", "+1",
			sortfile, "-o", sortfile, 0);
	default:	
		while(wait(&status) != pid);
	}
	getsort();
	if(*sortfile)
		unlink(sortfile);
	exit(0);
}
msg(s,arg)
char *s;
char *arg;
{
	fprintf((&_iob[2]),"%s %s\n",s,arg);
	return;
}
diag(s,arg)
char *s, *arg;
{
	msg(s,arg);
	exit(1);
}
char *getline()
{
	int	c;
	char *linep;
	char *endlinep;
	endlinep= line + mlen;
	linep = line;
	
	while(	((_ctype_+1)[c=		(--(inptr)->_cnt>=0? (int)(*(unsigned char *)(inptr)->_ptr++):_filbuf(inptr))]&010))
		;
	if(c==(-1))
		return(0);
	ungetc(c,inptr);
	while(( c=		(--(inptr)->_cnt>=0? (int)(*(unsigned char *)(inptr)->_ptr++):_filbuf(inptr))) != (-1)) {
		switch (c) {
			case '\t':
				if(linep<endlinep)
					*linep++ = ' ';
				break;
			case '\n':
				while(	((_ctype_+1)[*--linep]&010));
				*++linep = '\n';
				return(linep);
			default:
				if(linep < endlinep)
					*linep++ = c;
		}
	}
	return(0);
}
cmpline(pend)
char *pend;
{
	char *pstrt, *pchar, *cp;
	char **hp;
	int flag;
	pchar = line;
	if(rflag)
		while(pchar<pend&&!	((_ctype_+1)[*pchar]&010))
			pchar++;
	while(pchar<pend){
	
		if( (btable[*pchar++]))
			continue;
		pstrt = --pchar;
		flag = 1;
		while(flag){
			if( (btable[*pchar])) {
				hp = &hasht[hash(pstrt,pchar)];
				pchar--;
				while(cp = *hp++){
					if(hp == &hasht[2048])
						hp = hasht;
	
					if(cmpword(pstrt,pchar,cp)){
	
						if(!ignore && only)
							putline(pstrt,pend);
						flag = 0;
						break;
					}
				}
	
				if(flag){
					if(ignore || !only)
						putline(pstrt,pend);
					flag = 0;
				}
			}
		pchar++;
		}
	}
}
cmpword(cpp,pend,hpp)
char *cpp, *pend, *hpp;
{
	char c;
	while(*hpp != '\0'){
		c = *cpp++;
		if((	((_ctype_+1)[c]&01)?	((c)-'A'+'a'):c) != *hpp++)
			return(0);
	}
	if(--cpp == pend) return(1);
	return(0);
}
putline(strt, end)
char *strt, *end;
{
	char *cp;
	for(cp=strt; cp<end; cp++)
			(--( sortptr)->_cnt >= 0 ?	(int)(*(unsigned char *)( sortptr)->_ptr++ = (*cp)) :	((( sortptr)->_flag & 0200) && -( sortptr)->_cnt < ( sortptr)->_bufsiz ?		((*( sortptr)->_ptr = (*cp)) != '\n' ?			(int)(*(unsigned char *)( sortptr)->_ptr++) :			_flsbuf(*(unsigned char *)( sortptr)->_ptr,  sortptr)) :		_flsbuf((unsigned char)(*cp),  sortptr)));
	
		(--(sortptr)->_cnt >= 0 ?	(int)(*(unsigned char *)(sortptr)->_ptr++ = (' ')) :	(((sortptr)->_flag & 0200) && -(sortptr)->_cnt < (sortptr)->_bufsiz ?		((*(sortptr)->_ptr = (' ')) != '\n' ?			(int)(*(unsigned char *)(sortptr)->_ptr++) :			_flsbuf(*(unsigned char *)(sortptr)->_ptr, sortptr)) :		_flsbuf((unsigned char)(' '), sortptr)));
		(--(sortptr)->_cnt >= 0 ?	(int)(*(unsigned char *)(sortptr)->_ptr++ = (0177)) :	(((sortptr)->_flag & 0200) && -(sortptr)->_cnt < (sortptr)->_bufsiz ?		((*(sortptr)->_ptr = (0177)) != '\n' ?			(int)(*(unsigned char *)(sortptr)->_ptr++) :			_flsbuf(*(unsigned char *)(sortptr)->_ptr, sortptr)) :		_flsbuf((unsigned char)(0177), sortptr)));
	for (cp=line; cp<strt; cp++)
			(--(sortptr)->_cnt >= 0 ?	(int)(*(unsigned char *)(sortptr)->_ptr++ = (*cp)) :	(((sortptr)->_flag & 0200) && -(sortptr)->_cnt < (sortptr)->_bufsiz ?		((*(sortptr)->_ptr = (*cp)) != '\n' ?			(int)(*(unsigned char *)(sortptr)->_ptr++) :			_flsbuf(*(unsigned char *)(sortptr)->_ptr, sortptr)) :		_flsbuf((unsigned char)(*cp), sortptr)));
		(--(sortptr)->_cnt >= 0 ?	(int)(*(unsigned char *)(sortptr)->_ptr++ = ('\n')) :	(((sortptr)->_flag & 0200) && -(sortptr)->_cnt < (sortptr)->_bufsiz ?		((*(sortptr)->_ptr = ('\n')) != '\n' ?			(int)(*(unsigned char *)(sortptr)->_ptr++) :			_flsbuf(*(unsigned char *)(sortptr)->_ptr, sortptr)) :		_flsbuf((unsigned char)('\n'), sortptr)));
}
getsort()
{
	int c;
	char *tilde, *linep, *ref;
	char *p1a,*p1b,*p2a,*p2b,*p3a,*p3b,*p4a,*p4b;
	int w;
	char *rtrim(), *ltrim();
	if((sortptr = fopen(sortfile,"r")) == 0)
		diag("Cannot open sorted data:",sortfile);
	halflen = (llen-gutter)/2;
	linep = line;
	while((c = 		(--(sortptr)->_cnt>=0? (int)(*(unsigned char *)(sortptr)->_ptr++):_filbuf(sortptr))) != (-1)) {
		switch(c) {
		case 0177:
			tilde = linep;
			break;
		case '\n':
			while(	((_ctype_+1)[linep[-1]]&010))
				linep--;
			ref = tilde;
			if(rflag) {
				while(ref<linep&&!	((_ctype_+1)[*ref]&010))
					ref++;
				*ref++ = 0;
			}
		
			p3b = rtrim(p3a=line,tilde,halflen-1);
			if(p3b-p3a>halflen-1)
				p3b = p3a+halflen-1;
			p2a = ltrim(ref,p2b=linep,halflen-1);
			if(p2b-p2a>halflen-1)
				p2a = p2b-halflen-1;
			p1b = rtrim(p1a=p3b+(	((_ctype_+1)[p3b[0]]&010)!=0),tilde,
				w=halflen-(p2b-p2a)-gap);
			if(p1b-p1a>w)
				p1b = p1a;
			p4a = ltrim(ref,p4b=p2a-(	((_ctype_+1)[p2a[-1]]&010)!=0),
				w=halflen-(p3b-p3a)-gap);
			if(p4b-p4a>w)
				p4a = p4b;
			fprintf(outptr,".xx \"");
			putout(p1a,p1b);
	
			if(p1b!=(tilde-1) && p1a!=p1b)
				fprintf(outptr,"/");
			fprintf(outptr,"\" \"");
			if(p4a==p4b && p2a!=ref && p2a!=p2b)
				fprintf(outptr,"/");
			putout(p2a,p2b);
			fprintf(outptr,"\" \"");
			putout(p3a,p3b);
	
	
			if(p1a==p1b && ++p3b!=tilde)
				fprintf(outptr,"/");
			fprintf(outptr,"\" \"");
			if(p1a==p1b && p4a!=ref && p4a!=p4b)
				fprintf(outptr,"/");
			putout(p4a,p4b);
			if(rflag)
				fprintf(outptr,"\" %s\n",tilde);
			else
				fprintf(outptr,"\"\n");
			linep = line;
			break;
		case '"':
	
			*linep++ = c;
		default:
			*linep++ = c;
		}
	}
}
char *rtrim(a,c,d)
char *a,*c;
{
	char *b,*x;
	b = c;
	for(x=a+1; x<=c&&x-a<=d; x++)
		if((x==c||	((_ctype_+1)[x[0]]&010))&&!	((_ctype_+1)[x[-1]]&010))
			b = x;
	if(b<c&&!	((_ctype_+1)[b[0]]&010))
		b++;
	return(b);
}
char *ltrim(c,b,d)
char *c,*b;
{
	char *a,*x;
	a = c;
	for(x=b-1; x>=c&&b-x<=d; x--)
		if(!	((_ctype_+1)[x[0]]&010)&&(x==c||	((_ctype_+1)[x[-1]]&010)))
			a = x;
	if(a>c&&!	((_ctype_+1)[a[-1]]&010))
		a--;
	return(a);
}
putout(strt,end)
char *strt, *end;
{
	char *cp;
	cp = strt;
	for(cp=strt; cp<end; cp++) {
			(--(outptr)->_cnt >= 0 ?	(int)(*(unsigned char *)(outptr)->_ptr++ = (*cp)) :	(((outptr)->_flag & 0200) && -(outptr)->_cnt < (outptr)->_bufsiz ?		((*(outptr)->_ptr = (*cp)) != '\n' ?			(int)(*(unsigned char *)(outptr)->_ptr++) :			_flsbuf(*(unsigned char *)(outptr)->_ptr, outptr)) :		_flsbuf((unsigned char)(*cp), outptr)));
	}
}
onintr()
{
	if(*sortfile)
		unlink(sortfile);
	exit(1);
}
hash(strtp,endp)
char *strtp, *endp;
{
	char *cp, c;
	int i, j, k;
	
	if((endp - strtp) == 1)
		return(0);
	cp = strtp;
	c = *cp++;
	i = (	((_ctype_+1)[c]&01)?	((c)-'A'+'a'):c);
	c = *cp;
	j = (	((_ctype_+1)[c]&01)?	((c)-'A'+'a'):c);
	i = i*j;
	cp = --endp;
	c = *cp--;
	k = (	((_ctype_+1)[c]&01)?	((c)-'A'+'a'):c);
	c = *cp;
	j = (	((_ctype_+1)[c]&01)?	((c)-'A'+'a'):c);
	j = k*j;
	k = (i ^ (j>>2)) & 03777;
	return(k);
}
storeh(num,strtp)
int num;
char *strtp;
{
	int i;
	for(i=num; i<2048; i++) {
		if(hasht[i] == 0) {
			hasht[i] = strtp;
			return(0);
		}
	}
	for(i=0; i<num; i++) {
		if(hasht[i] == 0) {
			hasht[i] = strtp;
			return(0);
		}
	}
	return(1);
}
