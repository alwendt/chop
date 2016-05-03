/* This is to test the different multiplication types with constants and with */
/* variables of that type (we use the same variable for ease */
main()
{
	unsigned char c = 3;
	unsigned short s = 932;
	unsigned int i = -10245678;
	unsigned long l = 2823;
	static char a[] = {1,2,3,4,5,6,7};
	char *p= a+5;
	char C= 128;
	short S=117;
	int I=232;
	long L= 2344;
	float F= .342;
	double D= 3234.;
	static int A[] = { 8,9,10,11,12};
	int *P= A+3;

	c *= 2;
	c *= c * 2;
	s *= 15535;
	s *= s * 23;
	i *= 42678;
	i *= i * 23;
	l *= 893;
	l *= l * 3234;
	a[2] *= a[4] * 234;
	p[2] *= p[-1] * 452;
	C *= -157;
	C *= C * 22;
	S *= 67;
	S *= S * -32;
	I *= -9342;
	I *= I * 234;
	L *= -454;
	L *= L * 2345;
	F *= 72.342;
	F *= F * 23.2;
	D *= 3934.83;
	D *= D * .234;
	A[1] *= A[0] * 2;
	P[-1] *= P[0] * 5;
	printf("%d %d %d %d %d %d\n%d %d %d %d %f %f %d %d\n",c,s,i,l,a[3],
	       *p,C,S,I,L,F,D,A[2],*P);
}
