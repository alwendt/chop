#include <ctype.h>
#include <stdio.h>
#include "c.h"
#include "hop2.h"

char *backin = "nbft";
char *backout = "\n\b\f\t";

char *deback(s)			/* delete backslashes except	*/
    char *s;			/* for the second one in a pair */
				/* of them and those	*/
				/* before one of the backin chars */
    {
    char	*t, *d;
    static char result[MAXREQLEN];

    for (d = result;; s++) {

	if (*s == '\\') {			/* if input is backslash */
	    s++;				/* advance to next input */
	    if (t = index(backin, *s)) {	/* if it's special	*/
		*d++ = '\\';			/* leave it in 		*/
		}
	    }

	if (!(*d++ = *s)) break;		/* else just copy input */
	}

    return result;
    }

char *conback(s)			/* convert backslashes in front of */
    char *s;				/* special chars		*/
    {
    char	*t, *d;
    static char result[MAXREQLEN];

    for (d = result;; s++) {

	if (*s == '\\') {			/* if input is backslash */
	    s++;				/* advance to next input */
	    if (t = index(backin, *s)) {	/* if its special	*/
		*d++ = backout[t - backin];	/* translate it		*/
		continue;
		}
	    *d++ = '\\';			/* leave it in 		*/
	    }

	if (!(*d++ = *s)) break;		/* else just copy input */
	}

    return result;
    }
