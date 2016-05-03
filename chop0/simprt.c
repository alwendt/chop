/* You have this code because you wanted it now rather than correct.
   Bugs abound!  Contact Alan Wendt for a later version or to be
   placed on the chop mailing list.  Parts are missing due to licensing
   constraints.

   Alan Wendt / Computer Science / University of Arizona / Tucson AZ 85721
   602-621-4252.  arizona!wendt
*/
#include <ctype.h>
#include <stdio.h>
#include "c.h"
#include "hop2.h"
#include "md.h"

/*  Fold constants.
 *  Replace comparisons >, >=, and != with <, <=, and ==.
 *  Remove constant additions with 0 and multiplications and divisions with 1.
 *  Remove multiplications and divisions with 0.
 *  Rewrite convert - operate - unconvert sequences when possible.
 */

/*  an op is shortable if it can be computed at its result width	*/
/*  This happens when each bit in the result is only a function of	*/
/*  input bits at or to the right of the result bit.			*/
#define SHORTABLE(op) (!strcmp(op, "add") || !strcmp(op, "sub") || \
	    !strcmp(op, "mul") || !strcmp(op, "and") || \
	    !strcmp(op, "or") || !strcmp(op, "xor"))

#define WIDTH(s) ((!strcmp(s, "l")) ? 32 : \
		(!strcmp(s, "w")) ? 16 : \
		(!strcmp(s, "b")) ? 8 : 0)

#define MAXSIMPVARS	10

char v[MAXSIMPVARS][MAXRTS];			/* variables */

static void condadd(), simp2();
static simp1(), getval();
static char *negatecomparison();

static int eql(o, s1, s2)		/* are these two vars equal or	*/
    struct Optrec *o;			/* bound to the same value?	*/
    char *s1, *s2;
    {
    char	*h1, *h2;
    char	bf1[40], bf2[40];
    int	var1, var2;

    if (!s1 || !s2) return 0;

    if (!strcmp(s1, s2)) return 1;	/* equal */

    if (ISVAR(s1) && s1[VARLN] == 0) {
	var1 = VAR(s1);
	if (o->o_numbers & (1 << var1)) {
	    sprintf(bf1, "%d", ONUM(o, var1));
	    s1 = bf1;
	    }
	else {
	    h1 = OSTR(o, var1);
	    if (!h1) return 0;
	    s1 = h1;
	    }
	}

    if (ISVAR(s2) && s2[VARLN] == 0) {
	var2 = VAR(s2);
	if (o->o_numbers & (1 << var2)) {
	    sprintf(bf2, "%d", ONUM(o, var2));
	    s2 = bf2;
	    }
	else {
	    h2 = OSTR(o, var2);
	    if (!h2) return 0;
	    s2 = h2;
	    }
	}
    return !strcmp(s1, s2);		/* bound to same value	*/
    }

/*  Return 1 if this string denotes a variable name like "%02" or a string of
 *  digits like "42".  Return 0 if it's something more complex like
 *  "add(%01,%02,%03)".
 */
static isconstant(s)
    char *s;
    {
    if (ISVAR(s) && s[VARLN] == 0)
	return 1;
    for (; *s; s++)
	if (!isdigit(*s))
	    return 0;
    return 1;
    }

/*	match the rt, setting vars. return length of match	*/
static match(ins, pat)
char *ins, *pat;
    {
    register char *i, *p;
    register int varnum;
    register int lev;
    int bounded[MAXSIMPVARS];

    bzero(bounded,sizeof(bounded));

    for (i = ins; *i && *pat;) {
	if (ISVAR(pat)) {
		lev = 0;
		p = v[varnum = VAR(pat)];
		pat += VARLN;
		if (!bounded[varnum]) {
		    while (*i && (*i != *pat || lev > 0)) {
			    if (*i == '(')
				    lev++;
			    else if (*i == ')')
				    lev--;
			    *p++ = *i++;
			    }
		    }
		else {
		    while (*i && (*i != *pat || lev > 0)) {
			if (*i == '(')
			    lev++;
			else if (*i == ')')
			    lev--;
			if (*p++ != *i++) return 0;
			}
		    }
		*p = 0;
		bounded[varnum] = 1;
		}
	else if (*pat++ != *i++)
	    return 0;
	}
    return *pat == 0 ? i - ins : 0;
    }

