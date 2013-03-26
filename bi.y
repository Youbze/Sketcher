%{
	#include <stdio.h>		
%}

%union {
	int entier;
	double db;
}

%token NB
%token EOL

%%
in:		line in
		| 
		;

line: 	cmd EOL
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
	yyparse();

	return 0;
}