














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






static char folding = 0, 	    
    ignore = 0, 		    
    stats = 0;			    
static short matchlen = 3;	    
static char *defvar = 0;	    
char *malloc();
static short arg = 1;		    

char *newstr(s)
    char *s;
    {
    char *p;
    p = malloc(strlen(s) + 1);
    strcpy(p, s);
    return p;
    }


static char **linebf = 0;	    


static unsigned start[2] = {0,0};

static unsigned stop[2] = {0,0};





static int last[2] = {0,0};	    
static int count[2] = {0,0};	    
static int current[2] = {0,0};     
static int endfile[2] = {-1,-1};   
static char nb[2] = {0, 0};	    



static int *hashtable = 0;	    

static char *fptr[2];	    
static char sync = 1;		
static struct _iobuf *ichan[2] = {0};	
static char *nocore = "Abort -- insufficient memory\n";
static char *nocomp = "Abort -- files differ too much\n";
static unsigned *collct = 0;  




int errkill(msg)
    char *msg;
    {
    fprintf((&_iob[2]), "%s\n", msg);
    exit(0);
    }





char *fold(s, result)
    char *s;
    char *result;
    {
    int c;
    char *t;
    char once;

    t = result;
    if (!result) errkill(nocomp);

    if (!folding && !ignore) return s + 1;	    
    
    
    if (ignore) {
	if (*s++ == '/') goto skipping;
	do  {
	    if (*s == '/' && *(s + 1) == '*') {
		
		s += 2;
		for (;;) {
skipping:	    if (*s == '\n') break;
		    if (*s == '*' && *(s + 1) == '/') {
			s += 2;
			break;
			}
		    s++;
		    }
		}
	    c = *s++;
	    if (c != ' ' && c != '\t') *t++ = c;
	    } while (c);
	}

    else {
	once = 0;
	do  {
	    c = *s++;
	    if (c == ' ' || c == '\t') {
		if (!once) {
		    *t++ = ' ';
		    once++;
		    }
		}
	    else    {
		once = 0;
		*t++ = c;
		}
	    } while (c);
	}
    
    return result;
    }


unsigned hash(line)
    char *line;
    {
    char	*fold();
    char buffer[1024		    ];
    unsigned result;
    char *lptr;

    lptr = fold(line, buffer);
    result = 0;
    while (*lptr) {
	result = (result >> 1) ^ *lptr++ ^ ((result & 1) << 15);
	}
    result = (result & 0x7fff) % 1279		    ;
    if (stats) collct[result]++;	
    return result;
    }



int entline(filex, buff, size)
    char *buff;
    char filex;
    unsigned size;
    {
    static unsigned hashind;
    static char *tmpstr;

    
    stop[filex] = (stop[filex] + 1) & 1023		    ;
    if (stop[filex] == start[filex]) errkill(nocomp);

    if (!(tmpstr = malloc(size))) errkill(nocomp);
    strcpy(tmpstr, buff);
    hashind = stop[filex] + (filex << 10);
    linebf[stop[filex] + (filex << 10)] = tmpstr;
    }





readaline(filex, linex)
    int filex;
    int linex;
    {
    struct _iobuf *f;
    static char commentmode[2];	
    unsigned csize;		
    char buff[1024		    ];
    int c;
    int lastcc = '\n';

    f = ichan[filex];
    if (endfile[filex] != -1) return;

    
    buff[0] = " /"[commentmode[filex]];
    csize = 1;

    
    for(;;) {
	c = 		fgetc(f);

	if (c == '*') {
	    if (lastcc == '/' && ignore) commentmode[filex] = 1;
	    }

	else if (c == '/') {
	    if (lastcc == '*' && ignore) commentmode[filex] = 0;
	    }

	else if (c == '\n') {
	    buff[csize++] = c;
	    buff[csize++] = 0;
	    entline(filex, buff, csize);
	    return;
	    }

	else if (c == (-1)) {
	    if (csize > 1) {
		buff[csize++] = 0;
		linex++;
		entline(filex, buff, csize);
		}
	    entline(filex, " (End of file)\n", 16);
	    endfile[filex] = linex;
	    return;
	    }
	lastcc = c;
	buff[csize++] = c;
	}
    }


