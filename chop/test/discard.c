/* This is to test all the different possible discards */
main()
{
	unsigned char c = 72;
	unsigned short s = 532;
	unsigned int i = 6324;
	unsigned long l = 738293;
	static char a[] = {1,2,3,4,5,6,7};
	char *p= a+5;
	char C= -6;
	short S=73;
	int I=829342;
	long L= 8239454;
	float F= 782.342;
	double D= 372934.;
	static int A[] = { 8,9,10,11,12};
	int *P= &I;
	c;
	s;
	i;
	l;
	a;
	p;
	C;
	S;
	I;
	L;
	F;
	D;
	A;
	P;

	c + 23;
	s + 323;
	i + 32342;
	l + 234223;
	a + 2;
	p + 234;
	C + 4;
	S + -234;
	I + -1233;
	L + 234;
	F + 23.2;
	D + 2323.;
	A + 23;
	P + 234;
}
