%{
	typedef struct {
		int x;
		int y;
		int isRelative;
	}s_point;
	#include "y.tab.h"
%}

%%

[[:digit:]]+ {yylval.decimal = atof(yytext); return NB;}
[[:digit:]]+\.[[:digit:]]+ {printf("Add val %f\n", atof(yytext)); yylval.decimal = atof(yytext); return NB;}

"draw"|"fill" return DRAW;
"cycle"	return CYCLE;


"+" return '+';
"*" return '*';
"-" return '-';
"/" return '/';
"(" return '(';
")" return ')';
":" return ':';
"," return ',';
";" return ';';
\n return EOL;

" " {}

<<EOF>> return ENDFILE;

. {yyerror("Illegal char"); return yytext[0];}



%%
