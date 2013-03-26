%{
	#include <stdio.h>		
%}

%union {
	int entier;
	double db;
}

%token DRAW
%token NB
%token EOL ENDFILE

%%
in:		in line ENDFILE {printf("Hooooo noon c'est finiittttt \n"); return 0;}
		| 
		;

line: 	cmd EOL
		| error EOL	{printf("\nERROR\n");}
		;

cmd:	DRAW points ';'
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
	yyparse();

	return 0;
}