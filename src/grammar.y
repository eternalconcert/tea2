%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "src/ast.h"
    #include "src/commons.h"
    #include "src/exceptions.h"
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
    int ival;
    float fval;
    bool bval;
    typeId tval;
    AstNode *node;
    Value *valueObj;
}


%token <sval> TOKPRINT TOKPLUS TOKMINUS TOKTIMES TOKDIVIDE TOKEQUAL TOKNEQUAL TOKGT TOKGTE TOKLT TOKLTE TOKCONST

%token <tval> TYPEIDENT
%token <sval> TOKSTRING
%token <ival> TOKINTEGER
%token <fval> TOKFLOAT
%token <bval> TOKBOOL
%token <sval> TOKIDENT

%type <sval> operator
%type <valueObj> act_param expression literal
%type <node> program statement const_declaration print_statement act_params expressions


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
    print_statement {
        root->addToChildList($$);
    }
    | const_declaration {
        root->addToChildList($$);
    }
    | expressions {
        root->addToChildList($$);
    }
    ;

expressions:
    expression {
        ExpressionNode *expNode = new ExpressionNode();
        expNode->value = $1;
        $$ = expNode;
    }
    |
    expressions operator expression {
        ExpressionNode *child = new ExpressionNode();
        child->op = $2;
        child->value = $3;
        $$->addToChildList(child);
    }
    ;

expression:
    literal {
        $$ = $1;
    }
    |
    TOKIDENT {
        Value *valueObj = new Value();
        valueObj->setIdent($1);
        $$ = valueObj;
    }
    ;

operator:
    TOKPLUS
    |
    TOKMINUS
    |
    TOKTIMES
    |
    TOKDIVIDE
    |
    TOKEQUAL
    |
    TOKNEQUAL
    |
    TOKGT
    |
    TOKGTE
    |
    TOKLT
    |
    TOKLTE
    ;

act_params: {
        $$ = new AstNode();
    };
    |
    act_param {
        ActParamNode *param = new ActParamNode();
        param->value = $1;
        $$->addToChildList(param);
    }
    |
    act_params ',' act_param {
        ActParamNode *param = new ActParamNode();
        param->value = $3;
        $$->addToChildList(param);
    }
    ;

act_param:
    literal {
        $$ = $1;
    }
    |
    TOKIDENT {
        Value *valueObj = new Value();
        valueObj->setIdent($1);
        $$ = valueObj;
    }
    ;

literal:
    TOKSTRING {
        Value *valueObj = new Value();
        valueObj->set($1);
        $$ = valueObj;
    }
    |
    TOKINTEGER {
        Value *valueObj = new Value();
        valueObj->set($1);
        $$ = valueObj;
    }
    |
    TOKFLOAT {
        Value *valueObj = new Value();
        valueObj->set($1);
        $$ = valueObj;
    }
    |
    TOKBOOL {
        Value *valueObj = new Value();
        valueObj->set($1);
        $$ = valueObj;
    }
    ;

print_statement:
    TOKPRINT '(' act_params ')' {
        PrintNode *print = new PrintNode($3);
        $$ = print;
    }
    ;

const_declaration:
    TOKCONST TYPEIDENT TOKIDENT '=' literal {
    ConstNode *constant = new ConstNode($2, $3, $5);
    $$ = constant;
    }

%%
