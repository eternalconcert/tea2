%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "ast.h"
    #include "exceptions.h"
    #include <string.h>

    AstNode *root = new AstNode();
    AstNode *curNode = root;

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
    root->evaluate();
}

%}

%union
{
    char *sval;
    AstNode *node;
}


%token TOKPRINT PLUS MINUS TIMES DIVIDE

%token <sval> TYPEIDENT
%token <sval> TOKSTRING
%token <sval> TOKINTEGER
%token <sval> TOKFLOAT
%token <sval> TOKBOOL
%token <sval> IDENT


%type <sval> act_param
%type <node> program
%type <node> print_statement act_params


%%

program:
    statements {
        $$ = root;
    }
    ;

statements: /* empty */
    | statements statement ';'
    ;

statement:
    print_statement
    ;

act_params: /* empty */ {
        $$ = new AstNode();
    };
    | act_param {
        ActParamNode *param = new ActParamNode();
        param->value = $1;
        $$->addToChildList(param);
    }
    | act_params ',' act_param {
        ActParamNode *param = new ActParamNode();
        param->value = $3;
        $$->addToChildList(param);
    }
    ;

act_param:
    TOKSTRING
    |
    TOKINTEGER
    |
    TOKFLOAT
    |
    TOKBOOL
    ;


print_statement:
    TOKPRINT '(' act_params ')' {
        PrintNode *print = new PrintNode($3);
        root->addToChildList(print);
    }
    ;
%%
