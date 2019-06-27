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
        int yy_scan_string(const char* instream);

        int yywrap() {
            return 1;
        }
    }

    void yyerror(const char *str) {
        fprintf(stderr, "Error: %s: %s on line %d\n", str, yytext, yylineno);
        exit(1);
    }


main(int argc, char *argv[0]) {
    if (argc <= 1) {
        printf("%s\n", "No file or command specified");
        exit(1);
    }
    else if (argc == 2) {
        FILE *inFile = fopen(argv[1], "r");
        if (!inFile) {
            printf("tea: /%s: No such file or directory\n", argv[1]);
            exit(1);
        }
        yyin = inFile;
    }

    else if (argc >= 3 and !strcmp(argv[1], "-c")) {
        yy_scan_string(argv[2]);
    }

    else {
        printf("tea: Problem during startup\n");
        exit(1);
    }

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

%type <sval> literal

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

literal:
    TOKSTRING
    |
    TOKINTEGER
    |
    TOKFLOAT
    |
    TOKBOOL

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
    literal ARITH_OP literal {
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