/*	Simplify char string in place					*/
simp(rt, o)
    char		*rt;
    struct Optrec	*o;
    {
    int			result;
#if 0
    printf("simp '%s' =>\n", rt); 
#endif
    result = simp1(rt, o);
#if 0
    if (result) printf("'%s'\n\n", rt); 
    else printf("no change\n\n");
#endif
    return result;
    }

foldbinary(n, s, o, leftid, operator, rightid, zero)
    int		n;
    char	*s;
    struct Optrec *o;
    char	operator;
    char	*leftid;		/* left identity element */
    char	*rightid;		/* right identity element */
    char	*zero;			/* if anything op zero == zero */
					/* and zero op anything == zero */
    {
    int		globv;
    long	result;
    char	bf[MAXREQLEN];
    int		v0, v1;

    if (n > 0 && isconstant(v[0]) && isconstant(v[1])) {
	if ((globv = getvar(o, 1, __FILE__, __LINE__)) != NOVAR) {
	    char	bf0[MAXRTLINE], bf1[MAXRTLINE];
	    int	v0, v1;

	    bf[0] = '\\';
	    sprintf(bf + 1, VARFMT, globv);

	    if (!getval(o, v[0], bf0, &v0) || !getval(o, v[1], bf1, &v1))
		return 0;

	    switch (operator) {
		case '+':  result = v0 + v1; break;
		case '-':  result = v0 - v1; break;
		case '*':  result = v0 * v1; break;
		case '/':  result = v0 / v1; break;
		case 'm':  result = v0 << v1; break;
		case 'n':  result = v0 >> v1; break;
		case '%':  result = v0 % v1; break;
		case '&':  result = v0 & v1; break;
		case '^':  result = v0 ^ v1; break;
		case '|':  result = v0 | v1; break;
		default: cerror("foldbinary: can't happen\n");
		}
	    SETONUM(o, globv, result);
	    simp2(s, n, bf, v);

	    /*  if v[0] and v[1] are not variables, they must be
	     *  constant numbers.
	     */
	    if (!ISVAR(v[0]) && !ISVAR(v[1])) {
		condadd(o->o_reqs, globv, ".str==\"%d\"", result);
		}
	    else  {
		condadd(o->o_reqs, globv,
			".num==((%s)%c(%s))", bf0, operator, bf1);
		}
	    return 1;
	    }
	}

    /* identity elements (x + 0, x * 1, etc) */
    else if (n > 0 && eql(o, v[0], leftid)) {
	simp2(s, n, "%01", v);
	if (ISVAR(v[0])) {
	    v0 = VAR(v[0]);
	    if (o->o_numbers & (1 << v0))
		condadd(o->o_reqs, v0, ".num==%s", leftid);
	    else
		condadd(o->o_reqs, v0, ".str==\"%s\"", leftid);
	    }
	return 1;
	}

    else if (n > 0 && eql(o, v[1], rightid)) {
	simp2(s, n, "%00", v);
	if (ISVAR(v[1])) {
	    v1 = VAR(v[1]);
	    if (o->o_numbers & (1 << v1))
		condadd(o->o_reqs, v1, ".num==%s", rightid);
	    else
		condadd(o->o_reqs, v1, ".str==\"%s\"", rightid);
	    }
	return 1;
	}

    /*  0 * x => 0 */
    else if (n > 0 && eql(o, v[0], zero)) {
	simp2(s, n, zero, v);
	if (ISVAR(v[0])) {
	    v0 = VAR(v[0]);
	    if (o->o_numbers & (1 << v0))
		condadd(o->o_reqs, v0, ".num==%s", zero);
	    else
		condadd(o->o_reqs, v0, ".str==\"%s\"", zero);
	    }
	}

    /* x * 0 => 0 */
    else if (n > 0 && eql(o, v[1], zero)) {
	simp2(s, n, zero, v);
	if (ISVAR(v[1])) {
	    v1 = VAR(v[1]);
	    if (o->o_numbers & (1 << v1))
		condadd(o->o_reqs, v1, ".num==%s", zero);
	    else
		condadd(o->o_reqs, v1, ".str==\"%s\"", zero);
	    }
	}

    return 0;
    }

