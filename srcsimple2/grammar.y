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

    struct {
        const char *typeName;
        char *rawValue;
    } value;
}

%token <sval> TYPEIDENT
%token <sval> ARITH_OP
%token <sval> TOKSTRING
%token <sval> TOKINTEGER
%token <sval> TOKFLOAT
%token <sval> TOKBOOL
%token <sval> IDENT

%type <value> literal
%type <value> expression
%type <value> identifier

%right '='
%left ARITH_OP

%%

program: {
        AstNode *currentHeadNode = rootNode;
    }
    statements
    ;

statements: /* empty */
        | statements statement ';'
        ;

statement:
    expression
    |
    declaration
    |
    print_statement
    ;

literal:
    TOKSTRING {
        $$.rawValue = $1;
        $$.typeName = "STR";
    }
    |
    TOKINTEGER {
        $$.rawValue = $1;
        $$.typeName = "INT";
    }
    |
    TOKFLOAT {
        $$.rawValue = $1;
        $$.typeName = "FLOAT";
    }
    |
    TOKBOOL {
        $$.rawValue = $1;
        $$.typeName = "BOOL";
    }

identifier:
    IDENT {
        $$.rawValue = $1;
        $$.typeName = "IDENT";
    }

expression:
    literal
    |
    identifier
    |
    expression ARITH_OP expression {
        nodeTypeId nodeType = getNodeTypeByName($2);
        AstNode *op = new AstNode(nodeType);
        currentHeadNode->addToChildList(op);

        AstNode *lOperand = new AstNode(getNodeTypeByName($1.typeName));
        lOperand->value = $1.rawValue;
        op->addToChildList(lOperand);

        AstNode *rOperand = new AstNode(getNodeTypeByName($3.typeName));
        rOperand->value = $3.rawValue;
        op->addToChildList(rOperand);
    }
    ;

declaration:
    TYPEIDENT identifier '=' TOKSTRING {
        declareLit($1, $2.rawValue, $4, "STR");
    }
    |
    TYPEIDENT identifier '=' TOKINTEGER {
        declareLit($1, $2.rawValue, $4, "INT");
    }
    |
    TYPEIDENT identifier '=' TOKFLOAT {
        declareLit($1, $2.rawValue, $4, "FLOAT");
    }
    |
    TYPEIDENT identifier '=' TOKBOOL {
        declareLit($1, $2.rawValue, $4, "BOOL");
    }
    |
    TYPEIDENT identifier '=' identifier {
        printf("IDENT\n");
    }

print_statement:
    TOKPRINT '(' TOKSTRING ')' {

    }
    |
    TOKPRINT '(' TOKINTEGER ')' {

    }
    |
    TOKPRINT '(' TOKFLOAT ')' {

    }
    |
    TOKPRINT '(' identifier ')' {

    }
    ;
