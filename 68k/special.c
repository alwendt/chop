/*  68k dependent compiler code	*/

#include <stdio.h>
#include "c.h"
#include "hop2.h"

/*  Legal allocable temporary names.  The variables must be %00 because
 *  factor() expects them to be.  "a" registers must follow "d" registers
 *  so that the moveml instruction's mask does not require shifting to
 *  compute.
 */
struct Regpatts regpatts[] = {
/*  rt                    many  bit volat width stride typename */
    {"d(%00,4)",	     8, 0,	0,	1,  1,     "l"},
    {"a(%00,4)",	     6, 8,	0,	1,  1,     "l"},
    {"f(%00,4)",	     8, 13,	0,	1,  1,     "f"},
    {"f(%00,8)",	     8, 13,	0,	1,  1,     "d"},
    {"cc(%00)",		     1, 22,	1,	1,  1,     "b"},
    {"mm(add(%00,a6,l),l,4)",9, 23,	0,	1,  1,     "l"},
    {"mm(add(%00,a6,l),l,8)",9, 23,	0,	1,  1,     "d"},
    {"?",		     0, 32,	0,	1,  1,     "l"},
    };

int	NOREG = nelts(regpatts) - 1;

/*	Map from bit number and width back to register class (regpatts index) */
char	regclass[MAX_REGBITS][REGBITS] =
	{
	"\0\0\0\0\0\0\0\0\1\1\1\1\1\1\2\2\2\2\2\2\2\2\4\5\5\5\5\5\5\5\5\5",
	"\0\0\0\0\0\0\0\0\1\1\1\1\1\1\3\3\3\3\3\3\3\3\4\6\6\6\6\6\6\6\6\6"
	};

/*	register names, in preference order of allocation		*/
/*	If you change this, fix the end-function stuff in specialx	*/
char	*regnames[MAX_REGBITS][REGBITS] = {
    {
    "d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7",			/* data */     
    "a0", "a1", "a2", "a3", "a4", "a5",					/* address */
    "fp0", "fp1", "fp2", "fp3", "fp4", "fp5", "fp6", "fp7",		/* float */    
    "0",								/* cc */
    "-8", "-16", "-24", "-32", "-40", "-48", "-56", "-64", "-72"	/* spill templates */
    },
    {
    "d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7",			/* data */     
    "a0", "a1", "a2", "a3", "a4", "a5",					/* address */
    "fp0", "fp1", "fp2", "fp3", "fp4", "fp5", "fp6", "fp7",		/* float */    
    "0",								/* cc */
    "-8", "-16", "-24", "-32", "-40", "-48", "-56", "-64", "-72"	/* spill templates */
    }
    };

/*  If there is a string that begins assembly comment, which continues to the
 *  end of a line, define this string as such.
 */

char commentstring[] = "|";
