%{
	#include "y.tab.h"
%}

%%

[[:digit:]]+ {yylval.entier = atoi(yytext); return NB;}
"D" return 'D';
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

. {yyerror("Illegal char"); return yytext[0];}



%%