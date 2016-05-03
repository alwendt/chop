unsigned char cfunc();
unsigned short sfunc();
unsigned int ifunc();
unsigned long lfunc();
char *pfunc();
char Cfunc();
short Sfunc();
int Ifunc();
long Lfunc();
float Ffunc();
double Dfunc();
int *Pfunc();
void dotfunc();
main()
{
	int i=734593;
	int z;
	dotfunc(&i);
	printf("%d %d %d %d %d %d %d\n%d %d %f %f %d %d\n",
	   cfunc(i),sfunc(i),ifunc(i),lfunc(i),pfunc(i)[2],Cfunc(i),Sfunc(i),
	   Ifunc(i),Lfunc(i),Ffunc(i),Dfunc(i),Pfunc(i)[4],(z,i));
}

unsigned char cfunc(i)
int i;
{
	unsigned char c = (unsigned char) i;
	return c;
}

unsigned short sfunc(i)
int i;
{
	unsigned short s = (unsigned short) i;
	return s;
}

unsigned int ifunc(i)
int i;
{
	unsigned int ei = (unsigned int) i;
	return ei;
}

unsigned long lfunc(i)
int i;
{
	unsigned long l = (unsigned long) i;
	return l;
}

char  *pfunc(i)
int i;
{
	static char array[5];
	char *p = &array[4];
	int j;
	for(j=0;j<5;j++) /* test pb... */
		p[-j] = -j;
	p = array;
	for(j=0;j<5;j++) /* test pa... */
		p[j] = j;
	for(j=0;j<5;j++)
		array[j] *= i;
	return p;
}

char Cfunc(i)
int i;
{
	char C = (char) i;
	return C;
}

short Sfunc(i)
int i;
{
	short S = (short) i;
	return S;
}

int Ifunc(i)
int i;
{
	int I = (int) i;
	return I;
}

long Lfunc(i)
int i;
{
	long L = (long) i;
	return L;
}

float Ffunc(i)
int i;
{
	float F = (float) i;
	return F;
}

double Dfunc(i)
int i;
{
	double D = (double) i;
	return D;
}

int  *Pfunc(i)
int i;
{
	static int array[5];
	int *P = &array[4];
	int j;
	for(j=0;j<5;j++)
		P[-j] = -j;
	P = array;
	for(j=0;j<5;j++)
		P[j] = j;
	for(j=0;j<5;j++)
		array[j] *= i;
	return P;
}

void dotfunc(pi)
int *pi;
{
	(*pi)++;
}

