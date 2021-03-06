/* You have this code because you wanted it now rather than correct.
   Bugs abound!  Contact Alan Wendt for a later version or to be
   placed on the chop mailing list.  Parts are missing due to licensing
   constraints.

   Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
   303-491-7323.  wendt@cs.colostate.edu
*/

/* hash.c */

#include <ctype.h>
#include <stdio.h>
#include "c.h"
#include "hop2.h"

char *unquote(from, to)			/* remove quotes from string	*/
    char *from, *to;
    {
    char	*ofrom = from;
    if (*from++ != '"')
	cerror("bad unquote call '%s'", from);

    for (;;) {
	if (from - ofrom > 1000)
	    cerror("string too long");

	if (*from == '"') {
	    *to = 0;
	    return from + 1;
	    }

	else if (*from == '\\') {
	    switch (*from) {
		case 'n':   *to++ = '\n'; break;
		case 't':   *to++ = '\t'; break;
		case 'r':   *to++ = '\r'; break;
		case 'f':   *to++ = '\f'; break;
		case 'b':   *to++ = '\b'; break;
		default:    *to++ = *from;
		}
	    from += 2;
	    }

	else *to++ = *from++;
	}
    }

char *quote(from, to)			/* quote a string		*/
    char *from, *to;
    {
    char	*origto = to;
    *to++ = '"';			/* leading quote		*/
    for (;;) {
	switch (*from) {
	    case 0:	*to++ = '"';	/* trailing quote		*/
			*to++ = 0;
			return origto;

	    case '\n':	*to++ = '\\';
			*to++ = 'n';
			break;

	    case '\t':	*to++ = '\\';
			*to++ = 't';
			break;

	    case '\r':	*to++ = '\\';
			*to++ = 'r';
			break;

	    case '\f':	*to++ = '\\';
			*to++ = 'f';
			break;

	    case '\b':	*to++ = '\\';
			*to++ = 'b';
			break;

	    case '\"':
	    case '\'':
	    case '\\':	*to++ = '\\';		/* fall through */
		
	    default:	*to++ = *from;
	    }
	from++;
	}
    }



#define MAXBUF 8192

char *calloc();
#define align (sizeof(struct { char a ; double b; }) - sizeof(struct { double b; }))

char *balloc(n) unsigned n; {
    static int bsize = 0;
    static char *bp;
    char *p;

    n += align - 1;
    n &= ~(align - 1);

    if (n > bsize) {
        bsize = MAXBUF;
        if (n > bsize) bsize = n;
        bp = calloc((unsigned)1, (unsigned)bsize);
        if (bp == 0) cerror("no memory for balloc.\n");
        }

    p = bp;
    bsize -= n;
    bp += n;
    return p;
    }

char *bmalloc(n) unsigned n; {
    static int bsize = 0;
    static char *bp;
    char *p;
    extern char *malloc();

    n += align - 1;
    n &= ~(align - 1);

    if (n > bsize) {
        bsize = MAXBUF;
        if (n > bsize) bsize = n;
        bp = malloc((unsigned)bsize);
        if (bp == 0)
		cerror("no memory for bmalloc\n");
        }

    p = bp;
    bsize -= n;
    bp += n;
#if SABER
    saber_untype(p, n);
#endif
    return p;
    }

#if OWNFUNCTIONS
/* avoid confusing saber-C */

/*	calloc - allocate and clear memory block */
#define CHARPERINT (sizeof(int)/sizeof(char))
#define NULL 0

char *calloc(num, size)
unsigned num, size;
{
	register char *mp;
	register int *q, *qlim, m;

	num *= size;
	mp = malloc(num);
	if(mp == NULL)
	    cerror("no memory for calloc\n");
	q = (int *) mp;
	qlim = (m = (num+CHARPERINT-1)/CHARPERINT) + (q = (int *)mp);

	/*  this code is hard to understand */
	switch (m & 7)
	    /* SUPPRESS 256 */
	    do	{
			*q++ = 0;
		case 7: *q++ = 0;
		case 6: *q++ = 0;
		case 5: *q++ = 0;
		case 4: *q++ = 0;
		case 3: *q++ = 0;
		case 2: *q++ = 0;
		case 1: *q++ = 0;
		case 0: ;
		} while (q < qlim);

	return(mp);
}
#endif

/*  Count bits in a word */
bitcount(m)
    register unsign32 m;
    {
    register int t = 0;
    while (m) {
	t += "\0\1\1\2\1\2\2\3\1\2\2\3\2\3\3\4"[m & 15];
	m >>= 4;
	}
    return t;
    }

#ifndef V9
#include <errno.h>
#ifndef errno
extern int errno;
#endif

/* strtol - interpret str as a base b number; if ptr!=0, *ptr gets updated str */
long strtol(const char *str, char **ptr,int b) {
	long n = 0;
	char *s, sign = '+';
	int d, overflow = 0;

	if (ptr)
		*ptr = str;
	if (b < 0 || b == 1 || b > 36)
		return 0;
	while (*str==' '||*str=='\f'||*str=='\n'||*str=='\r'||*str=='\t'||*str=='\v')
		str++;
	if (*str == '-' || *str == '+')
		sign = *str++;
	if (b == 0)
		if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X')) {
			b = 16;
			str += 2;
		} else if (str[0] == '0')
			b = 8;
		else
			b = 10;
	for (s = str; *str; str++) {
		if (*str >= '0' && *str <= '9')
			d = *str - '0';
		else if (*str >= 'a' && *str <= 'z' || *str >= 'A' && *str <= 'Z')
			d = (*str&~040) - 'A' + 10;
		else
			break;
		if (d >= b)
			break;
		if (n < (LONG_MIN + d)/b)
			overflow = 1;
		n = b*n - d;
	}
	if (s == str)
		return 0;
	if (ptr)
		*ptr = str;
	if (overflow || (sign == '+' && n == LONG_MIN)) {
		errno = ERANGE;
		return sign == '+' ? LONG_MAX : LONG_MIN;
	}
	return sign == '+' ? -n : n;
}
#endif

#if 1
memmove(destination, source, length)
    register char *destination;
    register char *source;
    unsigned length;
{
    register char *p, *q;

#if SABER
    char	*odst = destination;
#endif

    if (length != 0 && source != destination)
    {
	p = destination + length;
	if ((int)destination < (int)source)
	    do  {
		(*destination++) = (*source++);
	    } while (destination != p);
	else {
	    q = source + length;
	    do  {
		(*--p) = (*--q);
	    } while (p != destination);
	}
#if SABER
    saber_untype(odst, length);
#endif
    }
    return length;
}
#endif


#if 0
memcpy(destination, source, length)
    register char *destination;
    register char *source;
    unsigned length;
{
	/* overlapping source and destination? */
	if(abs((int)source - (int)destination)<length)
	{
		cerror("bad memcpy!!\n");
	}
	bcopy(source,destination,(int)length);
}
#endif

