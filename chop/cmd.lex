%start INCLUDE COMMENT QUOTED

C   ([a-zA-Z0-9_()<>[\]{},.;&!~*/+\-=^|?:@`$# ])

cchar	((\\?)({C}|\"))|(\\\')|(\\\\)|(\\([0-7]{1,3}))
schar	((\\?)({C}|\'))|(\\\")|(\\\\)|(\\([0-7]{1,3}))|(\\\%)
%{


#ifdef FLEX_SCANNER
#define YY_USER_INIT { yyin = mdfile; }
#else
static	char bf[1024];
static char *strptr = bf;
#undef input
#undef unput
#define unput(c)  ( *--strptr = c )
static input() {
	if (*strptr == 0) {
	    if (!fgets(bf + 200, sizeof(bf) - 200, mdfile)) return 0;
	    strptr = bf + 200;
	    }

	return *strptr++;
	}
yywrap() {
    return 1;
    }
#endif


/* SUPPRESS 17 */
/* SUPPRESS 20 */
extern char *deback();
%}
%%

<INITIAL>[A-Za-z_][A-Za-z0-9_]* {
			yylval.text = string(yytext);
			return Identifier;
			}

<INITIAL>-?[0-9]+	{
			yylval.text = string(yytext);
			return Integer;
			}

<INITIAL>\"		{
			BEGIN QUOTED;
			return Openquote;
			}

<QUOTED>\"		{
			BEGIN INITIAL;
			return Closequote;
			}

<QUOTED>"%"[a-zA-Z_]([a-zA-Z0-9_]*)\\ {
			/* A backslash that terminates an identifier in quoted
			 * mode is discarded.  For example "%add%l\t" becomes
			 * the identifiers %add, %l, followed by literal "t".
			 */
			yytext[strlen(yytext) - 1] = 0;
			yylval.text = string(yytext+1);
			return Identifier;
			}

<QUOTED>"%"[a-zA-Z_]([a-zA-Z0-9_]*) {
			yylval.text = string(yytext+1);
			return Identifier;
			}

<QUOTED>({schar})*	{
			yylval.text = string(deback(yytext));
			return String;
			}

<QUOTED>.		{
			yyerror("bad char in quoted string\n");
			}

<INITIAL>'({cchar})'	{
			yylval.text = string(yytext);
			return Integer;
			}


<INITIAL>"%type"        {
			return Type;
			}

<INITIAL>"%register"	{
			return Register;
			}

<INITIAL>"%range"	{
			return Range;
			}

<INITIAL>"%terminal"	{
			return Term;
			}

<INITIAL>"%{"		{
			BEGIN INCLUDE;
			}

<INCLUDE>"%}"		{
			BEGIN INITIAL;
			}

<INCLUDE>\n		{
			mdlineno++;
			return Included;
			}

<INCLUDE>.		{
			return Included;
			}



<INITIAL>[(),.:;?[\]{}~]	{
				return yytext[0];
				}
<INITIAL>([|^&+\-%*/=!><])	{
				return yytext[0];
				}
<INITIAL>[\n]			{
				mdlineno++;
				}
<COMMENT>.			;
<COMMENT>\n			{
				mdlineno++;
				BEGIN INITIAL;
				}
<INITIAL>[ \t]			;
<INITIAL>[#]			{
				BEGIN COMMENT;
				}
<INITIAL>.			{
				yyerror("bad char in initial state\n");
			    	}
%%