char *lines(filex, linex)
    char filex;
    int linex;
    {
    char	*s;
    if (linex > last[filex] + ((stop[filex] - start[filex]) & 1023		    ))
	readaline(filex, linex);

    /*
    s = linebf[(filex << 10) +
	((linex - last[filex] + start[filex]) & (1023		    ))];
    */
    return linebf[(filex << 10) +
	((linex - last[filex] + start[filex]) & (1023		    ))];
    }



char match()
    {
    char *s0, *s1;
    char bf0[1024		    ], bf1[1024		    ];
    short j;
    char t;
    unsigned tmp;
    static unsigned k;

    if (sync) j = 1; else j = matchlen;
    k = 0;

    while (j) {
	
	nb[0] = 0;
red0:
	tmp = count[0] + k;
	tmp += nb[0];
	s0 = fold(lines(0, tmp), bf0);
	if (s0[0] == '\n' && ignore) {
	    if (j == matchlen && !defvar) goto fal;
	    nb[0]++;
	    goto red0;
	    }

	nb[1] = 0;
red1:	
	s1 = fold(lines(1, count[1] + k + nb[1]), bf1);
	if (s1[0] == '\n' && ignore) {
	    if (j == matchlen && !defvar) goto fal;
	    nb[1]++;
	    goto red1;
	    }
	
	if (strcmp(s0, s1)) goto fal;

	
	if (s0[0] != '\n' || defvar) j--;	    

	




	else if (j == matchlen && !defvar) goto fal;

	
	/* Ensure end of files match */
	switch((endfile[0] == count[0] + k + nb[0]) +
	    (endfile[1] == count[1] + k + nb[1]))
	    {
	    case 0: k++; continue;
	    case 1: goto fal;
	    case 2: goto tru;
	    }
	}

tru:	return 1;
fal:	sync = 0;   return 0;
    }


char *id(filex)
    char filex;
    {
    fputs("File ", (&_iob[1])); fputs(fptr[filex], (&_iob[1]));
    if (last[filex] == 0) fputs(" beginning to ", (&_iob[1]));
    else printf(" line %d to ", last[filex]);
    if (count[filex] == endfile[filex]) fputs("end\n", (&_iob[1]));
    else printf("line %d\n", count[filex]);
    }

int runout()
    {
    char filex = 0;
    static char *delim = "<><><><><><><><><><><><><><><><><><><>";
    static int linex;
    if (defvar) {
	
	


	if (last[0] + 1 >= count[0] ||			
	    count[0] - last[0] > count[1] - last[1] &&	last[1] + 1 < count[1])			
	    filex = 1;

	if (filex) printf("#ifndef %s\n", defvar);
	else printf("#ifdef %s\n", defvar);

	for (linex = last[filex] + 1; linex < count[filex]; linex++)
	    if (linex != endfile[filex])
		fputs(lines(filex, linex) + 1, (&_iob[1]));

	filex = 1 - filex;

	
	if (last[filex] + 1 < count[filex]) {
	    printf("#else\n");
	    for (linex = last[filex] + 1; linex < count[filex]; linex++)
		if (linex != endfile[filex])
		    fputs(lines(filex, linex) + 1, (&_iob[1]));
	    }

	fputs("#endif\n", (&_iob[1]));
	}
    else for (filex = 0; filex < 2; filex++) {	    
	
	id(filex);	
	if (!filex) fputs(delim, (&_iob[1]));
	puts(delim);
	for (linex = last[filex]; linex <= count[filex]; linex++) {
	    fputs(lines(filex, linex) + 1, (&_iob[1]));
	    }
	if (filex) fputs(delim, (&_iob[1]));
	puts(delim);
	}
    }




int crong(filex)
    char filex;
    {
    static int i;

    count[filex] += sync + nb[filex] - 1;
    for (i = last[filex]; i < count[filex]; i++) {
	char *p;
	if (p = linebf[start[filex] + (filex << 10)]) free(p);
	start[filex]++;
	start[filex] &= 1023		    ;
	}

    current[filex] = last[filex] = count[filex];
    }

