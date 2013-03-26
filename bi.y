%{
	#include <stdio.h>		
	#include <cairo.h>
	#include <cairo-pdf.h>
	cairo_surface_t * pdf_surface;
	cairo_t* cr;
%}

%union {
	int entier;
	double db;
}

%token DRAW
%token NB
%token EOL EOF

%%
in:		in line
		| 
		| EOF	{}
		;

line: 	cmd EOL	{cairo_stroke(cr);}
		| error EOL	{printf("\nERROR\n");}
		;

cmd:	'D' points ';'
		;

points:	point
		| points '-''-' point
		;

point:	cart
		| pol
		;

cart:	'('exp','exp')'
		;

pol:	'('exp':'exp')'
		;

exp:	NB
		| '('NB'+'NB')'
		| '('NB'-'NB')'
		| '('NB'*'NB')'
		| '('NB'/'NB')'
		;

%%
yyerror(char* msg){
	printf("%s\n", msg);
}

int main(int argc, char *argv[]){
	pdf_surface = cairo_pdf_surface_create("out.pdf", 100, 100);
	cr = cairo_create(pdf_surface);

	yyparse();
	cairo_destroy(cr);
	cairo_surface_destroy(pdf_surface);

	return 0;
}