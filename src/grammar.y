%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "src/ast/ast.h"
    #include "src/commons.h"
    #include "src/exceptions.h"
    #include <string.h>
    #include <filesystem>
    #include <fstream>
    #include <map>
    #include <set>
    #include <sstream>
    #include <vector>

    AstNode *root = new AstNode();
    AstNode *curScope = root;
    std::vector<std::string> parseFileStack;
    std::set<std::string> importedTeaModules;
    std::set<std::string> importingTeaModules;
    std::map<std::string, std::map<std::string, Value*>> importedTeaModuleValues;

    void pushScope() {
        AstNode *newScope = new AstNode();
        newScope->parent = curScope;
        curScope = newScope;
    };

    void popScope() {
        curScope = curScope->parent;
    };

    typedef struct yy_buffer_state *YY_BUFFER_STATE;
    extern FILE *yyin;
    extern int yylineno;
    extern char *yytext;
        int yyparse(void);
        int yylex(void);
        YY_BUFFER_STATE yy_scan_string(const char* instream);
        void yy_delete_buffer(YY_BUFFER_STATE buffer);

    std::string resolveTeaPath(std::string path, std::string baseDir) {
        std::filesystem::path importPath(path);
        if (importPath.is_relative()) {
            importPath = std::filesystem::path(baseDir) / importPath;
        }
        return std::filesystem::weakly_canonical(importPath).string();
    }

    std::string currentParseDir() {
        if (parseFileStack.empty()) {
            return std::filesystem::current_path().string();
        }
        return std::filesystem::path(parseFileStack.back()).parent_path().string();
    }

    std::string readTeaSource(std::string path) {
        std::ifstream file(path);
        if (!file) {
            printf("ImportError: Could not open %s\n", path.c_str());
            exit(10);
        }
        std::stringstream buffer;
        buffer << file.rdbuf();
        return buffer.str();
    }

    AstNode *parseTeaSourceIntoScope(std::string source, std::string sourceName, AstNode *scope) {
        AstNode *previousScope = curScope;
        curScope = scope;
        parseFileStack.push_back(sourceName);
        yylineno = 1;

        YY_BUFFER_STATE buffer = yy_scan_string(source.c_str());
        yyparse();
        yy_delete_buffer(buffer);

        parseFileStack.pop_back();
        curScope = previousScope;
        return scope;
    }

    AstNode *parseTeaFileIntoScope(std::string path, AstNode *scope) {
        std::string absolutePath = resolveTeaPath(path, currentParseDir());
        return parseTeaSourceIntoScope(readTeaSource(absolutePath), absolutePath, scope);
    }

    bool isTeaModuleImported(std::string path) {
        return importedTeaModules.count(path) > 0;
    }

    bool beginTeaModuleImport(std::string path) {
        if (importingTeaModules.count(path) > 0) {
            return false;
        }
        importingTeaModules.insert(path);
        return true;
    }

    void finishTeaModuleImport(std::string path) {
        importingTeaModules.erase(path);
        importedTeaModules.insert(path);
    }

    void markTeaModuleImported(std::string path) {
        importedTeaModules.insert(path);
    }

    void registerImportedTeaModuleValue(std::string path, std::string ident, Value *value) {
        importedTeaModuleValues[path][ident] = value;
    }

    void copyImportedTeaModuleValues(std::string path, AstNode *scope) {
        for (auto const& item : importedTeaModuleValues[path]) {
            scope->valueStore->set(item.first, item.second);
        }
    }

        int yywrap() {
            return 1;
        }

    void yyerror(const char *str) {
        fprintf(stderr, "Error: %s: %s on line %d\n", str, yytext, yylineno);
        exit(1);
    }

