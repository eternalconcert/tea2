%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "ast.h"
    #include "exceptions.h"
    #include <string.h>

    RootNode *root;

    extern FILE *yyin;
    extern int yylineno;
    extern char *yytext;
        int yyparse(void);
        int yylex(void);
        int yy_scan_string(const char* instream);

        int yywrap() {
            return 1;
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

    root->run();
}



%}

%union
{
    char *sval;
    AstNode *prog;

    struct {
        nodeType type;
        char *rawValue;
    } value;
}


%token TOKPRINT

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
%type <prog> program

%right '='
%left ARITH_OP

%%

program:
    statements {
        root = new RootNode();
        printf("%s\n", getNodeTypeName(BOOL).c_str());
    }
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
        $$.type = STR;
    }
    |
    TOKINTEGER {
        $$.rawValue = $1;
        $$.type = INT;
    }
    |
    TOKFLOAT {
        $$.rawValue = $1;
        $$.type = FLOAT;
    }
    |
    TOKBOOL {
        $$.rawValue = $1;
        $$.type = BOOL;
    }

identifier:
    IDENT {
        $$.rawValue = $1;
        $$.type = IDENTIFIER;
    }

expression:
    literal
    |
    identifier
    |
    expression ARITH_OP expression {
        printf("%s\n", $2);
        printf("%s\n", $3.rawValue);
    }
    ;

declaration:
    TYPEIDENT identifier '=' TOKSTRING {

    }
    |
    TYPEIDENT identifier '=' TOKINTEGER {

    }
    |
    TYPEIDENT identifier '=' TOKFLOAT {

    }
    |
    TYPEIDENT identifier '=' TOKBOOL {

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
%%
