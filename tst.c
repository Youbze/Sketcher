#include <stdio.h>

int main()
{
	float i, x = 50.0, y = 50.0;
	for(i=5.0;i<100.0;i+=10.0)
	{
		printf("draw (%f,%f)--+(%f,0)--+(0,%f)--+(%f,0)--+(0,%f);\n",x,y,i,i,(i+5.0)*(-1),(i+5.2)*(-1));
		x -= 5.0;
		y -= 5.0;
	}
}