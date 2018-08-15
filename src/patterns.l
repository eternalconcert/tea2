%{
    #include <stdio.h>
    #include "y.tab.h"
%}

%%
"="                                     return '=';
";"                                     return ';';
","                                     return ',';
"+"|"-"|"*"|"\/"                        yylval.sval=strdup(yytext); return ARITH_OP;
"{"                                     return '{';
"}"                                     return '}';
"("                                     return '(';
")"                                     return ')';
"FN"                                    return TOKFUNC;
CONST                                   return TOKCONST;
INT|FLOAT|STR|BOOL|ARRAY|VOID           yylval.sval=strdup(yytext); return TYPEIDENT;
true|false                              yylval.sval=strdup(yytext); return BOOL_LIT;
return                                  return TOKRETURN;
[A-Za-z_][A-Za-z0-9_]*                    yylval.sval=strdup(yytext); return IDENT;


\"(\\.|[^"\\])*\"                       yylval.sval=strdup(yytext); return STRING_LIT;
[+-]?[0-9]+                             yylval.ival=atoi(yytext); return INTEGER_LIT;
[+-]?[0-9]+\.[0-9]+                     yylval.fval=atof(yytext); return FLOAT_LIT;

\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
