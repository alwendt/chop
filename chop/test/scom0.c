static int last[2] = {0,0};	    
static int count[2] = {0,0};	    
static int current[2] = {0,0};     
static int endfile[2] = {-1,-1};   
static char nb[2] = {0, 0};	    

main() {
	int k=0;
	switch((endfile[0] == count[0] + k + nb[0]) +
	    (endfile[1] == count[1] + k + nb[1]))
	    {
	    case 0: k++;
	    case 2: goto tru;
	    case 1: goto fal;
	    }
    fal: printf("false\n");
	 exit(1);
    tru: printf("true %d\n",k);
	 exit(0);
    }
