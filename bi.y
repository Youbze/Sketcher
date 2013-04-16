%{
	#include <stdlib.h>
	#include <stdio.h>		
	#include <math.h>
	#include <cairo.h>
	#include <cairo-pdf.h>
	#include <string.h>
	#include <assert.h>

	#define DOUBLE 	1
	#define INT 	2
	#define POINT 	3
	#define PATH 	4

	typedef struct {
		double x;
		double y;
		int isRelative;
	}s_point;

	/*
	* Table contenant les variables crees par l'utilisateur
	*/

	struct s_table{
		char *name;
		int type;
		union {
			double d_value;
			int i_value;
			s_point p_value;
			s_point* c_value;
		} value;
		struct s_table *next;
	};

	typedef struct s_table table;

	table *var_table = NULL;

	table *getvar(char* name){
		
		table *iter = var_table;
		
		while(iter != NULL){
			if (strcmp(iter->name, name) == 0){
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
		var->name = malloc((strlen(name) + 1)*sizeof(char));
		strcpy(var->name,name);


		var->next = (table*) var_table;

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

	freee()
	{
		table *iter = var_table;
		table *tmp;
		while(iter != NULL){
			if (iter->type == PATH)
				free(iter->value.c_value);
			tmp = iter;
			iter = (table*) iter->next;
			free(tmp);
		}
		free(tab_points);
		free(var_table);
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

%token T_INT T_DOUBLE T_POINT T_PATH

%token DRAW CYCLE
%token <decimal> NB
%token <str> STR
%token EOL ENDFILE

%token SEPARATOR SEPARATOR2

%left '-' '+' '/' '*' SEPARATOR SEPARATOR2

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
									tab_points[i_pts].isRelative = 0;
									i_pts++;	
								}
		| points SEPARATOR point 	{
									if(i_pts == tab_size)
										extend_tab();
									tab_points[i_pts] = $3;
									tab_points[i_pts].isRelative = 0;
									i_pts++;
								}
		| points SEPARATOR2 point {
									if(i_pts == tab_size)
										extend_tab();
									tab_points[i_pts] = $3;
									tab_points[i_pts].isRelative = 1;
									i_pts++;
								}					
		;

point:	cart 					{
									$$ = $1;
								}
		| pol					{
									$$ = $1;
								}
		| CYCLE					{
									$$ = tab_points[0];
								}
		| STR					{
									table* var = getvar($1);
									if (var->type == POINT)
										$$ = var->value.p_value;
								}
		;

cart:	'('exp','exp')'			{
									printf("Point(%f,%f)\n", $2, $4);
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
									table* var = addvar($2, INT);
									var->value.i_value = $4;
								}
	| T_DOUBLE STR '=' exp		{
									table* var = addvar($2, DOUBLE);
									var->value.d_value = $4;
								}
	| T_POINT STR '=' point 	{
									table* var = addvar($2, POINT);
									var->value.p_value = $4;
								}
	| T_PATH STR '=' points		{
									table* var = addvar($2, PATH);
									s_point *tmp = malloc(i_pts*sizeof(s_point));
									int i;
									for(i=0;i<i_pts;i++)
										tmp[i] = tab_points[i];
									var->value.c_value = tmp;
								}
	;

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

	pdf_surface = cairo_pdf_surface_create("out.pdf", 100, 100);
	cr = cairo_create(pdf_surface);
	cairo_set_line_width (cr, 1.0);
	i_pts = 0;
	tab_size = 10;
	tab_points = malloc(10*sizeof(s_point));
	yyparse();
	cairo_destroy(cr);
	cairo_surface_destroy(pdf_surface);
	freee();
	return 0;
}
