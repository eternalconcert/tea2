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
%token <ival> STATE
%token <ival> INTEGER_LIT
%token <fval> FLOAT_LIT
%token <sval> BOOL_LIT


%%

statements: /* empty */
        | statements statement
        ;

statement:
    heat_switch
    |
    target_set
    |
    const_declaration
    |
    identifier
    |
    typeidentifier
    |
    string
    |
    integer
    |
    float
    |
    bool
    ;

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

string:
    STRING_LIT
    {
        printf("String: %s\n", $1);
    }

integer:
    INTEGER_LIT
    {
        printf("Integer: %d\n", $1);
    }

float:
    FLOAT_LIT
    {
        printf("Float: %.2f\n", $1);
    }

bool:
    BOOL_LIT
    {
        printf("Boolean: %s\n", $1);
    }
