%{
	#include "y.tab.h"
%}

%%

[[:digit:]]+ {yylval.entier = atoi(yytext); return NB;}

"draw"|"fill" return DRAW;


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