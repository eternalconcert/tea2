%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "src/ast/ast.h"
    #include "src/commons.h"
    #include "src/exceptions.h"
    #include <string.h>


    AstNode *root = new AstNode();
    AstNode *curScope = root;

    void pushScope() {
        AstNode *newScope = new AstNode();
        newScope->parent = curScope;
        curScope = newScope;
    };

    void popScope() {
        curScope = curScope->parent;
    };

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
}


%token TOKIF TOKELSE TOKCONST TOKFN TOKRETURN
%token TOKPRINT TOKREADFILE TOKQUIT
%token TOKLBRACE TOKRBRACE

%token <sval> TOKPLUS TOKMINUS TOKTIMES TOKDIVIDE TOKMOD
%token <sval> TOKEQUAL TOKNEQUAL TOKGT TOKGTE TOKLT TOKLTE TOKAND TOKOR
%token <tval> TYPEIDENT
%token <sval> TOKSTRING
%token <ival> TOKINTEGER
%token <fval> TOKFLOAT
%token <bval> TOKBOOL
%token <sval> TOKIDENT

%type <sval> operator
%type <node> expression literal fn_call
%type <node> statement statements if_statement fn_declaration return_stmt const_declaration
%type <node> var_declaration var_declaration_assignment var_assignment act_params expressions act_param builtin_function
%type <node> print readFile quit

%start statements

%%

lbrace:
    TOKLBRACE {
        pushScope();
}

rbrace:
    TOKRBRACE {
    popScope();
}

statements: {
        $$ = curScope;
    }
    | statements statement ';' {
        curScope->addToChildList($2);
    }
    ;

statement:
    builtin_function {
        $$ = $1;
    }
    | const_declaration {
        $$ = $1;
    }
    | var_declaration {
        $$ = $1;
    }
    | var_assignment {
        $$ = $1;
    }
    | var_declaration_assignment {
        $$ = $1;
    }
    | expressions {
        $$ = $1;
    }
    | if_statement {
        $$ = $1;
    }
    | fn_declaration {
        $$ = $1;
    }
    | return_stmt {
        $$ = $1;
    }
    ;

expressions:
    expression {
        $$ = $1;
    }
    |
    expressions operator expression {
        ExpressionNode *child = (ExpressionNode*)$3;
        child->op = $2;
        $$->addToChildList($3);
    }
    ;

expression:
    literal {
        $$ = $1;
    }
    |
    TOKIDENT {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->setIdent($1, curScope);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    fn_call {
        $$ = $1;
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
    TOKMOD
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
    |
    TOKAND
    |
    TOKOR
    ;

return_stmt:
    TOKRETURN expressions {
        ReturnNode *n = new ReturnNode(curScope);
        n->addToChildList($2);
        $$ = n;
    }
    ;

act_params: /* empty */ {
        $$ = new AstNode();
    }
    |
    act_param {
        $1->addToChildList($1);
    }
    |
    act_params ',' act_param {
        $1->addToChildList($3);
    }
    ;

act_param:
    expressions {
        $$ = $1;
    }
    ;

literal:
    TOKSTRING {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    TOKINTEGER {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    TOKFLOAT {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    TOKBOOL {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    ;

const_declaration:
    TOKCONST TYPEIDENT TOKIDENT '=' literal {
        ConstNode *constant = new ConstNode($2, $3, $5);
        $$ = constant;
    }
    ;

var_declaration:
    TYPEIDENT TOKIDENT {
        VarDeclarationNode *variable = new VarDeclarationNode($1, $2, curScope);
        $$ = variable;
    }
    ;

fn_declaration:
    TYPEIDENT TOKFN TOKIDENT '(' /* formal_params */ ')' lbrace statements rbrace {
        FnNode *fnNode = new FnNode($1, $3, curScope);
        fnNode->addToChildList($7);
        $$ = fnNode;
};

fn_call:
    TOKIDENT '(' /* act_params */ ')' {
        ExpressionNode *retNode = new ExpressionNode(curScope);
        Value *fnCall = new Value();
        fnCall->setFnCall($1, retNode, curScope);
        retNode->value = fnCall;
        $$ = retNode;
    }

var_assignment:
    TOKIDENT '=' expressions {
        VarAssignmentNode *variable = new VarAssignmentNode($1, $3, curScope);
        $$ = variable;
    }

var_declaration_assignment:
        TYPEIDENT TOKIDENT '=' expressions {
        VarNode *variable = new VarNode($1, $2, $4, curScope);
        $$ = variable;
    }
    ;

if_statement:
    TOKIF '(' expressions ')' lbrace statements rbrace {
        IfNode *ifNode = new IfNode();
        $$ = ifNode;
        ifNode->addToChildList($3);
        ifNode->addToChildList($6);
    }
    |
    TOKIF '(' expressions ')' lbrace statements rbrace TOKELSE lbrace statements rbrace {
        IfNode *ifNode = new IfNode();
        $$ = ifNode;
        ifNode->addToChildList($3);
        ifNode->addToChildList($6);

        ifNode->elseBlock = ($10);
    };


builtin_function:
    print
    |
    readFile
    |
    quit

print:
    TOKPRINT '(' act_params ')' {
        PrintNode *print = new PrintNode($3, curScope);
        $$ = print;
    }
    ;

readFile:
    TOKREADFILE '(' TOKSTRING ')' {
        Value *valueObj = new Value();
        valueObj->set($3);

        ReadFileNode *readFile = new ReadFileNode(valueObj, curScope);
        $$ = readFile;
    }
    |
    TOKREADFILE '(' TOKIDENT ')' {
        Value *valueObj = new Value();
        valueObj->setIdent($3, curScope);

        ReadFileNode *readFile = new ReadFileNode(valueObj, curScope);
        $$ = readFile;
    }
    ;

quit:
    TOKQUIT '(' TOKINTEGER ')' {
        Value *valueObj = new Value();
        valueObj->set($3);

        QuitNode *quit = new QuitNode(valueObj, curScope);
        $$ = quit;
    }
    |
    TOKQUIT '(' TOKIDENT ')' {
        Value *valueObj = new Value();
        valueObj->setIdent($3, curScope);

        QuitNode *quit = new QuitNode(valueObj, curScope);
        $$ = quit;
    }
    |
    TOKQUIT '('  ')' {
        Value *valueObj = new Value();
        valueObj->set(0);

        QuitNode *quit = new QuitNode(valueObj, curScope);
        $$ = quit;
    }

%%
