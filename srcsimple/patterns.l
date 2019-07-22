%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "ast.h"
    #include "y.tab.h"
%}
%option yylineno

%%
"#".*                                   /* ignore comments */;
"="                                     return '=';
";"                                     return ';';
","                                     return ',';
"+"                                     return PLUS;
"-"                                     return MINUS;
"*"                                     return TIMES;
"\/"                                    return DIVIDE;
INT|FLOAT|STR|BOOL|VOID                 yylval.sval=strdup(yytext); return TYPEIDENT;
true|false                              yylval.sval=strdup(yytext); return TOKBOOL;
print                                   return TOKPRINT;
"("                                     return '(';
")"                                     return ')';
[A-Za-z_][A-Za-z0-9_]*                  yylval.sval=strdup(yytext); return IDENT;
\"(\\.|[^"\\])*\"                       yylval.sval = (char*)calloc(strlen(yytext)-1, sizeof(char));strncpy(yylval.sval, &yytext[1], strlen(yytext)-2);return TOKSTRING;
[+-]?[0-9]+                             yylval.sval=strdup(yytext); return TOKINTEGER;
[+-]?[0-9]+\.[0-9]+                     yylval.sval=strdup(yytext); return TOKFLOAT;
\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