static simp1(rt, o)
    char		*rt;
    struct Optrec	*o;
    {
    register char	*s = rt - 1;
    char		bf[MAXREQLEN];
    int			n, globv;

    for (;;) {
	switch (*++s)
	    {
	    case 0: return 0;

	    case 'a':

	    n = match(s, "and(%00,%01,%02)");
	    if (foldbinary(n, s, o, "-1", '&', "-1", "0"))
		return 1;

	    n = match(s, "add(%00,%01,%02)");

	    if (foldbinary(n, s, o, "0", '+', "0", NULL)) return 1;

	    n = match(s, "add(add(%00,%01,%02),%03,%04)");
	    if (n > 0 && (!isconstant(v[0])) && isconstant(v[3])) {
		simp2(s, n, "add(add(%01,%03,%04),%00,%02)", v);
		return 1;
		}
	    else if (n > 0 && (!isconstant(v[1])) && isconstant(v[3])) {
		simp2(s, n, "add(add(%00,%03,%04),%01,%02)", v);
		return 1;
		}

	    n = match(s, "add(%03,add(%00,%01,%02),%04)");
	    if (n > 0 && (!isconstant(v[0]))) {
		simp2(s, n, "add(add(%01,%03,%04),%00,%02)", v);
		return 1;
		}
	    else if (n > 0 && (!isconstant(v[1]))) {
		simp2(s, n, "add(add(%00,%03,%04),%01,%02)", v);
		return 1;
		}

	    n = match(s, "add(mul(add(%00,%01,%02),%03,%04),%05,%06)");
	    if (n > 0 && isconstant(v[1]) && isconstant(v[3])) {
		simp2(s, n,
		  "add(mul(%00,%03,%04),add(mul(%01,%03,%04),%05,%06),%02)",v);
		return 1;
		}

	    /* change to canonical */
	    /* what do we define as canonical???*/
	    /* longest operand first???      	*/
	    /* most nested first???		*/
	    /* alphabetical??? (currently used)	*/
	    /* how much difference does it make */
	    /* in space and in simplification   */
	    /* rules????  Need to check and     */
	    /* find out.			*/

	    n = match(s, "add(%00,add(%01,%02,%03),%04)");
	    if (n > 0
		&& strncmp(v[0],"add(",4)
		    ) {
		simp2(s, n, "add(add(%01,%02,%03),%00,%04)", v);
		return 1;
		}

	    n = match(s, "add(%00,ash(%01,%02,%03),%04)");
	    if (n > 0
		&& strncmp(v[0],"add(",4)
		&& strncmp(v[0],"ash(",4)
		    ) {
		simp2(s, n, "add(ash(%01,%02,%03),%00,%04)", v);
		return 1;
		}

	    n = match(s, "add(%00,cvt(%01,%02,%03),%04)");
	    if (n > 0
		&& strncmp(v[0],"add(",4)
		&& strncmp(v[0],"ash(",4)
		&& strncmp(v[0],"cvt(",4)
		    ) {
		simp2(s, n, "add(cvt(%01,%02,%03),%00,%04)", v);
		return 1;
		}

	    n = match(s, "add(%00,div(%01,%02,%03),%04)");
	    if (n > 0
		&& strncmp(v[0],"add(",4)
		&& strncmp(v[0],"ash(",4)
		&& strncmp(v[0],"cvt(",4)
		&& strncmp(v[0],"div(",4)
		    ) {
		simp2(s, n, "add(div(%01,%02,%03),%00,%04)", v);
		return 1;
		}

	    n = match(s, "add(%00,m(%01,%02,%03),%04)");
	    if (n > 0
		&& strncmp(v[0],"add(",4)
		&& strncmp(v[0],"ash(",4)
		&& strncmp(v[0],"cvt(",4)
		&& strncmp(v[0],"div(",4)
		&& strncmp(v[0],"m(",2)
		    ) {
		simp2(s, n, "add(m(%01,%02,%03),%00,%04)", v);
		return 1;
		}

	    n = match(s, "add(%00,mul(%01,%02,%03),%04)");
	    if (n > 0
		&& strncmp(v[0],"add(",4)
		&& strncmp(v[0],"ash(",4)
		&& strncmp(v[0],"cvt(",4)
		&& strncmp(v[0],"div(",4)
		&& strncmp(v[0],"m(",2)
		&& strncmp(v[0],"mul(",4)
		    ) {
		simp2(s, n, "add(mul(%01,%02,%03),%00,%04)", v);
		return 1;
		}

	    n = match(s, "add(%00,sub(%01,%02,%03),%04)");
	    if (n > 0
		&& strncmp(v[0],"add(",4)
		&& strncmp(v[0],"ash(",4)
		&& strncmp(v[0],"cvt(",4)
		&& strncmp(v[0],"div(",4)
		&& strncmp(v[0],"m(",2)
		&& strncmp(v[0],"mul(",4)
		&& strncmp(v[0],"sub(",4)
		    ) {
		simp2(s, n, "add(sub(%01,%02,%03),%00,%04)", v);
		return 1;
		}
    
	    /*  The "\\" prevents interpretation of %globv as a simplification
	     *  variable.  There are two kinds of %dd vars involved in simp.c
	     *  Replace x << c => x * (1 << c).
	     */
	    n = match(s, "ash(%00,%01,l)");
	    if (n > 0 && isconstant(v[1])) {
		if ((globv = getvar(o, 1, __FILE__, __LINE__)) != NOVAR) {
		    char	bf1[MAXRTLINE];
		    int		v1;

		    if (!getval(o, v[1], bf1, &v1))
			return 0;

		    if (v1 >= 0) {
			sprintf(bf, "mul(%%00,\\");
			sprintf(endof(bf), VARFMT, globv);
			sprintf(endof(bf), ",l)");
			SETONUM(o, globv, 1 << v1);
			simp2(s, n, bf, v);
			bf[0] = 0;
			condadd(bf, globv, ".num==((1)<<(%s))", bf1);
			SAFESTRCAT(o->o_reqs, bf);
			condadd(bf, globv, ".num>=0");
			SAFESTRCAT(o->o_reqs, bf);
			return 1;
			}
		    }
		}

	    /* (x << y) << z ==? x << (y+z) */
	    n = match(s, "ash(ash(%00,%01,l),%02,l)");
	    if (n > 0) {
		simp2(s, n, "ash(%00,add(%01,%02,l),l)", v);
		return 1;
		}
	    break;


	    /*	fix compares of converted bytes and words */
	    case 'c':

	    n = match(s, "code(cvt(%01,%02,l),cvt(%03,%02,l),l)");
	    if (n > 0 &&
		(!strcmp(v[2],"b") || !strcmp(v[2],"w"))) {
		simp2(s, n, "code(%01,%03,%02)", v);
		return 1;
		}

	    n = match(s, "code(cvt(%01,%03,l),%02,l)");
	    if (n > 0 && isconstant(v[2]) &&
		(!strcmp(v[3],"b") || !strcmp(v[3],"w"))) {
		char	bf0[MAXRTLINE];
		int	v0;
		int	maxsz;
	    
		maxsz = v[3][0] == 'b' ? 128 : 32768;

		if (!getval(o, v[2], bf0, &v0))
		    return 0;

		if (-maxsz <= v0 && v0 < maxsz) {	/* replace	*/
		    simp2(s, n, "code(%01,%02,%03)", v);

		    /* constraint */
		    sprintf(endof(o->o_reqs), ";;%s>=%d;;%s<=%d",
			bf0, -maxsz,
			bf0, maxsz - 1);
		    return 1;
		    }
		}

#ifdef BYTES_BIG_ENDIAN
	    /* These sizeof(int)s will screw us up on retargets ??? */
	    /* "cvt(m(add(%00,%01,l),4),l,b)" => "m(add(%00,%02,l),1)" */
	    /* %02 = %01 + 3 */
	    n = match(s, "cvt(m(add(%00,%01,l),4),l,b)");
	    if (n > 0 && isconstant(v[1])) {
		if ((globv = getvar(o, 1, __FILE__, __LINE__)) != NOVAR) {
		    char	bf1[MAXRTLINE];
		    int	v1;
		    sprintf(bf, "m(add(%%00,\\");
		    sprintf(endof(bf), VARFMT, globv);
		    sprintf(endof(bf), ",l),1)");

		    if (!getval(o, v[1], bf1, &v1))
			return 0;

		    SETONUM(o, globv, (v1 + (long)sizeof(int)-1));
		    simp2(s, n, bf, v);
		    condadd(o->o_reqs, globv,
		       ".num==(((%s)+(int)sizeof(int))-(1))", bf1);
		    return 1;
		    }
		}
#endif
	    break;

	    case 'd':
	    n = match(s, "div(%00,%01,%02)");

	    if (foldbinary(n, s, o, NULL, '/', "1", NULL)) return 1;
	    break;

	    case 'i':
	    n = match(s, "idiv(%01,%02,%03)");
	    if (n > 0 && eql(o, v[2], "1")) {
		simp2(s, n, "%01", v);
		if (ISVAR(v[2])) {
		    condadd(o->o_reqs, VAR(v[2]), ".str==\"1\"");
		    }
		return 1;
		}
	    break;


	    case 'm':
	    n = match(s, "move(%00(%04,cvt(%01,%02,%03),%03),%05,%02)");
	    if (n > 0 && (SHORTABLE(v[0])) && WIDTH(v[2]) < WIDTH(v[3])) {
		/*	printf("reqs => %s\n", reqs);	*/
		simp2(s, n, "move(%00(%04,%01,%02),%05,%02)", v);
		/*	printf("   => %s\n", reqs);	*/
		return 1;
		}

	    n = match(s, "move(%00(cvt(%01,%05,%03),%02,%03),%04,%05)");
	    if (n > 0 && SHORTABLE(v[0]) && WIDTH(v[5]) < WIDTH(v[3])) {
		/*	printf("reqs => %s\n", reqs);	*/
		simp2(s, n, "move(%00(%01,%02,%05),%04,%05)", v);
		/*	printf("   => %s\n", reqs);	*/
		return 1;
		}

	    n = match(s, "move(%00(%01,%02,%03),%04,%05)");
	    if (n > 0 && SHORTABLE(v[0]) && WIDTH(v[5]) < WIDTH(v[3])) {
		/*	printf("reqs => %s\n", reqs);	*/
		simp2(s, n, "move(%00(%01,%02,%05),%04,%05)", v);
		/*	printf("   => %s\n", reqs);	*/
		return 1;
		}

	    n = match(s, "move(add(%01,cvt(%02,b,l),l),m(%03,1),b)");
	    if (n > 0) {
		simp2(s, n, "move(add(%01,%02,b),m(%03,1),b)", v);
		return 1;
		}

	    n = match(s, "mul(sub(0,%01,l),%02,l)");
	    if (n > 0) {
		simp2(s, n, "sub(0,mul(%01,%02,l),l)", v);
		return 1;
		}

	    n = match(s, "m(addr(%01,l),%02,%03)");
	    if (n > 0) {
		simp2(s, n, "%01", v);
		return 1;
		}

	    n = match(s, "mul(40,%01,%02)");
	    if (n > 0) {
		simp2(s, n, "add(mul(%01,32,%02),mul(%01,8,%02),%02)", v);
		return 1;
		}

	    n = match(s, "mul(%00,%01,%02)");

	    /* fold the multiplication of constants */
	    if (foldbinary(n, s, o, "1", '*', "1", "0")) return 1;

	    else if (n > 0 && isconstant(v[0])) {

		if ((globv = getvar(o, 1, __FILE__, __LINE__)) != NOVAR) {
		    char	bf0[MAXRTLINE];
		    int	v0;

		    if (!getval(o, v[0], bf0, &v0))
			return 0;

		    if ((v0 & -v0) == v0) {
			sprintf(bf, "ash(%%01,\\");
			sprintf(endof(bf), VARFMT, globv);
			sprintf(endof(bf), ",l)", globv);
			SETONUM(o, globv, (long) lowbit(v0));
			simp2(s, n, bf, v);
			sprintf(endof(o->o_reqs), ";;((%s)&-(%s))==(%s)",
				bf0, bf0, bf0);
			condadd(o->o_reqs, globv, ".num==lowbit(%s)", bf0);
			return 1;
			}
		    }
		}

	    case 'n':
	    n = match(s, "not(if(code(%00,%01,%02),%03,%04,b),b)");
	    if (n > 0 && negatecomparison(v[3])) {
		sprintf(bf, "if(code(%%00,%%01,%%02),%s,%%04,b)",
			negatecomparison(v[3]));
		simp2(s, n, bf, v);
		return 1;
		}

	    /*
	    This breaks code generation for BANDU on the Vax.
	    n = match(s, "not(not(%01,%02),%02)");
	    if (n > 0) {
		sprintf(bf, "%%01");
		simp2(s, n, bf, v);
		return 1;
		}
	    */

	    n = match(s, "not(%00,%01)");
	    if (n > 0 && isconstant(v[0])) {
		if ((globv = getvar(o, 1, __FILE__, __LINE__)) != NOVAR) {
		    char	bf0[MAXRTLINE];
		    int	v0;

		    SAFESTRCPY(bf, "\\");
		    sprintf(endof(bf), VARFMT, globv);

		    if (!getval(o, v[0], bf0, &v0))
			return 0;

		    SETONUM(o, globv, (long) ~v0);
		    simp2(s, n, bf, v);
		    condadd(o->o_reqs, globv, ".num==~(%s)", bf0);
		    return 1;
		    }
		}
	    break;

	    case 's':
	    n = match(s, "sub(%00,%01,%02)");
	    if (foldbinary(n, s, o, NULL, '-', "0", NULL)) return 1;
	    break;

	    /*	881208	*/
	    case 'u':
	    n = match(s, "udiv(%01,%02,%03)");
	    if (n > 0 && eql(o, v[2], "1")) {
		simp2(s, n, "%01", v);
		if (ISVAR(v[2]))
		    condadd(o->o_reqs, VAR(v[2]), ".str==\"1\"");
		return 1;
		}

	    else if (n > 0 && isconstant(v[2])) {

		if ((globv = getvar(o, 1, __FILE__, __LINE__)) != NOVAR) {
		    char	bf0[MAXRTLINE];
		    int	v0;

		    if (!getval(o, v[2], bf0, &v0))
			return 0;

		    if ((v0 & -v0) == v0) {
			sprintf(bf, "ush(sub(0,\\");
			sprintf(endof(bf), VARFMT, globv);
			sprintf(endof(bf), ",l),%%01,l)", globv);
			SETONUM(o, globv, lowbit(v0));
			simp2(s, n, bf, v);
			sprintf(endof(o->o_reqs), ";;((%s)&-(%s))==(%s)", bf0);
			condadd(o->o_reqs, globv, ".num==lowbit(%s)", bf0);
			return 1;
			}
		    }
		}
	    break;
	    }
	}
    }

