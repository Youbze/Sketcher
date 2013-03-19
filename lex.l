%{
#include "const.h"
#include "bi.tab.h"
%}

%%

[[:digit:]] {/*yylval.entier = atoi(yytext);*/ return NB;}
"+" return '+';
"*" return '*';
"-" return '-';
"/" return '/';
"(" return '(';
")" return ')';
":" return ':';
"," return ',';




%%