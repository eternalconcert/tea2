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

%token TOKCONST TOKFUNC TOKRETURN

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
    var_assignment
    |
    func_declaration
    |
    func_call
    |
    return_statement
    ;

literal:
    STRING_LIT | INTEGER_LIT | FLOAT_LIT | BOOL_LIT

expression:
    literal ARITH_OP expression { printf("Literal arith MULTI literal expression\n"); }
    |
    IDENT ARITH_OP expression { printf("Ident arith ident expression\n"); }
    |
    literal ARITH_OP literal { printf("Literal arith literal expression\n"); }
    |
    IDENT ARITH_OP IDENT { printf("Ident arith ident expression\n"); }
    |
    literal ARITH_OP IDENT { printf("Literal arith ident expression\n"); }
    |
    IDENT ARITH_OP literal { printf("Ident arith literal expression\n"); }

const_declaration:
    TOKCONST TYPEIDENT IDENT '=' literal
    {
        printf("Const assignment\n");
    }

var_declaration:
    TYPEIDENT IDENT
    {
        printf("var declaration\n");
    }

var_assignment:
    var_declaration '=' literal
    |
    var_declaration '=' IDENT
    |
    var_declaration '=' expression
    |
    var_declaration '=' func_call
    |
    IDENT '=' literal
    |
    IDENT '=' IDENT
    |
    IDENT '=' expression
    |
    IDENT '=' func_call
    {
        printf("var assignment\n");
    }

return_statement:
    TOKRETURN |
    TOKRETURN IDENT |
    TOKRETURN literal

formal_arguments_list:
    |
    TYPEIDENT IDENT |
    TYPEIDENT IDENT '=' literal |
    TYPEIDENT IDENT ',' formal_arguments_list |
    TYPEIDENT IDENT '=' literal ',' formal_arguments_list

actual_arguments_list:
    |
    IDENT
    |
    IDENT ',' actual_arguments_list
    |
    literal
    |
    literal ',' actual_arguments_list


func_declaration:
    TOKFUNC TYPEIDENT IDENT '(' formal_arguments_list ')' '{' statements '}' { printf("func declaration\n"); }

func_call:
    IDENT '(' actual_arguments_list ')' { printf("func call\n"); }

