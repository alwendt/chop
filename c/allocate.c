/* C compiler: tree management */

#include "c.h"

static struct arena first[] = {
	0, 0, &first[0], 0,
	0, 0, &first[1], 0,
};
Arena permanent = &first[0];	/* permanent storage */
Arena transient = &first[1];	/* transient storage; released at function end */

static Arena freearenas;	/* list of free arenas */

/* allocate - allocate n bytes in arena **p, adding a new arena if necessary */
char *allocate(n, p) Arena *p; {
	extern char *malloc();
	Arena ap = *p;

	while (ap->avail + n + 7 > ap->limit)
		if (ap->next) {		/* move to next arena */
			ap = ap->next;
			ap->avail = (char *)ap + sizeof *ap;
		} else if (ap->next = freearenas) {
			freearenas = freearenas->next;
			ap = ap->next;
			ap->avail = (char *)ap + sizeof *ap;
			ap->first = (*p)->first;
			ap->next = 0;
		} else {		/* allocate a new arena */
			int m = ((n + 7)&~7) + MEMINCR*1024 + sizeof *ap;
			ap->next = (Arena) malloc(m);
			assert(ap->next && (int)ap->next >= 0);
			if ((char *)ap->next == ap->limit) /* extend previous arena? */
				ap->limit = (char *)ap->next + m;
			else {			/* link to a new arena */
				ap = ap->next;
				ap->limit = (char *)ap + m;
				ap->avail = (char *)ap + sizeof *ap;
			}
			ap->first = (*p)->first;
			ap->next = 0;
		}
	*p = ap;
	ap->avail = (char *)(((int)ap->avail + 7) & ~7) + n;
	return ap->avail - n;
}

/* deallocate - release all space in arena *p, except the first arena; reset *p */
void deallocate(p) Arena *p; {
	Arena first = (*p)->first;

	(*p)->next = freearenas;
	freearenas = first->next;
	first->next = 0;
	*p = first;
}

