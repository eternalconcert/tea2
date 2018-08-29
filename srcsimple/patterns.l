%{
    #include <stdio.h>
    #include "y.tab.h"
%}
%option yylineno

%%
"#".*                                   /* ignore comments */;
"="                                     return '=';
";"                                     return ';';
CONST                                   return TOKCONST;
INT|FLOAT|STR|BOOL|ARRAY|VOID           yylval.sval=strdup(yytext); return TYPEIDENT;
true|false                              yylval.sval=strdup(yytext); return TOKBOOL;
print                                   return TOKPRINT;
[A-Za-z_][A-Za-z0-9_]*                  yylval.sval=strdup(yytext); return IDENT;
"("                                     return '(';
")"                                     return ')';

\"(\\.|[^"\\])*\"                       yylval.sval=strdup(yytext); return TOKSTRING;
[+-]?[0-9]+                             yylval.ival=atoi(yytext); return TOKINTEGER;
[+-]?[0-9]+\.[0-9]+                     yylval.fval=atof(yytext); return TOKFLOAT;
\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
