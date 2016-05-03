/* This is to test the different addition types with constants and with */
/* variables of that type (we use the same variable for ease */
main()
{
	float F= .342;
	double D= 3234.;
	F += 72.342;
	F += F + 2342.3;
	D += 3934.83;
	D += D + 0.00001;
	printf("%.8f\n", (double)D);
}
