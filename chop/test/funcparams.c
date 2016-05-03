/* This is to test all the different possible parameters */
/* Also to test loading from globals, locals, and statics */
func(c,s,i,l,a,p,C,S,I,L,F,D,A,P)
unsigned char c;
unsigned short s;
unsigned int i;
unsigned long l;
char a[];
char *p;
char C;
short S;
int I;
long L;
float F;
double D;
int A[];
int *P;
{
	printf("%d %d %d %d %d %d\n%d %d %d %d %f %f %d %d\n",c,s,i,l,a[3],
	       *p,C,S,I,L,F,D,A[2],*P);
}

unsigned char Gc = 0;
unsigned short Gs = 1;
unsigned int Gi = 2;
unsigned long Gl = 3;
char Ga[] = {10,20,30,40,50,60,70};
char *Gp= Ga+5;
char GC= 128;
/* short GS= -32768; chop does not like -32768 */
short GS= -32767;
int GI= -936742;
long GL= -723489398;
float GF= 12782.342;
double GD= -89903.;
int GA[] = { -8,-9,-10,-11,-12};
int *GP= &GI;


static unsigned char Sc = 83;
static unsigned short Ss = 433;
static unsigned int Si = 8392;
static unsigned long Sl = 23432;
static char Sa[] = {10,120,0,4,50,60,70};
static char *Sp= Sa+5;
static char SC= 42;
static short SS=21345;
static int SI=234523;
static long SL= -72998;
static float SF= 1782.42;
static double SD= 9903.;
static int SA[] = { 432,549,12345111,11,12};
static int *SP= &SI;
main()
{
	unsigned char c = 255;
	unsigned short s = 65535;
	unsigned int i = 4102345678;
	unsigned long l = 738293;
	static char a[] = {1,2,3,4,5,6,7};
	char *p= a+5;
	char C= -127;
	short S=32767;
	int I=829342;
	long L= 8239454;
	float F= 782.342;
	double D= 372934.;
	static int A[] = { 8,9,10,11,12};
	int *P= &I;
	func(c,s,i,l,a,p,C,S,I,L,F,D,A,P);
	func(Gc,Gs,Gi,Gl,Ga,Gp,GC,GS,GI,GL,GF,GD,GA,GP);
	func(Sc,Ss,Si,Sl,Sa,Sp,SC,SS,SI,SL,SF,SD,SA,SP);
}
