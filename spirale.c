#include <stdio.h>

int main()
{
	float i, x = 125.0, y = 125.0;
	for(i=5.0;i<250.0;i+=10.0)
	{
		printf("draw (%f,%f)--+(%f,0)--+(0,%f)--+(%f,0)--+(0,%f);\n",x,y,i,i,(i+5.0)*(-1),(i+5.5)*(-1));
		x -= 5.0;
		y -= 5.0;
	}
}