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

%token TOKCONST TOKFUNC TOKFOR TOKRETURN TOKIF TOKELSE TOKPRINT

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
%token <sval> TOKIN
%token <sval> TOKNOTIN
%token <sval> TOKOR
%token <sval> TOKXOR
%token <sval> TOKNOT
%token <sval> TOKAND
%token <sval> TOKEQ
%token <sval> TOKNEQ
%token <sval> TOKLT
%token <sval> TOKGT
%token <sval> TOKLTE
%token <sval> TOKGTE

%type <sval> logic_op
%type <sval> string

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
    for_loop
    |
    if_statement
    |
    return_statement
    |
    print_statement
    ;

string:
    STRING_LIT { $$=$1; }

literal:
    string
    |
    INTEGER_LIT
    |
    FLOAT_LIT
    |
    BOOL_LIT

expression:
    literal ARITH_OP expression
    |
    IDENT ARITH_OP expression
    |
    literal ARITH_OP literal
    |
    IDENT ARITH_OP IDENT
    |
    literal ARITH_OP IDENT
    |
    IDENT ARITH_OP literal

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

for_loop:
    TOKFOR IDENT TOKIN IDENT '{' statements '}'
    {
        { printf("for loop\n"); }
    }


logic_op:
    TOKIN
    |
    TOKNOTIN
    |
    TOKOR
    |
    TOKXOR
    |
    TOKNOT
    |
    TOKAND
    |
    TOKEQ
    |
    TOKNEQ
    |
    TOKLT
    |
    TOKGT
    |
    TOKLTE
    |
    TOKGTE

comparison:
    literal logic_op comparison
    |
    IDENT logic_op comparison
    |
    literal logic_op literal
    |
    IDENT logic_op IDENT
    |
    literal logic_op IDENT
    |
    IDENT logic_op literal

if_statement:
    TOKIF comparison '{' statements '}'
    {
        printf("if statement\n");
    }
    |
    TOKIF comparison '{' statements '}' TOKELSE '{' statements '}'
    {
        printf("if else statement\n");
    }

print_statement:
    TOKPRINT '(' string ')'
    {
        printf("%s\n", $3);
    }
    |
    TOKPRINT '(' INTEGER_LIT ')'
    {
        printf("%d\n", $3);
    }