main(ac,av)
    int ac;
    char **av;
    {
    static unsigned i;
    static char strikes;
    int *hashp, *hashend;
    static unsigned hashind, hash0, hash1;
    static char *tb;

    for (;;) {
	nextarg:  
	av++;
	ac--;
	if (ac <= 0 || *av[0] != '-') break;
	while (*++*av) {
	    if (** av == 'f') folding++;
	    else if (** av == 'i') ignore++;
	    else if (** av == 'z') stats++;
	    else if (** av == 's') { matchlen = atoi(av[0] + 1); goto nextarg; }
	    else if (** av == 'D') { defvar = newstr(av[0] + 1); goto nextarg; }
	    else {
		fooey:
		fprintf((&_iob[2]), "Format: scom <flags> <file1> <file2>\n");
		fprintf((&_iob[2]),
		    "flags: -f fold whitespace to single space\n");
		fprintf((&_iob[2]), "	-i ignore whitespace entirely\n");
		fprintf((&_iob[2]), "	-sN resynchronize at N equal lines\n");
		fprintf((&_iob[2]), "	-Dname output program with #defines\n");
		exit(1);
		}
	    }
	}

    if (ac != 2) goto fooey;

    
    for (i = 0; i < 2; i++)
	{
	ichan[i] = fopen(av[i], "r");
	fptr[i] = av[i];	    
	if (ichan[i] == 0)	    
	    {
	    fprintf((&_iob[2]), "can't read %s\n", av[i]);
	    exit(1);
	    }	
	}

    
    if (stats) collct = (unsigned *)malloc(sizeof(unsigned) * 1279		    );

    
    
    hashtable = (int *)malloc(1279		     * 2 * sizeof(unsigned));
    if (!hashtable) errkill("can't allocate hash table\n");

    linebf = (char **)malloc((1023		     + 1) * 2 * sizeof(char *));
    if (!linebf) errkill("can't allocate line buffer\n");

    
    tb = " (Beginning of file)\n";
    if (!(linebf[0] = newstr(tb))) errkill(nocore);
    if (!(linebf[1023		    +1] = newstr(tb))) errkill(nocore);

    
    

    
resyn:	
    hashend = hashtable + 1279		     * 2;
    for (hashp = hashtable; hashp != hashend; hashp++) *hashp = -1;

    
in: strikes = 0;

    if (current[0] == endfile[0]) strikes++;
    else current[0]++;

    if (current[1] == endfile[1]) strikes++;
    else current[1]++;

    count[0] = current[0];
    count[1] = current[1];

    if (match()) goto found;

    
out:	count[0] = current[0];		    

    
    if (current[1] != endfile[1]) {
	hash1 = hash(lines(1, current[1]));
	hashind = hash1 + 1279		    ;
	while (hashtable[hashind] != -1) {
	    hashind++;
	    if (hashind == 1279		     * 2) hashind = 1279		    ;
	    }
	
	
	hashtable[hashind] = stop[1];
	}

    
    hash0 = hash(lines(0, current[0]));
    hashind = hash0 + 1279		    ;

    
    while (hashtable[hashind] != -1) {
	count[1] = last[1] + ((hashtable[hashind] - start[1]) & 1023		    );
	if (match()) goto found;
	hashind++;
	if (hashind == 1279		     * 2) hashind = 1279		    ;
	}

    
    count[1] = current[1];

    
    if (current[0] != endfile[0]) {
	hashind = hash0;
	while (hashtable[hashind] != -1) {
	    hashind++;
	    if (hashind == 1279		    ) hashind = 0;
	    }

	
	hashtable[hashind] = stop[0];
	}

    hashind = hash1;
    while (hashtable[hashind] != -1) {
	count[0] = last[0] + ((hashtable[hashind] - start[0]) & 1023		    );
	if (match()) goto found;
	hashind++;
	if (hashind == 1279		    ) hashind = 0;
	}

    goto in;

    
found:
    if (!sync) runout(0);

    
    if (sync && defvar && count[0] && count[0] != endfile[0])
	fputs(lines(0, count[0]) + 1, (&_iob[1]));

    crong(0); crong(1); 	

    
    if (strikes == 2) {
	if (stats)
	    for (i = 0; i < 1279		    ; i++)
		if (collct[i] != 0) printf("%5d  %5d\n",i,collct[i]);
	exit(1);
	}

    if (sync) goto in;
    else    { sync = 1; goto resyn; }
    }
