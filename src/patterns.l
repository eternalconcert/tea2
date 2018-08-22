%{
    #include <stdio.h>
    #include "y.tab.h"
%}
%option yylineno

%%
"#".*                                   /* ignore comments */;
"="                                     return '=';
";"                                     return ';';
","                                     return ',';
"+"|"-"|"*"|"\/"                        yylval.sval=strdup(yytext); return ARITH_OP;
"{"                                     return OCBRACE;
"}"                                     return CCBRACE;
"["                                     return '[';
"]"                                     return ']';
"("                                     return '(';
")"                                     return ')';
"FN"                                    return TOKFUNC;
CONST                                   return TOKCONST;
INT|FLOAT|STR|BOOL|ARRAY|VOID           yylval.sval=strdup(yytext); return TYPEIDENT;
true|false                              yylval.sval=strdup(yytext); return BOOL_LIT;
if                                      return TOKIF;
else                                    return TOKELSE;
"=="                                    yylval.sval=strdup(yytext); return TOKEQ;
"!="                                    yylval.sval=strdup(yytext); return TOKNEQ;
"<"                                     yylval.sval=strdup(yytext); return TOKLT;
">"                                     yylval.sval=strdup(yytext); return TOKGT;
"<="                                    yylval.sval=strdup(yytext); return TOKLTE;
">="                                    yylval.sval=strdup(yytext); return TOKGTE;
"or"                                    yylval.sval=strdup(yytext); return TOKOR;
"xor"                                   yylval.sval=strdup(yytext); return TOKXOR;
"not"                                   yylval.sval=strdup(yytext); return TOKNOT;
"and"                                   yylval.sval=strdup(yytext); return TOKAND;
"in"                                    yylval.sval=strdup(yytext); return TOKIN;
"not in"                                yylval.sval=strdup(yytext); return TOKNOTIN;
for                                     return TOKFOR;
return                                  return TOKRETURN;
print                                   return TOKPRINT;
[A-Za-z_][A-Za-z0-9_]*                  yylval.sval=strdup(yytext); return IDENT;

\"(\\.|[^"\\])*\"                       yylval.sval=strdup(yytext); return STRING_LIT;
[+-]?[0-9]+                             yylval.ival=atoi(yytext); return INTEGER_LIT;
[+-]?[0-9]+\.[0-9]+                     yylval.fval=atof(yytext); return FLOAT_LIT;
\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
