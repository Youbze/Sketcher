#include <stdio.h>

#define PI 3.1416
int main()
{
	char * alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	printf("point CENTER = (125,150);\npoint A = (100,100);\npoint B = (150,100);\n");
	int i;
	float delta = 4;
	for(i=2;i<52;i++)
	{
		printf("point %c = %c;\n", alphabet[i], (i%2 ? 'B' : 'A'));
		printf("translate (%c,(0,%f));\n", alphabet[i], delta);
		if(i%2)
			delta+=4;
	}
	for(i=0;i<52;i+=2)
	{
		printf("draw %c--CENTER--%c;\n", alphabet[i], alphabet[i+1]);
	}
	printf("\n");
	return 0;
}