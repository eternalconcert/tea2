%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "src/ast/ast.h"
    #include "y.tab.h"
    std::string strbuf;


//\"(\\.|[^"\\])*\"                       yylval.sval = (char*)calloc(strlen(yytext)-1, sizeof(char));strncpy(yylval.sval, &yytext[1], strlen(yytext)-2);return TOKSTRING; // Simple string.
// <string>\\[0-7]*                       { strbuf += strtol(yytext+1, 0, 8); } // No idea..
%}
%option yylineno
%option noyywrap
%x string
%x multiLineComment
%%
"//".*|"#!".*                            /* ignore comments */;
"/*"                                    { BEGIN multiLineComment; }
<multiLineComment>[^*\n]+
<multiLineComment>\n
<multiLineComment>"*/"                  { BEGIN 0; }
"="                                     return '=';
";"                                     return ';';
","                                     return ',';
"+"                                     yylval.sval=strdup(yytext); return TOKPLUS;
"-"                                     yylval.sval=strdup(yytext); return TOKMINUS;
"*"                                     yylval.sval=strdup(yytext); return TOKTIMES;
"\/"                                    yylval.sval=strdup(yytext); return TOKDIVIDE;
"%"                                     yylval.sval=strdup(yytext); return TOKMOD;
"=="                                    yylval.sval=strdup(yytext); return TOKEQUAL;
"!="                                    yylval.sval=strdup(yytext); return TOKNEQUAL;
">"                                     yylval.sval=strdup(yytext); return TOKGT;
">="                                    yylval.sval=strdup(yytext); return TOKGTE;
"<"                                     yylval.sval=strdup(yytext); return TOKLT;
"<="                                    yylval.sval=strdup(yytext); return TOKLTE;
"and"|"&&"|"&"                          yylval.sval=strdup(yytext); return TOKAND;
"or"|"||"|"|"                           yylval.sval=strdup(yytext); return TOKOR;
int                                     yylval.tval=INT; return TYPEIDENT;
float                                   yylval.tval=FLOAT; return TYPEIDENT;
str                                     yylval.tval=STR; return TYPEIDENT;
bool                                    yylval.tval=BOOL; return TYPEIDENT;
void                                    yylval.tval=VOID; return TYPEIDENT;
if                                      return TOKIF;
else                                    return TOKELSE;
true                                    yylval.bval=true; return TOKBOOL;
false                                   yylval.bval=false; return TOKBOOL;
fn                                      return TOKFN;
return                                  return TOKRETURN;
while                                   return TOKWHILE;
print                                   return TOKPRINT;
read                                    return TOKREADFILE;
quit                                    return TOKQUIT;
assert                                  return TOKASSERT;
cmd                                     return TOKCMD;
SYSARGS                                 return TOKSYSARGS;
LRC                                     return TOKLRC;
"("                                     return '(';
")"                                     return ')';
"["                                     return '[';
"]"                                     return ']';
"{"                                     return TOKLBRACE;
"}"                                     return TOKRBRACE;
[A-Za-z_][A-Za-z0-9_]*                  yylval.sval=strdup(yytext); return TOKIDENT;

\"                                      { BEGIN string; strbuf = ""; }
<string>[^\\"\n]*                       { strbuf += yytext; }
<string>\\n                             { strbuf += '\n'; }
<string>\\t                             { strbuf += '\t'; }
<string>\\[\\"]                         { strbuf += yytext[1]; }
<string>\n                              { strbuf += '\n'; }
<string>\"                              { yylval.sval = strdup(strbuf.c_str()); BEGIN 0; return TOKSTRING; }
[+-]?[0-9]+                             yylval.ival=atoi(yytext); return TOKINTEGER;
[+-]?[0-9]+\.[0-9]+                     yylval.fval=atof(yytext); return TOKFLOAT;
\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
