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

int main(int argc, char *argv[0]) {
    if (argc <= 1) {
        printf("%s\n", "No file or command specified");
        exit(1);
    }

    else if (argc >= 3 and !strcmp(argv[1], "-c")) {
        yy_scan_string(argv[2]);
    }

    else if (argc == 2 and !strcmp(argv[1], "-v")) {
        printf("%i\n", BUILDNO);
        exit(0);
    }

    else if (argc >= 2) {
        FILE *inFile = fopen(argv[1], "r");
        if (!inFile) {
            printf("tea: /%s: No such file or directory\n", argv[1]);
            exit(1);
        }
        yyin = inFile;
    }

    else {
        printf("tea: Problem during startup\n");
        exit(1);
    }

    yyparse();
    root->init(argc, argv);
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


%token TOKIF TOKELSE TOKFN TOKRETURN TOKWHILE
%token TOKPRINT TOKOUT TOKREADFILE TOKQUIT TOKSLEEP TOKASSERT TOKCMD TOKSYSARGS TOKLRC TOKINPUT
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
%type <node> statement statements if_statement fn_declaration return_stmt while_loop
%type <node> var_declaration var_declaration_assignment var_assignment  expressions act_params act_param formal_params builtin_function
%type <node> print out read input quit sleep assert cmd sysargs lastrc

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
        $2->setLocation(@2);
        curScope->addToChildList($2);
    }
    ;

statement:
    var_declaration {
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
    | while_loop {
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
        valueObj->setIdent($1, curScope, @1);
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

formal_params: /* empty */ {
        $$ = new AstNode();
    }
    |
    var_declaration {
        $1->addToChildList($1);
    }
    |
    formal_params ',' var_declaration {
        $1->addToChildList($3);
    }
    ;

literal:
    TOKSTRING {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1, @1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    TOKINTEGER {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1, @1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    TOKFLOAT {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1, @1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    TOKBOOL {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1, @1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    ;

var_declaration:
    TYPEIDENT TOKIDENT {
        VarDeclarationNode *variable = new VarDeclarationNode($1, $2, curScope);
        $$ = variable;
    }
    ;

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

fn_declaration:
    TYPEIDENT TOKFN TOKIDENT '(' formal_params ')' lbrace statements rbrace {
        FnDeclarationNode *fnDeclarationNode = new FnDeclarationNode($1, $3, $5, curScope);
        fnDeclarationNode->addToChildList($8);
        $$ = fnDeclarationNode;
};

fn_call:
    builtin_function
    |
    TOKIDENT '(' act_params ')' {
        FnCallNode *fnCall = new FnCallNode($1, $3, curScope);
        fnCall->value->setFnCall($1, $$, curScope, @1);
        $$ = fnCall;
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

while_loop:
    TOKWHILE '(' expressions ')' lbrace statements rbrace {
        WhileNode *whileNode = new WhileNode();
        $$ = whileNode;
        whileNode->condition = $3;
        whileNode->addToChildList($6);
    }
    ;


builtin_function:  // Causes reduce/reduce conflict
    print
    |
    out
    |
    read
    |
    input
    |
    quit
    |
    sleep
    |
    assert
    |
    cmd
    |
    sysargs
    |
    lastrc
    ;

print:
    TOKPRINT '(' act_params ')' {
        PrintNode *print = new PrintNode($3, curScope, true);
        $$ = print;
    }
    ;

out:
    TOKOUT '(' act_params ')' {
        PrintNode *print = new PrintNode($3, curScope, false);
        $$ = print;
    }

read:
    TOKREADFILE '(' TOKSTRING ')' {
        Value *valueObj = new Value();
        valueObj->set($3, @3);

        ReadFileNode *readFile = new ReadFileNode(valueObj, curScope);
        $$ = readFile;
    }
    |
    TOKREADFILE '(' TOKIDENT ')' {
        Value *valueObj = new Value();
        valueObj->setIdent($3, curScope, @3);

        ReadFileNode *readFile = new ReadFileNode(valueObj, curScope);
        $$ = readFile;
    }
    ;

input:
    TOKINPUT {
        InputNode *input = new InputNode(curScope);
        $$ = input;
    }
    ;

assert:
    TOKASSERT '(' act_params ')' {
        AssertNode *assert = new AssertNode($3, curScope);
        $$ = assert;
    }
    ;

cmd:
    TOKCMD '(' TOKSTRING ')' {
        Value *valueObj = new Value();
        valueObj->set($3, @3);

        CmdNode *cmd = new CmdNode(valueObj, curScope);
        $$ = cmd;
    }
    |
    TOKCMD '(' TOKIDENT ')' {
        Value *valueObj = new Value();
        valueObj->setIdent($3, curScope, @3);

        CmdNode *cmd = new CmdNode(valueObj, curScope);
        $$ = cmd;
    }
    ;

sysargs:
    TOKSYSARGS '[' TOKINTEGER ']' {
        Value *valueObj = new Value();
        valueObj->set($3, @3);

        SystemArgsNode *sysArgs = new SystemArgsNode(valueObj, curScope);
        $$ = sysArgs;
    }
    |
    TOKSYSARGS '[' TOKIDENT ']' {
        Value *valueObj = new Value();
        valueObj->setIdent($3, curScope, @3);

        SystemArgsNode *sysArgs = new SystemArgsNode(valueObj, curScope);
        $$ = sysArgs;
    }
    ;

lastrc:
    TOKLRC {
        LastRcNode *lrc = new LastRcNode();
        $$ = lrc;
    }

quit:
    TOKQUIT '(' TOKINTEGER ')' {
        Value *valueObj = new Value();
        valueObj->set($3, @3);

        QuitNode *quit = new QuitNode(valueObj, curScope);
        $$ = quit;
    }
    |
    TOKQUIT '(' TOKIDENT ')' {
        Value *valueObj = new Value();
        valueObj->setIdent($3, curScope, @3);

        QuitNode *quit = new QuitNode(valueObj, curScope);
        $$ = quit;
    }
    |
    TOKQUIT '('  ')' {
        Value *valueObj = new Value();
        valueObj->set(0, @1);

        QuitNode *quit = new QuitNode(valueObj, curScope);
        $$ = quit;
    }
    ;

sleep:
    TOKSLEEP '(' TOKFLOAT ')' {
        Value *valueObj = new Value();
        valueObj->set($3, @3);

        SleepNode *sleep = new SleepNode(valueObj, curScope);
        $$ = sleep;
    }
    |
    TOKSLEEP '(' TOKINTEGER ')' {
        Value *valueObj = new Value();
        valueObj->set($3, @3);

        SleepNode *sleep = new SleepNode(valueObj, curScope);
        $$ = sleep;
    }
    |
    TOKSLEEP '(' TOKIDENT ')' {
        Value *valueObj = new Value();
        valueObj->setIdent($3, curScope, @3);

        SleepNode *sleep = new SleepNode(valueObj, curScope);
        $$ = sleep;
    }
    ;


%%
