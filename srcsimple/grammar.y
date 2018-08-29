%{
    #include <stdio.h>
    #include <string.h>

    #include "ast.cpp"

    extern FILE *yyin;
    extern int yylineno;
    extern char *yytext;
    extern "C" {
        int yyparse(void);
        int yylex(void);

        int yywrap() {
            return 1;
        }
    }

    void yyerror(const char *str) {
        fprintf(stderr, "Error: %s: %s on line %d\n", str, yytext, yylineno);
    }


main(int argc, char *argv[0]) {

    FILE *inFile = fopen(argv[1], "r");
    if (!inFile) {
        printf("No file named %s found\n", argv[1]);
        return -1;
    }
    yyin = inFile;

    yyparse();
}

%}

%token TOKCONST TOKPRINT

%union
{
    int ival;
    char *sval;
    float fval;
}

%token <sval> TYPEIDENT
%token <sval> IDENT
%token <sval> TOKSTRING
%token <ival> TOKINTEGER
%token <fval> TOKFLOAT
%token <sval> TOKBOOL

%%

program:
    items
    ;

items: /* empty */
        | items item ';'
        ;

item:
    statement
    |
    expression

statement:
    const_declaration
    |
    print_statement
    ;

expression:
    TOKSTRING
    |
    TOKINTEGER
    |
    TOKFLOAT
    |
    TOKBOOL
    |
    IDENT {printf("TESTSTST\n");}
    ;

const_declaration:
    TOKCONST TYPEIDENT IDENT '=' TOKSTRING
    {
        printf("CONST STRING\n");
    }
    |
    TOKCONST TYPEIDENT IDENT '=' TOKINTEGER
    {
        printf("CONST INTEGER\n");
    }
    |
    TOKCONST TYPEIDENT IDENT '=' TOKFLOAT
    {
        printf("CONST FLOAT\n");
    }
    |
    TOKCONST TYPEIDENT IDENT '=' TOKBOOL
    {
        printf("CONST BOOL\n");
    }
    |
    TOKCONST TYPEIDENT IDENT '=' IDENT
    {
        printf("CONST IDENT\n");
    }

print_statement:
    TOKPRINT '(' TOKSTRING ')'
    {
        printf("%s\n", $3);
    }
    |
    TOKPRINT '(' TOKINTEGER ')'
    {
        printf("%d\n", $3);
    }
    |
    TOKPRINT '(' TOKFLOAT ')'
    {
        printf("%f\n", $3);
    }
    |
    TOKPRINT '(' IDENT ')'
    {
        std::string ident = std::string($3);
        printf("PRINT IDENT");
    }
    ;