/*  add a condition of the form ";;%02.str==<something>" to the end
 *  of this reqs */
/* VARARGS */
static void condadd(reqs, globv, format, val1, val2, val3)
    char	*reqs, *format;
    char	*val1, *val2, *val3;
    int		globv;
    {
    if (globv < 0 || MAXGLOBALS+MAXFREENONTERMS <= globv) {
	cerror("condadd: bad variable %d\n", globv);
	}
    strcat(reqs, ";;");
    sprintf(endof(reqs), VARFMT, globv);
    /* SUPPRESS 126 */
    sprintf(endof(reqs), format, val1, val2, val3);
    }

/*  get the current numeric value and the C program string to get the	*/
/*  value of this matched variable.  The C program string references	*/
/*  the var at runtime if the var is not a constant built into the	*/
/*  pattern, or bound.							*/
static getval(o, var, ctext, resultp)	/* get numeric and C string	*/
    struct Optrec *o;
    char *var;			/* pointer to var	*/
    char *ctext;		/* returned ctext buffer	*/
    long	*resultp;
    {
    char	*s, tmp[MAXRTLINE];

    if (ISVAR(var)) {
	if (s = bound(o->o_reqs, var, tmp))
	    unquote(s, ctext);
	else {
	    sprintf(ctext, VARFMT, VAR(var));
	    strcat(ctext, ".num");
	    if (o->o_numbers & (1 << VAR(var))) {
		*resultp = ONUM(o, VAR(var));
		return 1;
		}
	    }

	*resultp = strtol(OSTR(o, VAR(var)), &s, 10);
	return !*s;
	}

    strcpy(ctext, var);
    *resultp = strtol(var, &s, 10);
    return !*s;
    }
 
