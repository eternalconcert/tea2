%{
    #include <stdio.h>
    #include "y.tab.h"
%}

%%
CONST                                   return TOKCONST;
VAR                                     return TOKVAR;
INT|FLOAT|STR|BOOL|ARRAY|VOID           yylval.sval=strdup(yytext); return TYPEIDENT;
true|false                              yylval.sval=strdup(yytext); return BOOL_LIT;
[A-Za-z][A-Za-z0-9]*                    yylval.sval=strdup(yytext); return IDENT;
"="                                     return '=';
";"                                     return ';';
\"(\\.|[^"\\])*\"                       yylval.sval=strdup(yytext); return STRING_LIT;
[+-]?[0-9]+                             yylval.ival=atoi(yytext); return INTEGER_LIT;
[+-]?[0-9]+\.[0-9]+                     yylval.fval=atof(yytext); return FLOAT_LIT;

\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
