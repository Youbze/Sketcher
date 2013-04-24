#include <stdio.h>

#define PI 3.1416
int main()
{
	char * alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	printf("point CENTER = (125,150);\npoint A = (100,100);\npoint B = (150,100);\n");
	int i;
	float angle = PI/6.0;
	for(i=2;i<24;i++)
	{
		printf("point %c = %c;\n", alphabet[i], (i%2 ? 'B' : 'A'));
		printf("rotate (%c,CENTER,%f);\n", alphabet[i], angle);
		if(i%2)
			angle+= (PI/6.0);
	}
	printf("draw ");
	for(i=0;i<24;i+=2)
	{
		printf("%c--%c--CENTER", alphabet[i], alphabet[i+1]);
		if(i < 22)
			printf("--");
		else
			printf("--A;");
	}
	printf("\n");
	return 0;
}