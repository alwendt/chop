/* This is to test the different division types with constants and with */
/* variables of that type (we use the same variable for ease */
main()
{
	unsigned char c = 255;
	unsigned short s = 932;
	unsigned int i = -10245678;
	unsigned long l = 28253623;
	static char a[] = {1,2,3,4,5,6,7};
	char *p= a+5;
	char C= 123;
	short S=117;
	int I= -45234232;
	long L= 2344;
	float F= .342;
	double D= 3234.;
	static int A[] = { 8,9,10,11,12};
	int *P= A+1;

	c /= 5;
	c /= c / 2;
	s /= 15;
	s /= s / 24;
	i /= 468;
	i /= i / 245;
	l /= 83;
	l /= l / 246;
	a[2] /= a[4];
	p[2] /= p[-1];
	C /= -1;
	C /= C / 2;
	S /= 7;
	S /= S / 4;
	I /= -932;
	I /= I / 63;
	L /= -44;
	L /= L / 23;
	F *= 72.342;
	F *= F;
	D *= 3934.83;
	D *= D;
	A[1] /= A[0];
	P[-1] /= P[3];
	printf("%d %d %d %d %d %d\n%d %d %d %d %f %f %d %d\n",
	    c,s,i,l,a[3],*p,
	    C,S,I,L,F,D,A[2],*P);
}
