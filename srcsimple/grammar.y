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

    runProgram();
}

%}

%token TOKPRINT

%union
{
    int ival;
    char *sval;
    float fval;
}

%token <sval> TYPEIDENT
%token <sval> IDENT
%token <sval> ARITH_OP
%token <sval> TOKSTRING
%token <sval> TOKINTEGER
%token <sval> TOKFLOAT
%token <sval> TOKBOOL

%%

program: {
        AstNode *currentHeadNode = rootNode;
    }
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
    declaration
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
    IDENT
    |
    TOKINTEGER ARITH_OP TOKINTEGER {
        nodeTypeId nodeType = getNodeTypeByName($2);
        AstNode *op = new AstNode(nodeType);
        currentHeadNode->addToChildList(op);

        AstNode *lOperand = new AstNode(INT);
        lOperand->value = $1;
        op->addToChildList(lOperand);

        AstNode *rOperand = new AstNode(INT);
        rOperand->value = $3;
        op->addToChildList(rOperand);
    }
    ;

declaration:
    TYPEIDENT IDENT '=' TOKSTRING {
        declareLit($1, $2, $4, "STR");
    }
    |
    TYPEIDENT IDENT '=' TOKINTEGER {
        declareLit($1, $2, $4, "INT");
    }
    |
    TYPEIDENT IDENT '=' TOKFLOAT {
        declareLit($1, $2, $4, "FLOAT");
    }
    |
    TYPEIDENT IDENT '=' TOKBOOL {
        declareLit($1, $2, $4, "BOOL");
    }
    |
    TYPEIDENT IDENT '=' IDENT {
        printf("IDENT\n");
    }

print_statement:
    TOKPRINT '(' TOKSTRING ')' {
        printf("%s\n", $3);
    }
    |
    TOKPRINT '(' TOKINTEGER ')' {
        printf("%s\n", $3);
    }
    |
    TOKPRINT '(' TOKFLOAT ')' {
        printf("%s\n", $3);
    }
    |
    TOKPRINT '(' IDENT ')' {
        printf("PRINT IDENT\n");
    }
    ;
