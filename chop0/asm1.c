#include <stdio.h>
#include <ctype.h>
#include "c.h"
#include "hop2.h"
#include "md.h"

char *gets();
char	*filename = "md";
extern int gdumpsets;
extern struct State *bog;
int	NOREG;

main(argc, argv)
    int		argc;
    char	**argv;
    {
    struct State *sp;
    char lin[MAXRTS];
    int	gotone;			/* got one parse back	*/
    int		n;

    if (argc == 2) {
	gdumpsets = 1;
	if (atoi(argv[1])) bog = (struct State *)atoi(argv[1]);
	}

    setbuf(stdout, 0);
    getmd(filename);

    for (;;) {
	printf(": ");
	if (gets(lin) == NULL) break;
	if (*lin == '#') continue;
	if (*lin == '>') {
	    gotone = 0;
	    for (sp = newinst2(lin+1, parse); sp; sp = sp->next) {
		gotone = 1;
		printf("%s ", sp->trans);
		printf("cost=%f", (double)sp->cost);
		for (n = 0; n < MAXGLOBALS + MAXFREENONTERMS; n++)
		    if (sp->constraints[n]) {
			printf(" ");
			printf(VARFMT, n);
			printf("=%s", sp->constraints[n]);
			}
		/* dumpparse(sp, 0); */
		printf("\n");
		}
	    if (!gotone)
		printf("%.*s ^ %.*s maxstate = %d\n",
		     maxstate+1, lin + 1, strlen(lin) - maxstate - 2,
			 maxstate + lin + 2, maxstate);
	    }
	else {
	    gotone = 0;
	    for (sp = parse(lin+1, 0); sp; sp = sp->next) {
		gotone = 1;
		printf("%s ", sp->trans);
		printf("cost=%f", (double)sp->cost);
		for (n = 0; n < MAXGLOBALS + MAXFREENONTERMS; n++)
		    if (sp->constraints[n]) {
			printf(" ");
			printf(VARFMT, n);
			printf("=%s", sp->constraints[n]);
			}
		printf("\n");
		}
	    if (!gotone)
		printf("%.*s ^ %.*s\n",
		     maxstate, lin + 1, strlen(lin) - maxstate - 1,
			 maxstate + lin + 1);
	    }
	}
    }

/* VARARGS1 */
cerror( s, a, b, c ) char *s; { /* compiler error: die */
    fprintf( stderr, s, a, b, c );
    fprintf( stderr, "\n" );
#ifdef BUFSTDERR
    fflush(stderr);
#endif
    exit(1);
    }

int fatal(name, fmt, n)
    char *name, *fmt;
    {
    fprintf(stderr, fmt, n);
    exit(-1);
    }
