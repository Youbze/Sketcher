%{
	#include <stdlib.h>
	#include <stdio.h>		
	#include <math.h>
	#include <cairo.h>
	#include <cairo-pdf.h>
	#include <string.h>

	#define DOUBLE 	1
	#define INT 	2
	#define POINT 	3
	#define CHEMIN 	4

	typedef struct {
		double x;
		double y;
		int isRelative;
	}s_point;

	/*
	* Table contenant les variables crees par l'utilisateur
	*/

	typedef struct {
		char *name;
		int type; // DOUBLE or INT
		union {
			double d_value;
			int i_value;
			s_point p_value;
			s_point* c_value;
		} value;
		struct table *next;
	} table;

	table *var_table = NULL;

	table *getvar(char* name){
		
		table *iter = var_table;

		while(iter->next != NULL){
			printf("HERHERHEREHREHR_n");
			if (strcmp((char*)iter->name, (char*)name) == 0){
				return iter;
			}

			iter = (table*) iter->next;
		}

		return NULL;
	}

	table *addvar(char* name, int type){

		table *var = getvar(name);

		if (var == NULL)
			var = malloc(sizeof(table));

		var->type = type;
		var->name = malloc(strlen(name) + 1);
		strcpy(var->name,name);


		var->next = (struct table*) var_table;

		var_table = var;

		return var;
	}



	cairo_surface_t * pdf_surface;
	cairo_t* cr;
	s_point *tab_points;
	int i_pts;
	int tab_size;

	void extend_tab()
	{
		s_point *tmp = malloc(2*tab_size*sizeof(s_point));
		int i;
		for(i=0;i<tab_size;i++)
			tmp[i] = tab_points[i];
		free(tab_points);
		tab_points = tmp;
	}
%}

%union {
	int entier;
	double decimal;
	s_point sp;
	char* str;
}

%type <sp> point cart pol
%type <decimal> exp

%token T_INT T_DOUBLE

%token DRAW CYCLE
%token <decimal> NB
%token <str> STR
%token EOL ENDFILE



%left '-' '+' '/' '*'

%%
in:		line in ENDFILE {printf("End of stream reached, exiting...\n"); return 0;}
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
		| var ';'
		;

points:	point 					{
									if(i_pts == tab_size)
										extend_tab();
									tab_points[i_pts] = $1;
									i_pts++;	
								}
		| points '-''-' point 	{
									if(i_pts == tab_size)
										extend_tab();
									tab_points[i_pts] = $4;
									i_pts++;
								}
		| points '-''-''+' point {
									if(i_pts == tab_size)
										extend_tab();
									tab_points[i_pts] = $5;
									tab_points[i_pts].isRelative = 1;
									i_pts++;
								}	
		| points '-''-' CYCLE	{
									if(i_pts == tab_size)
										extend_tab();
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

var: T_INT STR '=' exp			{
									printf("Create var %s\n", $2);
									table* var = addvar($2, INT);
									var->value.i_value = $4;
								}
	| T_DOUBLE STR '=' exp		{
									table* var = addvar($2, DOUBLE);
									var->value.d_value = $4;
								}
	| "point" STR '=' point 	{
									table* var = addvar($2, POINT);
									var->value.p_value = $4;
								}
	| "chemin" STR '=' points;

exp:	NB						{
									$$ = $1;
								}
		| STR 					{
									table* var = getvar($1);
									if (var->type == INT)
										$$ = var->value.i_value;
									else if (var->type == DOUBLE)
										$$ = var->value.d_value;

								}
		| '-'NB					{
									$$ = -$2;
								}
		| exp '/' exp				{
									$$ = $1/$3;
								}
		| exp '+' exp				{
									$$ = $1+$3;
								}
		| exp '*' exp				{
									$$ = $1*$3;
								}
		| exp '-' exp				{
									$$ = $1-$3;
								}
		| '('exp')'				{ $$ = $2; }
		;

%%
yyerror(char* msg){
	printf("%s\n", msg);
}

int main(int argc, char *argv[]){

	var_table = malloc(sizeof(table*));
	var_table->name = NULL;
	var_table->next = NULL;

	pdf_surface = cairo_pdf_surface_create("out.pdf", 100, 100);
	cr = cairo_create(pdf_surface);
	cairo_set_line_width (cr, 1.0);
	i_pts = 0;
	tab_size = 10;
	tab_points = malloc(10*sizeof(s_point));
	yyparse();
	cairo_destroy(cr);
	cairo_surface_destroy(pdf_surface);

	return 0;
}