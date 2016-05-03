static char sccsid[] = "@(#)grep.c	4.6 (Berkeley) 5/14/84";
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
char	expbuf[256];
long	lnum;
char	linebuf[1024+1];
char	ybuf[256];
int	bflag;
int	lflag;
int	nflag;
int	cflag;
int	vflag;
int	nfile;
int	hflag	= 1;
int	sflag;
int	yflag;
int	wflag;
int	retcode = 0;
int	circf;
int	blkno;
long	tln;
int	nsucc;
char	*braslist[9];
char	*braelist[9];
char	bittab[] = {
	1,
	2,
	4,
	8,
	16,
	32,
	64,
	128
};
main(argc, argv)
char **argv;
{
	while (--argc > 0 && (++argv)[0][0]=='-')
		switch (argv[0][1]) {
		case 'i':
		case 'y':
			yflag++;
			continue;
		case 'w':
			wflag++;
			continue;
		case 'h':
			hflag = 0;
			continue;
		case 's':
			sflag++;
			continue;
		case 'v':
			vflag++;
			continue;
		case 'b':
			bflag++;
			continue;
		case 'l':
			lflag++;
			continue;
		case 'c':
			cflag++;
			continue;
		case 'n':
			nflag++;
			continue;
		case 'e':
			--argc;
			++argv;
			goto out;
		default:
			errexit("grep: unknown flag\n", (char *)0);
			continue;
		}
out:
	if (argc<=0)
		exit(2);
	if (yflag) {
		char *p, *s;
		for (s = ybuf, p = *argv; *p; ) {
			if (*p == '\\') {
				*s++ = *p++;
				if (*p)
					*s++ = *p++;
			} else if (*p == '[') {
				while (*p != '\0' && *p != ']')
					*s++ = *p++;
			} else if (	((_ctype_+1)[*p]&02)) {
				*s++ = '[';
				*s++ = 	((*p)-'a'+'A');
				*s++ = *p++;
				*s++ = ']';
			} else
				*s++ = *p++;
			if (s >= ybuf+256-5)
				errexit("grep: argument too long\n", (char *)0);
		}
		*s = '\0';
		*argv = ybuf;
	}
	compile(*argv);
	nfile = --argc;
	if (argc<=0) {
		if (lflag)
			exit(1);
		execute((char *)0);
	} else while (--argc >= 0) {
		argv++;
		execute(*argv);
	}
	exit(retcode != 0 ? retcode : nsucc == 0);
}
compile(astr)
char *astr;
{
	int c;
	char *ep, *sp;
	char *cstart;
	char *lastep;
	int cclcnt;
	char bracket[9], *bracketp;
	int closed;
	char numbra;
	char neg;
	ep = expbuf;
	sp = astr;
	lastep = 0;
	bracketp = bracket;
	closed = numbra = 0;
	if (*sp == '^') {
		circf++;
		sp++;
	}
	if (wflag)
		*ep++ = 14;
	for (;;) {
		if (ep >= &expbuf[256])
			goto cerror;
		if ((c = *sp++) != '*')
			lastep = ep;
		switch (c) {
		case '\0':
			if (wflag)
				*ep++ = 15;
			*ep++ = 11;
			return;
		case '.':
			*ep++ = 4;
			continue;
		case '*':
			if (lastep==0 || *lastep==1 || *lastep==12 ||
			    *lastep == 14 || *lastep == 15)
				goto defchar;
			*lastep |= 01;
			continue;
		case '$':
			if (*sp != '\0')
				goto defchar;
			*ep++ = 10;
			continue;
		case '[':
			if(&ep[17] >= &expbuf[256])
				goto cerror;
			*ep++ = 6;
			neg = 0;
			if((c = *sp++) == '^') {
				neg = 1;
				c = *sp++;
			}
			cstart = sp;
			do {
				if (c=='\0')
					goto cerror;
				if (c=='-' && sp>cstart && *sp!=']') {
					for (c = sp[-2]; c<*sp; c++)
						ep[c>>3] |= bittab[c&07];
					sp++;
				}
				ep[c>>3] |= bittab[c&07];
			} while((c = *sp++) != ']');
			if(neg) {
				for(cclcnt = 0; cclcnt < 16; cclcnt++)
					ep[cclcnt] ^= -1;
				ep[0] &= 0376;
			}
			ep += 16;
			continue;
		case '\\':
			if((c = *sp++) == 0)
				goto cerror;
			if(c == '<') {
				*ep++ = 14;
				continue;
			}
			if(c == '>') {
				*ep++ = 15;
				continue;
			}
			if(c == '(') {
				if(numbra >= 9) {
					goto cerror;
				}
				*bracketp++ = numbra;
				*ep++ = 1;
				*ep++ = numbra++;
				continue;
			}
			if(c == ')') {
				if(bracketp <= bracket) {
					goto cerror;
				}
				*ep++ = 12;
				*ep++ = *--bracketp;
				closed++;
				continue;
			}
			if(c >= '1' && c <= '9') {
				if((c -= '1') >= closed)
					goto cerror;
				*ep++ = 18;
				*ep++ = c;
				continue;
			}
		defchar:
		default:
			*ep++ = 2;
			*ep++ = c;
		}
	}
    cerror:
	errexit("grep: RE error\n", (char *)0);
}
execute(file)
char *file;
{
	char *p1, *p2;
	int c;
	if (file) {
		if (freopen(file, "r", (&_iob[0])) == 0) {
			perror(file);
			retcode = 2;
		}
	}
	lnum = 0;
	tln = 0;
	for (;;) {
		lnum++;
		p1 = linebuf;
		while ((c = 			(--((&_iob[0]))->_cnt>=0? (int)(*(unsigned char *)((&_iob[0]))->_ptr++):_filbuf((&_iob[0])))) != '\n') {
			if (c == (-1)) {
				if (cflag) {
					if (nfile>1)
						printf("%s:", file);
					printf("%D\n", tln);
					fflush((&_iob[1]));
				}
				return;
			}
			*p1++ = c;
			if (p1 >= &linebuf[1024-1])
				break;
		}
		*p1++ = '\0';
		p1 = linebuf;
		p2 = expbuf;
		if (circf) {
			if (advance(p1, p2))
				goto found;
			goto nfound;
		}
		
		if (*p2==2) {
			c = p2[1];
			do {
				if (*p1!=c)
					continue;
				if (advance(p1, p2))
					goto found;
			} while (*p1++);
			goto nfound;
		}
		
		do {
			if (advance(p1, p2))
				goto found;
		} while (*p1++);
	nfound:
		if (vflag)
			succeed(file);
		continue;
	found:
		if (vflag==0)
			succeed(file);
	}
}
advance(lp, ep)
char *lp, *ep;
{
	char *curlp;
	char c;
	char *bbeg;
	int ct;
	for (;;) switch (*ep++) {
	case 2:
		if (*ep++ == *lp++)
			continue;
		return(0);
	case 4:
		if (*lp++)
			continue;
		return(0);
	case 10:
		if (*lp==0)
			continue;
		return(0);
	case 11:
		return(1);
	case 6:
		c = *lp++ & 0177;
		if(ep[c>>3] & bittab[c & 07]) {
			ep += 16;
			continue;
		}
		return(0);
	case 1:
		braslist[*ep++] = lp;
		continue;
	case 12:
		braelist[*ep++] = lp;
		continue;
	case 18:
		bbeg = braslist[*ep];
		if (braelist[*ep]==0)
			return(0);
		ct = braelist[*ep++] - bbeg;
		if(ecmp(bbeg, lp, ct)) {
			lp += ct;
			continue;
		}
		return(0);
	case 18|01:
		bbeg = braslist[*ep];
		if (braelist[*ep]==0)
			return(0);
		ct = braelist[*ep++] - bbeg;
		curlp = lp;
		while(ecmp(bbeg, lp, ct))
			lp += ct;
		while(lp >= curlp) {
			if(advance(lp, ep))	return(1);
			lp -= ct;
		}
		return(0);
	case 4|01:
		curlp = lp;
		while (*lp++);
		goto star;
	case 2|01:
		curlp = lp;
		while (*lp++ == *ep);
		ep++;
		goto star;
	case 6|01:
		curlp = lp;
		do {
			c = *lp++ & 0177;
		} while(ep[c>>3] & bittab[c & 07]);
		ep += 16;
		goto star;
	star:
		if(--lp == curlp) {
			continue;
		}
		if(*ep == 2) {
			c = ep[1];
			do {
				if(*lp != c)
					continue;
				if(advance(lp, ep))
					return(1);
			} while(lp-- > curlp);
			return(0);
		}
		do {
			if (advance(lp, ep))
				return(1);
		} while (lp-- > curlp);
		return(0);
	case 14:
		if (lp == expbuf)
			continue;
		if (	(	((_ctype_+1)[*lp]&(01|02)) || (*lp) == '_') || 	((_ctype_+1)[*lp]&04))
			if (!	(	((_ctype_+1)[lp[-1]]&(01|02)) || (lp[-1]) == '_') && !	((_ctype_+1)[lp[-1]]&04))
				continue;
		return (0);
	case 15:
		if (!	(	((_ctype_+1)[*lp]&(01|02)) || (*lp) == '_') && !	((_ctype_+1)[*lp]&04))
			continue;
		return (0);
	default:
		errexit("grep RE botch\n", (char *)0);
	}
}
succeed(f)
char *f;
{
	nsucc = 1;
	if (sflag)
		return;
	if (cflag) {
		tln++;
		return;
	}
	if (lflag) {
		printf("%s\n", f);
		fflush((&_iob[1]));
		fseek((&_iob[0]), 0l, 2);
		return;
	}
	if (nfile > 1 && hflag)
		printf("%s:", f);
	if (bflag)
		printf("%u:", blkno);
	if (nflag)
		printf("%ld:", lnum);
	printf("%s\n", linebuf);
	fflush((&_iob[1]));
}
ecmp(a, b, count)
char	*a, *b;
{
	int cc = count;
	while(cc--)
		if(*a++ != *b++)	return(0);
	return(1);
}
errexit(s, f)
char *s, *f;
{
	fprintf((&_iob[2]), s, f);
	exit(2);
}
