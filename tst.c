#include <stdio.h>

int main()
{
	int i, x = 50, y = 50;
	for(i=5;i<100;i+=10)
	{
		printf("draw (%d,%d)--+(%d,0)--+(0,%d)--+(%d,0)--+(0,%d);\n",x,y,i,i,(i+5)*(-1),(i+5)*(-1));
		x -= 5;
		y -= 5;
	}
}