/*	construct the simplified version			*/
static void simp2(old, nmatch, new, vars)
    char *new, *old, vars[][MAXRTS];
    {
    char buf[MAXRTS], *p, *q, *s, *sav;

    sav = old;
    for (s = buf; *s = *old; old++, s++)
	if (strncmp(old, sav, nmatch) == 0) {
	    for (p = new; *s = *p; s++, p++) {
		if (*p == '\\') *s = *++p;
		else if (ISVAR(p)) {
		    if ((q = vars[VAR(p)]) == NULL)
			cerror("simp2 dies '%s'", old);
		    strcpy(s, q);
		    p += VARLN - 1;
		    s += strlen(q)-1;
		    }
		}
	    old += nmatch-1;
	    s--;
	    }
    strcpy(sav, buf);
    }

/*  Replace undesirable comparison operators with preferred ones.
 *  not(undesireable) => desireable
 */
static char *negatecomparison(s)
    char	*s;
    {
    if (!strcmp(s, "ne")) return "eq";
    if (!strcmp(s, "gt")) return "le";
    if (!strcmp(s, "ge")) return "lt";
    return NULL;
    }

/*  Replace undesirable comparison operators with preferred ones.
 *  not(x undesireable y) => y desireable x
 */
static char *reversecomparison(s)
    char	*s;
    {
    if (!strcmp(s, "gt")) return "lt";
    if (!strcmp(s, "ge")) return "le";
    return NULL;
    }


#if 0

main()
    {
    char bf[2000];

    while (gets(bf)) {
	simp(bf);
	printf("%s\n", bf);
	}
    }

imm32 => or(ash(bitfld(imm32,16,16),16,l),and(imm32,65535,l),l)

#endif

