%{
    #include <stdio.h>
    #include <string.h>

    #include "src/valuestore.cpp"

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

%token TOKCONST TOKFUNC TOKFOR TOKRETURN TOKIF TOKELSE OCBRACE CCBRACE TOKPRINT

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

program:
    statements

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
    TYPEIDENT IDENT
    {
        makeEmptyVariable(getScopeHead(), $2, getTypeIdByName($1));
    }
    ;

var_assignment:
    TYPEIDENT IDENT '=' INTEGER_LIT
    {
        addVariable(getScopeHead(), $2, INT, $4, 0, NULL, NULL);
    }
    |
    TYPEIDENT IDENT '=' FLOAT_LIT
    {
        addVariable(getScopeHead(), $2, FLOAT, 0, $4, NULL, NULL);
    };
    |
    TYPEIDENT IDENT '=' STRING_LIT
    {
        addVariable(getScopeHead(), $2, STR, 0, 0, $4, NULL);
    };
    |
    TYPEIDENT IDENT '=' BOOL_LIT
    {
        addVariable(getScopeHead(), $2, BOOL, 0, 0, NULL, $4);
    };
    |
    TYPEIDENT IDENT '=' IDENT
    {
        addVariable(getScopeHead(), $2, IDENTIFIER, 0, 0, NULL, $4);
    };
    |

    TYPEIDENT IDENT '=' array_lit
    |
    TYPEIDENT IDENT '=' expression
    |
    TYPEIDENT IDENT '=' func_call
    |

    IDENT '=' INTEGER_LIT
    {
        updateVariable(getScopeHead(), $1, INT, $3, 0, NULL, NULL);
    }
    |
    IDENT '=' FLOAT_LIT
    {
        updateVariable(getScopeHead(), $1, FLOAT, 0, $3, NULL, NULL);
    };
    |
    IDENT '=' STRING_LIT
    {
        updateVariable(getScopeHead(), $1, STR, 0, 0, $3, NULL);
    };
    |
    IDENT '=' BOOL_LIT
    {
        updateVariable(getScopeHead(), $1, BOOL, 0, 0, NULL, $3);
    };

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

ccbrace:
    OCBRACE
    {
        pushScope();
    };

ocbrace:
    CCBRACE
    {
        popScope();
    };

func_declaration:
    TOKFUNC TYPEIDENT IDENT '(' formal_arguments_list ')' ccbrace statements ocbrace
    ;

func_call:
    IDENT '(' actual_arguments_list ')';

for_loop:
    TOKFOR IDENT TOKIN IDENT OCBRACE statements CCBRACE;

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
    TOKIF comparison OCBRACE statements CCBRACE
    |
    TOKIF comparison OCBRACE statements CCBRACE TOKELSE OCBRACE statements CCBRACE
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
    TOKPRINT '(' FLOAT_LIT ')'
    {
        printf("%f\n", $3);
    }
    |
    TOKPRINT '(' IDENT ')'
    {
        std::string ident = std::string($3);
        ValueStore item = getFromValueStore(ident);
        item.repr();
    }
    ;
