%{
    #include <stdio.h>
    #include "y.tab.h"
%}

%%
CONST                                   return TOKCONST;
INT|STR|BOOL|ARRAY|VOID                 yylval.string=strdup(yytext); return TOKTYPEIDENT;
[0-9]+                                  yylval.number=atoi(yytext); return NUMBER;
heat                                    return TOKHEAT;
on|off                                  yylval.number=!strcmp(yytext, "on"); return STATE;
target                                  return TOKTARGET;
temperature                             return TOKTEMPERATURE;
\n                                      /* ignore EOL */;
[ \t]+                                  /* ingnore whitespace */;
