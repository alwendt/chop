/* this needs to be expanded !!! */
int fun[10] = {213,13546,234254,26,-4,234,-24};
main()
{
	unsigned int i = 5;
	char bf0[20],bf1[20];

	sprintf(bf0,"%d",fun[i]+(i*1024));
	sprintf(bf1,"%d",fun[i]+(i<<10));
	if(strcmp(bf0,bf1) != 0)
	{
		printf("<< not ok\n");
	} else
	{
		printf("<< ok\n");
	}

	i = 7234543;
	sprintf(bf0,"%d",fun[i%10]+(i/1024));
	sprintf(bf1,"%d",fun[i%10]+(i>>10));
	if(strcmp(bf0,bf1) != 0)
	{
		printf(">> not ok\n");
	} else
	{
		printf(">> ok\n");
	}
}
