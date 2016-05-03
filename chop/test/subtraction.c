/* This is to test the different subtraction types with constants and with */
/* variables of that type (we use the same variable for ease */
main()
{
	unsigned char c = 25;
	unsigned short s = 932;
	unsigned int i = -10245678;
	unsigned long l = 2823;
	static char a[] = {1,2,3,4,5,6,7};
	char *p= a+5;
	char C= 127;
	short S=117;
	int I=232;
	long L= 2344;
	float F= .342;
	double D= 3234.;
	static int A[] = { 8,9,10,11,12};
	int *P= A+1;

	c -= 5;
	c -= c - 78;
	s -= 15535;
	s -= s - 234;
	i -= 42678;
	i -= i - 2345;
	l -= 893;
	l -= l - 2346;
	a[2] -= a[4];
	p -= 3 - 1;
	p[2] -= p[-1];
	C -= 157;
	C -= C - 113;
	S -= 67;
	S -= S - 43;
	I -= -9342;
	I -= I - 63;
	L -= -454;
	L -= L - 23;
	F -= 72.342;
	F -= F - 234;
	D -= 3934.83;
	D -= D - 2562;
	A[1] -= A[0];
	P -= -3 - -1;
	P[-1] -= P[0];
	printf("%d %d %d %d %d %d\n%d %d %d %d %f %f %d %d\n",c,s,i,l,a[3],
	       *p,C,S,I,L,F,D,A[2],*P);
}
