%{
    #include <stdio.h>
    #include <string.h>

    extern FILE *yyin;
    extern "C" {
        int yyparse(void);
        int yylex(void);

        int yywrap() {
            return 1;
        }
    }


    void yyerror(const char *str) {
        fprintf(stderr, "Error: %s\n", str);
    }


main(int argc, char *argv[0]) {

    FILE *inFile = fopen(argv[1], "r");
    if (!inFile) {
        return -1;
    }
    yyin = inFile;

    yyparse();
}

%}

%token TOKCONST TOKHEAT TOKTARGET TOKTEMPERATURE

%union
{
    int ival;
    char *sval;
    float fval;
}

%token <sval> TYPEIDENT
%token <sval> IDENT
%token <sval> STRING_LIT
%token <sval> ASSIGNMENT_OP
%token <ival> STATE
%token <ival> INTEGER_LIT
%token <fval> FLOAT_LIT
%token <sval> BOOL_LIT


%%
program: statements
statements: /* empty */
        | statements statement ';'
        ;

statement:
    const_assignment
    |
    heat_switch
    |
    target_set
    |
    const_declaration
    |
    identifier
    |
    typeidentifier
    ;

const_assignment:
    TOKCONST TYPEIDENT IDENT '=' INTEGER_LIT
    {
        printf("Const assignment %d\n", $5);
    }

heat_switch:
    TOKHEAT STATE
    {
        if ($2) {
            printf("Heat turned on\n");
        }
        else {
            printf("Heat turned off\n");
        }
    }

target_set:
    TOKTARGET TOKTEMPERATURE INTEGER_LIT
    {
        printf("Temperature set to %d\n", $3);
    }

const_declaration:
    TOKCONST TYPEIDENT
    {
        printf("CONST Identifier: %s\n", $2);
    }

identifier:
    IDENT
    {
        printf("Identifier: %s\n", $1);
    }

typeidentifier:
    TYPEIDENT
    {
        printf("Typeident: %s\n", $1);
    }
