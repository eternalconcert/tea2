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
    if (argc <= 1) {
        printf("%s\n", "No file or command specified");
        exit(1);
    }

    FILE *inFile = fopen(argv[1], "r");
    if (!inFile) {
        printf("tea: /%s: No such file or directory\n", argv[1]);
        exit(1);
    }
    yyin = inFile;

    yyparse();
}

%}

%token TOKCONST TOKFUNC TOKFOR TOKRETURN TOKIF TOKELSE OCBRACE CCBRACE TOKPRINT TOKCMD

%union
{
    int ival;
    char *sval;
    float fval;

    struct {
        const char *type;
        int integerVal;
        char *stringVal;
        float floatVal;
        char *booleanVal;
        char *identifier;
    } var;
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
%type <var> literal

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
    |
    cmd_statement
    ;

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
    STRING_LIT
    {
        std::string res = std::string($1);
        res = cleanStrLit(res);

        char *stripped = new char[res.size() + 1];
        std::copy(res.begin(), res.end(), stripped);
        stripped[res.size()] = '\0';

        $$.stringVal = stripped;
        $$.type = "STR";
    }
    |
    INTEGER_LIT
    {
        $$.integerVal = $1;
        $$.type = "INT";
    }
    |
    FLOAT_LIT
    {
        $$.floatVal = $1;
        $$.type = "FLOAT";
    }
    |
    BOOL_LIT
    {
        $$.booleanVal = $1;
        $$.type = "BOOL";
    }
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
    TOKCONST TYPEIDENT IDENT '=' literal
    {
        TYPE_ID id = getTypeIdByName($2);
        switch(id) {
            case INT:
                addConstant(std::string($3), INT, $5.integerVal, 0, NULL, NULL);
                break;

            case FLOAT:
                addConstant(std::string($3), FLOAT, 0, $5.floatVal, NULL, NULL);
                break;

            case STR:
                addConstant(std::string($3), STR, 0, 0, $5.stringVal, NULL);
                break;

            case BOOL:
                addConstant(std::string($3), BOOL, 0, 0, NULL, $5.booleanVal);
                break;
            };
        };


var_declaration:
    TYPEIDENT IDENT
    {
        makeEmptyVariable($2, getTypeIdByName($1));
    }
    ;

var_assignment:
    TYPEIDENT IDENT '=' literal
    {
        std::string typeName = std::string($4.type);
        if (strcmp($4.type, $1)) {
            throw RuntimeError("Type mismatch: Cannot assign " + typeName + " to variable of type " + $1);
        };
        TYPE_ID typeId = getTypeIdByName($1);
        addVariable($2, typeId, $4.integerVal, $4.floatVal, $4.stringVal, $4.booleanVal, NULL);
    }
    |
    TYPEIDENT IDENT '=' IDENT
    {
        addVariable($2, IDENTIFIER, 0, 0, NULL, NULL, $4);
    };
    |

    TYPEIDENT IDENT '=' array_lit
    {
        printf("Array assignment not yet implemented: %s\n", $2);
    }
    |
    TYPEIDENT IDENT '=' expression
    |
    TYPEIDENT IDENT '=' func_call
    |

    IDENT '=' INTEGER_LIT
    {
        updateVariable($1, INT, $3, 0, NULL, NULL, NULL);
    }
    |
    IDENT '=' FLOAT_LIT
    {
        updateVariable($1, FLOAT, 0, $3, NULL, NULL, NULL);
    };
    |
    IDENT '=' STRING_LIT
    {
        std::string res = std::string($3);
        res = cleanStrLit(res);

        char *stripped = new char[res.size() + 1];
        std::copy(res.begin(), res.end(), stripped);
        stripped[res.size()] = '\0';

        updateVariable($1, STR, 0, 0, stripped, NULL, NULL);
    };
    |
    IDENT '=' BOOL_LIT
    {
        updateVariable($1, BOOL, 0, 0, NULL, $3, NULL);
    };

    |
    IDENT '=' IDENT
    {
        updateVariable($1, IDENTIFIER, 0, 0, NULL, NULL, $3);
    };
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
    TOKPRINT '(' STRING_LIT ')'
    {
        std::string lit = cleanStrLit(std::string($3));
        printf("%s\n", lit.c_str());
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
    TOKPRINT '(' BOOL_LIT ')'
    {
        printf("%s\n", $3);
    }
    |
    TOKPRINT '(' IDENT ')'
    {
        std::string ident = std::string($3);
        ValueStore item = getFromValueStore(ident);
        item.repr();
    }
    ;

cmd_statement:
    TOKCMD '(' STRING_LIT ')'
    {
        std::string command = std::string($3);
        command = cleanStrLit(command);
        std::system(command.c_str());
    }
    |
    TOKCMD '(' IDENT ')'
    {
        std::string ident = std::string($3);
        ValueStore item = getFromValueStore(ident);
        std::system(item.string_value);
    }

