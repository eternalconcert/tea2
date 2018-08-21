%{
    #include <stdio.h>
    #include <string.h>

    #include "src/tea.h"

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
    |
    literal
    |
    IDENT
    |
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
    return
    |
    print_statement
    ;

string:
    STRING_LIT { $$=$1; }

list_elems:
    |
    IDENT
    |
    literal
    |
    IDENT ',' list_elems
    |
    literal ',' list_elems
    ;

array_lit:
    '[' list_elems ']'

literal:
    string
    |
    INTEGER_LIT
    |
    FLOAT_LIT
    |
    BOOL_LIT
    |
    array_lit
    ;

expression:
    expression ARITH_OP literal
    |
    expression ARITH_OP IDENT
    |
    literal ARITH_OP literal
    |
    IDENT ARITH_OP IDENT
    |
    literal ARITH_OP IDENT
    |
    IDENT ARITH_OP literal
    ;

const_declaration:
    TOKCONST TYPEIDENT IDENT '=' INTEGER_LIT
    {
        addConstant(std::string($3), INT, $5, 0, NULL, NULL);
    };
    |
    TOKCONST TYPEIDENT IDENT '=' FLOAT_LIT
    {
        addConstant(std::string($3), FLOAT, 0, $5, NULL, NULL);
    };
    |
    TOKCONST TYPEIDENT IDENT '=' string
    {
        addConstant(std::string($3), STR, 0, 0, $5, NULL);
    };
    |
    TOKCONST TYPEIDENT IDENT '=' BOOL_LIT
    {
        addConstant(std::string($3), BOOL, 0, 0, NULL, $5);
    };

var_declaration:
    TYPEIDENT IDENT;

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
    ;

return:
    TOKRETURN |
    TOKRETURN IDENT |
    TOKRETURN literal
    ;

formal_arguments_list:
    |
    TYPEIDENT IDENT |
    TYPEIDENT IDENT '=' literal |
    TYPEIDENT IDENT ',' formal_arguments_list |
    TYPEIDENT IDENT '=' literal ',' formal_arguments_list
    ;

actual_arguments_list:
    |
    IDENT
    |
    IDENT ',' actual_arguments_list
    |
    literal
    |
    literal ',' actual_arguments_list
    ;

func_declaration:
    TOKFUNC TYPEIDENT IDENT '(' formal_arguments_list ')' '{' statements '}';

func_call:
    IDENT '(' actual_arguments_list ')';

for_loop:
    TOKFOR IDENT TOKIN IDENT '{' statements '}';

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
    ;

comparison:
    comparison logic_op literal
    |
    comparison logic_op IDENT
    |
    literal logic_op literal
    |
    IDENT logic_op IDENT
    |
    literal logic_op IDENT
    |
    IDENT logic_op literal
    ;

if_statement:
    TOKIF comparison '{' statements '}'
    |
    TOKIF comparison '{' statements '}' TOKELSE '{' statements '}'
    ;

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
    |
    TOKPRINT '(' IDENT ')'
    {
        Constant constant = constants[std::string($3)];
        if (constant.type == INT) {
            printf("%d\n", constant.int_value);
        }
        if (constant.type == FLOAT) {
            printf("%d\n", constant.float_value);
        }
        if (constant.type == STR) {
            printf("%s\n", constant.string_value);
        }
        if (constant.type == BOOL) {
            printf("%d\n", constant.bool_value);
        }
    }
    ;
