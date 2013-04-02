%{
	#include <stdio.h>		
	#include <math.h>
	#include <cairo.h>
	#include <cairo-pdf.h>

	#define MAXPOINTSPARCOMMANDE 10

	typedef struct {
		int x;
		int y;
		int isRelative;
	}s_point;

	cairo_surface_t * pdf_surface;
	cairo_t* cr;
	s_point tab_points[MAXPOINTSPARCOMMANDE];
	int i_pts;
%}

%union {
	int entier;
	s_point sp;
}

%type <sp> point cart pol
%type <entier> exp

%token DRAW CYCLE
%token <entier> NB
%token EOL ENDFILE


%%
in:		in line ENDFILE {printf("Hooooo noon c'est finiiiiii \n"); return 0;}
		| 
		| EOL
		;

line: 	cmd EOL	{	
					int i;
					for(i=0;i<i_pts;i++)
					{
						if(tab_points[i].isRelative && i > 0)
						{
							tab_points[i].x+=tab_points[i-1].x;
							tab_points[i].y+=tab_points[i-1].y;
							cairo_line_to(cr, tab_points[i].x, tab_points[i].y);
						}
						else
							cairo_line_to(cr, tab_points[i].x, tab_points[i].y);
					}

					cairo_stroke(cr);
					i_pts = 0;
				}
		| error EOL	{printf("\nERROR\n");}
		;

cmd:	DRAW points ';'
		;

points:	point 					{
									tab_points[i_pts] = $1;
									i_pts++;	
								}
		| points '-''-' point 	{
									tab_points[i_pts] = $4;
									i_pts++;
								}
		| points '-''-''+' point {
									tab_points[i_pts] = $5;
									tab_points[i_pts].isRelative = 1;
									i_pts++;
								}	
		| points '-''-' CYCLE	{
									tab_points[i_pts] = tab_points[0];
									i_pts++;
								}									
		;

point:	cart 					{
									$$ = $1;
								}
		| pol					{
									$$ = $1;
								}
		;

cart:	'('exp','exp')'			{
									s_point res;
									res.x = $2;
									res.y = $4;
									$$ = res;
								}
		;

pol:	'('exp':'exp')'			{
									s_point res;
									res.x = $4*cos($2);
									res.y = $4*sin($2);
									$$ = res;
								}
		;

exp:	NB						{
									$$ = $1;
								}
		| '-'NB					{
									$$ = -$2;
								}
		| exp '/' NB				{
									$$ = $1/$3;
								}
		| exp '+' NB				{
									$$ = $1+$3;
								}
		| exp '*' NB				{
									$$ = $1*$3;
								}
		| exp '-' NB				{
									$$ = $1-$3;
								}
		| '('exp')'				{ $$ = $2; }
		;

%%
yyerror(char* msg){
	printf("%s\n", msg);
}

int main(int argc, char *argv[]){
	pdf_surface = cairo_pdf_surface_create("out.pdf", 100, 100);
	cr = cairo_create(pdf_surface);
	cairo_set_line_width (cr, 1.0);
	i_pts = 0;
	yyparse();
	cairo_destroy(cr);
	cairo_surface_destroy(pdf_surface);

	return 0;
}
