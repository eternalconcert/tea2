%code requires {
#include <string>
struct TeaLocation {
    int first_line;
    int first_column;
    int last_line;
    int last_column;
    std::string filename;
};
}
%define api.location.type {struct TeaLocation}

%code provides {
#undef YYLLOC_DEFAULT
#define YYLLOC_DEFAULT(Current, Rhs, N)                             \
    do {                                                            \
        if (N) {                                                    \
            (Current).first_line = YYRHSLOC(Rhs, 1).first_line;     \
            (Current).first_column = YYRHSLOC(Rhs, 1).first_column; \
            (Current).last_line = YYRHSLOC(Rhs, N).last_line;       \
            (Current).last_column = YYRHSLOC(Rhs, N).last_column;   \
            (Current).filename = YYRHSLOC(Rhs, 1).filename;         \
        } else {                                                    \
            (Current).first_line = (Current).last_line =             \
                YYRHSLOC(Rhs, 0).last_line;                        \
            (Current).first_column = (Current).last_column =        \
                YYRHSLOC(Rhs, 0).last_column;                      \
            (Current).filename = YYRHSLOC(Rhs, 0).filename;         \
        }                                                           \
    } while (0)
}

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
    #include "src/init_code.h"

    static AstNode *tea_merge_binary(AstNode *left, char *op, AstNode *right) {
        ExpressionNode *l = (ExpressionNode*)left;
        ExpressionNode *r = (ExpressionNode*)right;
        r->op = op;
        l->addToChildList(r);
        return l;
    }

    AstNode *root = new AstNode();
    AstNode *curScope = root;
    std::vector<std::string> parseFileStack;
    std::set<std::string> importedTeaModules;
    std::set<std::string> importingTeaModules;
    std::map<std::string, std::map<std::string, Value*>> importedTeaModuleValues;
    std::map<std::string, bool> importedTeaModuleLowPriority;

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

    TeaImportResolved resolveTeaImport(std::string path, std::string baseDir) {
        std::error_code ec;
        if (!path.empty() && path[0] == '@') {
            std::string rel = path.substr(1);
            while (!rel.empty() && (rel[0] == '/' || rel[0] == '\\')) {
                rel.erase(0, 1);
            }
            std::filesystem::path teahousePath;
            if (rel.empty()) {
                teahousePath = std::filesystem::current_path() / "teahouse";
            } else {
                teahousePath = std::filesystem::current_path() / "teahouse" / rel;
            }
            std::string canonical = std::filesystem::weakly_canonical(teahousePath, ec).string();
            return { canonical, true };
        }
        return { resolveTeaPath(path, baseDir), false };
    }

    void setImportedTeaModuleLowPriority(std::string path, bool low) {
        importedTeaModuleLowPriority[path] = low;
    }

    bool importedTeaModuleHasLowPriorityExports(std::string path) {
        auto it = importedTeaModuleLowPriority.find(path);
        return it != importedTeaModuleLowPriority.end() && it->second;
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
        tea_reset_lexer_column();

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
        bool low = importedTeaModuleHasLowPriorityExports(path);
        for (auto const& item : importedTeaModuleValues[path]) {
            if (!low || scope->valueStore->get(item.first) == nullptr) {
                scope->valueStore->set(item.first, item.second);
            }
        }
    }

        int yywrap() {
            return 1;
        }

    void yyerror(const char *str) {
        const char *tok = yytext;
        if (!tok || !tok[0]) {
            tok = "end of file";
        }
        int err_line = yylloc.first_line;
        int err_col = yylloc.first_column;
        if (!parseFileStack.empty()) {
            fprintf(stderr, "%s:%d:%d: Error: %s (at %s)\n",
                    parseFileStack.back().c_str(), err_line, err_col, str, tok);
        } else if (!yylloc.filename.empty()) {
            fprintf(stderr, "%s:%d:%d: Error: %s (at %s)\n",
                    yylloc.filename.c_str(), err_line, err_col, str, tok);
        } else {
            fprintf(stderr, "%d:%d: Error: %s (at %s)\n",
                    err_line, err_col, str, tok);
        }
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

    // Execute embedded init code from stdlib/sys.t
    if (INIT_CODE && strlen(INIT_CODE) > 0) {
        parseTeaSourceIntoScope(std::string(INIT_CODE), "<embedded-init>", root);
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


%token TOKIF TOKELSE TOKFN TOKRETURN TOKWHILE TOKFOR TOKBREAK TOKCONTINUE TOKIMPORT TOKEXPORT TOKTHROW
%token TOKSYSPRINT TOKOUT TOKREADFILE TOKWRITEFILE TOKQUIT TOKSLEEP TOKASSERT TOKCMD TOKSYSARGS TOKLRC TOKINPUT TOKCAST TOKSPLIT TOKFIND TOKLEN TOKDICTKEYS TOKDICTVALUES TOKELLIPSIS
%token TOKLBRACE TOKRBRACE

%token <sval> TOKPLUS TOKMINUS TOKTIMES TOKDIVIDE TOKMOD
%token <sval> TOKEQUAL TOKNEQUAL TOKGT TOKGTE TOKLT TOKLTE TOKAND TOKOR
%token <tval> TYPEIDENT
%token <sval> TOKSTRING
%token <ival> TOKINTEGER
%token <fval> TOKFLOAT
%token <bval> TOKBOOL
%token <sval> TOKIDENT

%type <node> or_expr and_expr eq_expr rel_expr add_expr mul_expr unary_expr
%type <node> expression literal array_literal array_items dict_literal dict_items dict_item dict_key array_index fn_call
%type <node> statement statements if_statement fn_declaration return_stmt while_loop for_loop import_statement export_statement throw
%type <node> var_declaration var_declaration_assignment var_assignment  expressions act_params act_param formal_params builtin_function
%type <node> sysprint out read write split find len dictKeys dictValues input quit sleep assert cmd sysargs lastrc cast
%type <node> for_init for_condition for_post

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
    | TOKIDENT '[' expressions ']' '=' expressions {
        ArrayAssignmentNode *assignment = new ArrayAssignmentNode($1, $3, $6, curScope);
        $$ = assignment;
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
    | for_loop {
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
    | throw {
        $$ = $1;
    }
    | TOKBREAK {
        $$ = new BreakNode();
    }
    | TOKCONTINUE {
        $$ = new ContinueNode();
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
    or_expr {
        $$ = $1;
    }
    ;

or_expr:
    and_expr {
        $$ = $1;
    }
    |
    or_expr TOKOR and_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    ;

and_expr:
    eq_expr {
        $$ = $1;
    }
    |
    and_expr TOKAND eq_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    ;

eq_expr:
    rel_expr {
        $$ = $1;
    }
    |
    eq_expr TOKEQUAL rel_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    |
    eq_expr TOKNEQUAL rel_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    ;

rel_expr:
    add_expr {
        $$ = $1;
    }
    |
    rel_expr TOKGT add_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    |
    rel_expr TOKGTE add_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    |
    rel_expr TOKLT add_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    |
    rel_expr TOKLTE add_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    ;

add_expr:
    mul_expr {
        $$ = $1;
    }
    |
    add_expr TOKPLUS mul_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    |
    add_expr TOKMINUS mul_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    ;

mul_expr:
    unary_expr {
        $$ = $1;
    }
    |
    mul_expr TOKTIMES unary_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    |
    mul_expr TOKDIVIDE unary_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    |
    mul_expr TOKMOD unary_expr {
        $$ = tea_merge_binary($1, $2, $3);
    }
    ;

unary_expr:
    expression {
        $$ = $1;
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
        $$ = $1;
    }
    |
    act_params ',' act_param {
        if ($1 == NULL) {
            $$ = $3;
        } else {
            $1->appendNextSibling($3);
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
        $$ = $1;
    }
    |
    formal_params ',' var_declaration {
        if ($1 == NULL) {
            $$ = $3;
        } else {
            $1->appendNextSibling($3);
            $$ = $1;
        }
    }
    |
    TOKELLIPSIS TOKIDENT {
        VarDeclarationNode *variable = new VarDeclarationNode(ARRAY, $2, curScope, true);
        $$ = variable;
    }
    |
    formal_params ',' TOKELLIPSIS TOKIDENT {
        VarDeclarationNode *variable = new VarDeclarationNode(ARRAY, $4, curScope, true);
        if ($1 == NULL) {
            $$ = variable;
        } else {
            $1->appendNextSibling(variable);
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
    |
    dict_literal {
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

dict_literal:
    TOKLBRACE dict_items TOKRBRACE {
        DictLiteralNode *dictLiteral = new DictLiteralNode($2, curScope);
        $$ = dictLiteral;
    }
    ;

dict_items: /* empty */ {
        $$ = new AstNode();
    }
    |
    dict_item {
        AstNode *items = new AstNode();
        items->addToChildList($1);
        $$ = items;
    }
    |
    dict_items ',' dict_item {
        $1->addToChildList($3);
        $$ = $1;
    }
    ;

dict_item:
    dict_key ':' expressions {
        AstNode *entry = new AstNode();
        entry->addToChildList($1);
        entry->addToChildList($3);
        $$ = entry;
    }
    ;

dict_key:
    TOKSTRING {
        ExpressionNode *expNode = new ExpressionNode(curScope);
        Value *valueObj = new Value();
        valueObj->set($1, @1);
        expNode->value = valueObj;
        $$ = expNode;
    }
    |
    TOKIDENT {
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
        fnCall->value->setFnCall($1, fnCall, curScope, @1);
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

for_loop:
    TOKFOR '(' for_init ';' for_condition ';' for_post ')' lbrace statements rbrace {
        ForNode *forNode = new ForNode();
        $$ = forNode;
        forNode->init = $3;
        forNode->condition = $5;
        forNode->post = $7;
        forNode->addToChildList($10);
    }
    ;

for_init: /* empty */ {
        $$ = NULL;
    }
    | var_declaration_assignment {
        $$ = $1;
    }
    | var_assignment {
        $$ = $1;
    }
    | var_declaration {
        $$ = $1;
    }
    | expressions {
        $$ = $1;
    }
    ;

for_condition: /* empty */ {
        $$ = NULL;
    }
    | expressions {
        $$ = $1;
    }
    ;

for_post: /* empty */ {
        $$ = NULL;
    }
    | var_assignment {
        $$ = $1;
    }
    | expressions {
        $$ = $1;
    }
    ;


builtin_function:  // Causes reduce/reduce conflict
    sysprint
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
    dictKeys
    |
    dictValues
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

throw:
    TOKTHROW TOKIDENT '(' expressions ')' {
        ThrowNode *throwNode = new ThrowNode($2, $4, curScope);
        $$ = throwNode;
    }
    ;

sysprint:
    TOKSYSPRINT '(' act_params ')' {
        PrintNode *print = new PrintNode($3, curScope, false);
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

dictKeys:
    TOKDICTKEYS '(' expressions ')' {
        KeysNode *keys = new KeysNode($3, curScope);
        $$ = keys;
    }
    ;

dictValues:
    TOKDICTVALUES '(' expressions ')' {
        ValuesNode *values = new ValuesNode($3, curScope);
        $$ = values;
    }
    ;

input:
    TOKINPUT {
        InputNode *input = new InputNode(curScope);
        $$ = input;
    }
    ;

cast:
    TOKCAST '(' expressions ',' TYPEIDENT ')' {
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
    |
    TOKSYSARGS {
        SystemArgsNode *sysArgs = new SystemArgsNode(nullptr, curScope);
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
