/*  32k dependent compiler code	*/

#include <stdio.h>
#include "c.h"
#include "hop2.h"

/*  legal allocable register names	*/
/*  the variables MUST be %00 because factor() expects them to be */
struct Regpatts regpatts[] = {
/*  rt                         many  bit volat width  stride, typename */
    {"r(%00,4)",                  8,  0,    0,     1,     1,	"l"},
    {"f(%00,4)",                  8,  8,    0,     1,     1,	"f"},
    {"f(%00,8)",                  4,  8,    0,     2,     2,	"d"},
    {"cc(%00)",                   1, 16,    1,     1,     1,	"b"},
    {"mm(add(%00,fp,l),l,4)",    15, 17,    0,     1,     1,	"l"},
    {"mm(add(%00,fp,l),l,8)",     7, 17,    0,     2,     2,	"d"},
    {"?",                         0, 32,    0,     1,     1,	"l"},
    };

int	NOREG = nelts(regpatts) - 1;

/*	the spill template %00(fp) is the "register of last resort"	*/
char	regclass[MAX_REGBITS][REGBITS] = 
	{
	/* SUPPRESS 442 */
	"\0\0\0\0\0\0\0\0\1\1\1\1\1\1\1\1\3\4\4\4\4\4\4\4\4\4\4\4\4\4\4\4",
	"\6\6\6\6\6\6\6\6\2\2\2\2\2\2\2\2\3\5\5\5\5\5\5\5\5\5\5\5\5\5\5\5"
	};

char	*regnames[MAX_REGBITS][REGBITS] = {
    {
	"r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
	"f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7",
	"cc", "-8", "-16", "-24",
	"-32", "-40", "-48", "-56",
	"-64", "-72", "-80", "-88",
	"-96", "-100", "-104", "-108",
    },
/* some wider operands may be unuseable due to alignment (stride) constraints */
    {
	"r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
	"f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7",
	"cc", "-8", "-16", "-24",
	"-32", "-40", "-48", "-56",
	"-64", "-72", "-80", "-88",
	"-96", "-100", "-104", "-108",
    }
    };

/*  The string that begins comments in assembly language,
 *  or 0 if the assembly language has no commenting convention.
 */
char commentstring[] = "#";

