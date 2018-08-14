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

%token TOKCONST TOKVAR TOKHEAT TOKTARGET TOKTEMPERATURE

%union
{
    int ival;
    char *sval;
    float fval;
}

%token <sval> TYPEIDENT
%token <sval> IDENT
%token <ival> STATE
%token <sval> STRING_LIT
%token <ival> INTEGER_LIT
%token <fval> FLOAT_LIT
%token <sval> BOOL_LIT
%token <sval> ARITH_OP

%%

program: statements
statements: /* empty */
        | statements statement ';'
        ;

statement:
    expression
    |
    const_declaration
    |
    var_declaration
    |
    var_assignment_literal
    |
    var_assignment_ident
    |
    var_declaration_assignment
    |
    heat_switch
    |
    target_set
    |
    identifier
    |
    typeidentifier
    ;


literal:
    STRING_LIT | INTEGER_LIT | FLOAT_LIT | BOOL_LIT

expression:
    literal ARITH_OP literal
    {
        printf("Expression\n");
    }

const_declaration:
    TOKCONST TYPEIDENT IDENT '=' literal
    {
        printf("Const assignment\n");
    }

var_declaration_assignment:
    TOKVAR TYPEIDENT IDENT '=' literal
    {
        printf("var declaration assignment\n");
    }

var_declaration:
    TOKVAR TYPEIDENT IDENT
    {
        printf("var declaration\n");
    }

var_assignment_literal:
    IDENT '=' literal
    {
        printf("var assignment literal\n");
    }

var_assignment_ident:
    IDENT '=' IDENT
    {
        printf("var assignment ident\n");
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