int main(int argc, char *argv[0]) {
    std::string mainSource;
    std::string mainSourceName;

    if (argc <= 1) {
        printf("%s\n", "No file or command specified");
        exit(1);
    }

    else if (argc >= 3 and !strcmp(argv[1], "-c")) {
        mainSource = argv[2];
        mainSourceName = std::filesystem::current_path().string() + "/<command>";
    }

    else if (argc == 2 and !strcmp(argv[1], "-v")) {
        printf("%i\n", BUILDNO);
        exit(0);
    }

    else if (argc >= 2) {
        mainSourceName = resolveTeaPath(argv[1], std::filesystem::current_path().string());
        std::ifstream inFile(mainSourceName);
        if (!inFile) {
            printf("tea: /%s: No such file or directory\n", argv[1]);
            exit(1);
        }
        std::stringstream buffer;
        buffer << inFile.rdbuf();
        mainSource = buffer.str();
    }

    else {
        printf("tea: Problem during startup\n");
        exit(1);
    }

    std::string stdlibPath = resolveTeaPath("lib/common.t", std::filesystem::current_path().string());
    if (!std::filesystem::exists(stdlibPath)) {
        stdlibPath = resolveTeaPath("common/string.t", std::filesystem::current_path().string());
    }
    if (std::filesystem::exists(stdlibPath)) {
        ImportNode *stdlibImport = new ImportNode(strdup(stdlibPath.c_str()), root, std::filesystem::current_path().string());
        stdlibImport->evaluate();
    }

    parseTeaSourceIntoScope(mainSource, mainSourceName, root);
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


%token TOKIF TOKELSE TOKFN TOKRETURN TOKWHILE TOKIMPORT TOKEXPORT
%token TOKPRINT TOKOUT TOKREADFILE TOKWRITEFILE TOKQUIT TOKSLEEP TOKASSERT TOKCMD TOKSYSARGS TOKLRC TOKINPUT TOKCAST TOKSPLIT TOKFIND TOKLEN
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
%type <node> expression literal array_literal array_items array_index fn_call
%type <node> statement statements if_statement fn_declaration return_stmt while_loop import_statement export_statement
%type <node> var_declaration var_declaration_assignment var_assignment  expressions act_params act_param formal_params builtin_function
%type <node> print out read write split find len input quit sleep assert cmd sysargs lastrc cast

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
    | import_statement {
        $$ = $1;
    }
    | export_statement {
        $$ = $1;
    }
    ;

import_statement:
    TOKIMPORT TOKSTRING {
        ImportNode *importNode = new ImportNode($2, curScope, currentParseDir());
        $$ = importNode;
    }
    ;

export_statement:
    TOKEXPORT fn_declaration {
        $2->exported = true;
        $$ = $2;
    }
    |
    TOKEXPORT var_declaration {
        $2->exported = true;
        $$ = $2;
    }
    |
    TOKEXPORT var_declaration_assignment {
        $2->exported = true;
        $$ = $2;
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
    array_index {
        $$ = $1;
    }
    |
    fn_call {
        $$ = $1;
    }
    ;

array_index:
    TOKIDENT '[' expressions ']' {
        ArrayIndexNode *arrayIndex = new ArrayIndexNode($1, $3, curScope);
        $$ = arrayIndex;
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
        $$ = NULL;
    }
    |
    act_param {
        $1->addToChildList($1);
        $$ = $1;
    }
    |
    act_params ',' act_param {
        if ($1 == NULL) {
            $$ = $3;
        } else {
            $1->addToChildList($3);
            $$ = $1;
        }
    }
    ;

act_param:
    expressions {
        $$ = $1;
    }
    ;

formal_params: /* empty */ {
        $$ = NULL;
    }
    |
    var_declaration {
        $1->addToChildList($1);
        $$ = $1;
    }
    |
    formal_params ',' var_declaration {
        if ($1 == NULL) {
            $$ = $3;
        } else {
            $1->addToChildList($3);
            $$ = $1;
        }
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
    |
    array_literal {
        $$ = $1;
    }
    ;

array_literal:
    '[' array_items ']' {
        ArrayLiteralNode *arrayLiteral = new ArrayLiteralNode($2, curScope);
        $$ = arrayLiteral;
    }
    ;

array_items: /* empty */ {
        $$ = new AstNode();
    }
    |
    expressions {
        AstNode *items = new AstNode();
        items->addToChildList($1);
        $$ = items;
    }
    |
    array_items ',' expressions {
        $1->addToChildList($3);
        $$ = $1;
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
    write
    |
    split
    |
    find
    |
    len
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
    |
    cast
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

write:
    TOKWRITEFILE '(' expressions ',' expressions ')' {
        WriteFileNode *writeFile = new WriteFileNode($3, $5, curScope);
        $$ = writeFile;
    }
    ;

split:
    TOKSPLIT '(' expressions ',' expressions ')' {
        SplitNode *split = new SplitNode($3, $5, curScope);
        $$ = split;
    }
    ;

find:
    TOKFIND '(' expressions ',' expressions ')' {
        FindNode *find = new FindNode($3, $5, curScope);
        $$ = find;
    }
    ;

len:
    TOKLEN '(' expressions ')' {
        LenNode *len = new LenNode($3, curScope);
        $$ = len;
    }
    ;

input:
    TOKINPUT {
        InputNode *input = new InputNode(curScope);
        $$ = input;
    }
    ;

cast:
    TOKCAST '(' TOKIDENT ',' TYPEIDENT ')' {
        CastNode *cast = new CastNode($3, $5, curScope);
        $$ = cast;
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
