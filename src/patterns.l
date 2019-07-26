%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "src/ast.h"
    #include "y.tab.h"
%}
%option yylineno

%%
"#".*                                   /* ignore comments TODO: Think about enforcing a blank after the # */;
"="                                     return '=';
";"                                     return ';';
","                                     return ',';
"+"                                     return TOKPLUS;
"-"                                     return TOKMINUS;
"*"                                     return TOKTIMES;
"\/"                                    return TOKDIVIDE;
CONST                                   return TOKCONST;
INT                                     yylval.tval=INT; return TYPEIDENT;
FLOAT                                   yylval.tval=FLOAT; return TYPEIDENT;
STR                                     yylval.tval=STR; return TYPEIDENT;
BOOL                                    yylval.tval=BOOL; return TYPEIDENT;
VOID                                    yylval.tval=VOID; return TYPEIDENT;
true                                    yylval.bval=true; return TOKBOOL;
false                                   yylval.bval=false; return TOKBOOL;
print                                   return TOKPRINT;
"("                                     return '(';
")"                                     return ')';
[A-Za-z_][A-Za-z0-9_]*                  yylval.sval=strdup(yytext); return IDENT;
\"(\\.|[^"\\])*\"                       yylval.sval = (char*)calloc(strlen(yytext)-1, sizeof(char));strncpy(yylval.sval, &yytext[1], strlen(yytext)-2);return TOKSTRING;
[+-]?[0-9]+                             yylval.ival=atoi(yytext); return TOKINTEGER;
[+-]?[0-9]+\.[0-9]+                     yylval.fval=atof(yytext); return TOKFLOAT;
\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
